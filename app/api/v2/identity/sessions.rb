# frozen_string_literal: true

require_dependency 'barong/jwt'

include JWTSessions::Authorization
include JWTSessions::RailsAuthorization

module API::V2
  module Identity
    class Sessions < Grape::API

      helpers do
        def validate_user(user)
          error!({ errors: ['identity.session.invalid_params'] }, 401) unless user

          if user.state == 'banned'
            login_error!(reason: 'Your account is banned', error_code: 401,
                         user: user.id, action: 'login', result: 'failed', error_text: 'banned')
          end

          if user.state == 'deleted'
            login_error!(reason: 'Your account is deleted', error_code: 401,
                         user: user.id, action: 'login', result: 'failed', error_text: 'deleted')
          end
          user
        end

        def validate_app_user(user)
          if user.platform == 'app'
            label = user.labels.find_or_initialize_by(key: 'login_email', scope: 'private')
            if label.value == 'pending' || label.value.to_s == ''
              login_error!(reason: 'Your email verification is pending from mobile app', error_code: 401,
                           user: user.id, action: 'login', result: 'failed',
                           error_text: 'app_email_verification_pending')
            end
          end
        end

        def create_session(user)
          user.update(last_ip: remote_ip, last_country: Barong::GeoIP.info(ip: remote_ip, keys: [:country])[:country])

          tokens = Barong::JWTSession::Session.generate(codec.merge_claims(user.jwt_payload)
                                                          .except(:iat, :exp)).login
          header['access-token']   = tokens[:access]
          header['access-expire']  = tokens[:access_expires_at]
          header['refresh-token']  = tokens[:refresh]
          header['refresh-expire'] = tokens[:refresh_expires_at]
        end
      end

      desc 'Session related routes'
      resource :sessions do
        desc 'Start a new session',
             failure: [
               { code: 400, message: 'Required params are empty' },
               { code: 404, message: 'Record is not found' }
             ]
        params do
          requires :identity,
                   type: String,
                   desc: 'User\'s email or username'
          optional :password,
                   type: String,
                   desc: 'User\'s password'
          optional :captcha_response,
                   types: { value: [String, Hash], message: 'identity.session.invalid_captcha_format' },
                   desc: 'Response from captcha widget'
          optional :otp_code,
                   type: String,
                   desc: 'Code from Google Authenticator'
          optional :reactive_account,
                   type: Boolean,
                   desc: 'Send this true if user\'s social login is disabled'
          optional :login_device, type: Hash do
            requires :device_id,
                     type: String,
                     desc: 'User device id'
            requires :device_type,
                     type: String,
                     default: 'web',
                     desc: 'User device type Android/IOS'
            requires :device_token,
                     type: String,
                     desc: 'User fcm device token Android/IOS'
          end
        end
        post do
          declared_params = declared(params, include_missing: false)

          identifier = find_identifier(declared_params)
          error!({ errors: ['identity.session.invalid_details'] }, 401) unless identifier

          user = if identifier == 'email'
                   User.find_by(email: params[:identity])
                 elsif identifier == 'username'
                   User.find_by(username: params[:identity])
                 elsif identifier == 'phone'
                   phone_number = Phone.international(params[:identity])
                   validate_phone!(phone_number)
                   User.find_by(phone_number: phone_number)
                 end

          error!({ errors: ['identity.session.not_found'] }, 404) unless user

          validate_user(user)

          error!({ errors: ['identity.user.password.disabled'] }, 401) unless user.password_enabled?

          unless user.authenticate(declared_params[:password])
            login_error!(reason: "Invalid #{identifier} or Password", error_code: 401, user: user.id,
                         action: 'login', result: 'failed', error_text: 'invalid_params')
          end

          if user.otp
            error!({ errors: ['identity.session.missing_otp'] }, 401) if declared_params[:otp_code].blank?

            verify_captcha!(response: params['captcha_response'], endpoint: 'session_create')

            unless TOTPService.validate?(user.uid, declared_params[:otp_code])
              login_error!(reason: 'OTP code is invalid', error_code: 403,
                           user: user.id, action: 'login::2fa', result: 'failed', error_text: 'invalid_otp')
            end
            activity_record(user: user.id, action: 'login::2fa', result: 'succeed', topic: 'session')
          end

          if params[:reactive_account]
            user.social_media_status = 'active'
            user.save!
            activity_record(user: user.id, action: 'reactivate social login', result: 'succeed', topic: 'session')
          else
            error!({ errors: ["identity.conflict.#{user.social_media_status}"] }, 409) unless user.social_media_status == 'active'
          end

          user.update_label('email') if user.state == 'pending'

          create_session(user)
          activity_record(user: user.id, action: 'login', result: 'succeed', topic: 'session')

          update_device(user, params[:login_device])

          present user, with: API::V2::Entities::UserWithFullInfo
          status 200
        rescue StandardError => e
          Rails.logger.error e.inspect
          error!(e.message, 422)
        end

        desc 'Start a new session',
             failure: [
                        { code: 400, message: 'Required params are empty' },
                        { code: 404, message: 'Record is not found' }
                      ]
        params do
          requires :identity,
                   type: String,
                   desc: 'User\'s email or username or phone number'
          optional :password,
                   type: String,
                   desc: 'User\'s password'
          optional :captcha_response,
                   types: { value: [String, Hash], message: 'identity.session.invalid_captcha_format' },
                   desc: 'Response from captcha widget'
          optional :otp_code,
                   type: String,
                   desc: 'Code from Google Authenticator'
          optional :channel,
                   type: String,
                   default: 'sms',
                   values: { value: -> { Phone::TWILIO_CHANNELS }, message: 'resource.phone.invalid_channel'},
                   desc: 'The verification method to use'
          optional :platform,
                   type: String,
                   values: { value: -> { %w[icx zen explorer nft app] },
                             message: 'identity.platform.invalid_platform'},
                   default: 'zen',
                   desc: 'User login platform'
        end
        post '/new' do
          declared_params = declared(params, include_missing: false)
          identifier = find_identifier(declared_params)
          error!({ errors: ['identity.session.invalid_details'] }, 401) unless identifier

          user = if identifier == 'email'
                   User.find_by(email: params[:identity])
                 elsif identifier == 'username'
                   User.find_by(username: params[:identity])
                 elsif identifier == 'phone'
                   phone_number = Phone.international(declared_params[:identity])
                   User.find_by(phone_number: phone_number)
                 else
                   error!({ errors: ['identity.session.invalid_identifier'] }, 401)
                 end

          validate_user(user)

          if declared_params[:password]
            error!({ errors: ['identity.user.is_pending'] }, 422) if user.state == 'pending'

            error!({ errors: ['identity.user.password.disabled'] }, 401) unless user.password_enabled

            unless user.authenticate(declared_params[:password])
              login_error!(reason: 'Invalid Email or Password', error_code: 401, user: user.id,
                           action: 'login', result: 'failed', error_text: 'invalid_params')
            end
            unless user.otp
              verify_captcha!(response: params['captcha_response'], endpoint: 'session_create')

              activity_record(user: user.id, action: 'login', result: 'succeed', topic: 'session')
              csrf_token = open_session(user)
              publish_session_create(user)

              present user, with: API::V2::Entities::UserWithFullInfo, csrf_token: csrf_token
              return status 200
            end
            error!({ errors: ['identity.session.missing_otp'] }, 401) if declared_params[:otp_code].blank?

            verify_captcha!(response: params['captcha_response'], endpoint: 'session_create')

            unless TOTPService.validate?(user.uid, declared_params[:otp_code])
              login_error!(reason: 'OTP code is invalid', error_code: 403,
                           user: user.id, action: 'login::2fa', result: 'failed', error_text: 'invalid_otp')
            end
            activity_record(user: user.id, action: 'login::2fa', result: 'succeed', topic: 'session')

            csrf_token = open_session(user)
            publish_session_create(user)
            activity_record(user: user.id, action: 'login', result: 'succeed', topic: 'session')

            present user, with: API::V2::Entities::UserWithFullInfo, csrf_token: csrf_token
            return status 200
          end
          verify_captcha!(response: params['captcha_response'], endpoint: 'session_create')

          user.update(social_media_status: 'active', status_updated_at: Time.now) if user.social_media_status == 'deleted'

          request_from = otp_channel(user) if identifier == 'phone'

          present public_send("send_#{request_from}_otp", user,
                              { action: "sent message to user's #{request_from}",
                                topic: 'session' })
          status 200
        end

        desc 'Destroy current session',
             failure: [
               { code: 400, message: 'Required params are empty' },
               { code: 404, message: 'Record is not found' }
             ],
             success: { code: 200, message: 'Session was destroyed' }
        delete do
          user = User.find_by(uid: session[:uid])
          error!({ errors: ['identity.session.not_found'] }, 404) unless user

          activity_record(user: user.id, action: 'logout', result: 'succeed', topic: 'session')

          session.destroy
          status(200)
        end

        desc 'Resent OTP for the registered phone number',
             success: { code: 200, message: 'User authenticated' },
             failure: [
               { code: 400, message: 'Required params are empty' },
               { code: 404, message: 'Record is not found' }
             ]
        params do
          optional :platform,
                   type: String,
                   values: { value: -> { %w[icx zen explorer nft app] },
                             message: 'identity.platform.invalid_platform'},
                   desc: 'User login platform',
                   default: 'zen'
          optional :phone_number,
                   type: String,
                   allow_blank: false,
                   desc: 'User phone number'
          optional :email,
                   type: String,
                   desc: 'User phone number'
          optional :username,
                   type: String,
                   desc: 'User\'s username'
          optional :channel,
                   type: String,
                   default: 'sms',
                   values: { value: -> { Phone::TWILIO_CHANNELS }, message: 'resource.phone.invalid_channel'},
                   desc: 'The verification method to use'
          optional :reactive_account,
                   type: Boolean,
                   desc: 'Send this true if user\'s social login is disabled'
          optional :captcha_response,
                   types: [String, Hash],
                   desc: 'Response from captcha widget'
          optional :device_id,
                   type: String,
                   desc: 'User device id'
          optional :device_type,
                   type: String,
                   default: 'web',
                   desc: 'User device type Android/IOS'
          at_least_one_of :phone_number, :email, :username, message: 'resource.identity.invalid_parameter'
        end
        post '/verify_user' do
          verify_captcha!(response: params['captcha_response'], endpoint: 'user_otp_session')

          declared_params = declared(params)

          validate_signature?('resent') if request.headers['X-App-Auth-Token']

          return 201 unless request_from_app?

          user = if params[:phone_number].present?
                   identifier = 'phone'
                   phone_number = Phone.international(declared_params[:phone_number])
                   validate_phone!(phone_number)
                   User.find_by(phone_number: phone_number)
                 elsif params[:username].present?
                   identifier = 'username'
                   User.find_by(username: params[:username])
                 else
                   identifier = 'email'
                   User.find_by(email: params[:email])
                 end

          unless user
            Barong::AwsPinpoint::PhoneValidate.validate(phone_number) if identifier == 'phone'
            error!({ errors: ['identity.session.not_found'] }, 404)
          end

          validate_user(user)

          # ::hotfix: for old ios version
          if user.password_enabled? && (app_version('ios').nil? || app_version('ios').to_f >= 1.3)
            error!({ errors: ['identity.user.password.enabled'] }, 401)
          end

          # Disable login for those users who has done their singup from mobile
          # and hasn't verified their email yet. So they can verify the email on the
          # mobile app only.
          # validate_app_user(user) if %w[email username].include?(identifier)

          if params[:reactive_account]
            user.social_media_status = 'active'
            user.save!
            activity_record(user: user.id, action: 'reactivate social login', result: 'succeed', topic: 'session')
          elsif params[:platform] == 'app'
            error!({ errors: ["identity.conflict.#{user.social_media_status}"] }, 409) unless user.social_media_status == 'active'
          end

          identifier = otp_channel(user) if identifier == 'phone'

          present public_send("send_#{identifier}_otp", user,
                              { action: "sent message to user's #{identifier}", topic: 'session' })
        rescue Barong::AwsPinpoint::PhoneValidate::InvalidPhoneNumberError => e
          Rails.logger.error { "Error: Invalid phone number #{e.inspect}" }
          error!({ errors: ['identity.users.invalid_phone_number'] }, 422)
        rescue StandardError => e
          Rails.logger.error e.inspect
          error!(e.message, 422)
        end

        desc 'Verify user otp and generate jwt session',
             success: { code: 200, message: 'User authorization' },
             failure: [
               { code: 400, message: 'Required params are empty' },
               { code: 404, message: 'Record is not found' }
             ]
        params do
          optional :phone_number,
                   type: String,
                   desc: 'Phone number with country code'
          optional :email,
                   type: String,
                   desc: 'Registered email address'
          optional :username,
                   type: String,
                   desc: 'User\'s username'
          requires :verification_code,
                   type: String,
                   allow_blank: false,
                   desc: 'Verification code from sms'
          requires :platform,
                   type: String,
                   values: { value: -> { %w[icx zen explorer nft app] },
                             message: 'identity.platform.invalid_platform'},
                   desc: 'User login platform'
          optional :login_device, type: Hash do
            requires :device_id,
                     type: String,
                     desc: 'User device id'
            requires :device_type,
                     type: String,
                     default: 'web',
                     desc: 'User device type Android/IOS'
            optional :device_token,
                     type: String,
                     desc: 'User fcm device token Android/IOS'
          end
          at_least_one_of :phone_number, :email, :username, message: 'resource.identity.invalid_parameter'
        end
        post '/verify' do
          declared_params = declared(params)
          labels = []
          request_from = 'email'
          user = if declared_params[:phone_number].present?
                   request_from = 'phone'
                   phone_number = Phone.international(declared_params[:phone_number])
                   validate_phone!(phone_number)
                   User.find_by_phone_number(phone_number)
                 elsif params[:username].present?
                   User.find_by(username: params[:username])
                 else
                   User.find_by_email(declared_params[:email])
                 end
          error!({ errors: ['identity.session.not_found'] }, 404) unless user

          validate_user(user)

          request_from = otp_channel(user) if request_from == 'phone'

          expired, verify = if request_from == 'email'
                              [user.code_expiry_date >= Time.now,
                               PlatformSetting.verify_service(user.phone_number, request_from).verify_email_user?(
                                 code: declared_params[:verification_code], user: user
                               )]
                            else
                              [user.phone_code_expiry_date >= Time.now,
                               PlatformSetting.verify_service(user.phone_number).verify_phone_user?(
                                 code: declared_params[:verification_code], user: user
                               )]
                            end
          error!({ errors: ['resource.session.code_is_expired'] }, 422) unless expired

          unless user.role == 'mock'
            error!({ errors: ['resource.session.verification_invalid'] }, 401) unless verify
          end

          if request_from == 'email'
            user.update(code_expiry_date: 1.minute.ago(Time.now),
                        time_before_resend: 1.minute.ago(Time.now))
            user.update_label('login_email')
          else
            user.update(phone_code_expiry_date: 1.minute.ago(Time.now),
                        phone_time_before_resend: 1.minute.ago(Time.now),
                        phone_resend_counter: 0)
            user.update_label('login_phone')
          end

          if user.state == 'pending'
            user.update_label('social', status: 'created')
            user.update_label('email')
          end

          if declared_params[:platform] == 'app'
            error!({ errors: ["identity.conflict.#{user.social_media_status}"] }, 409) unless user.social_media_status == 'active'

            create_session(user)
          else
            csrf_token = open_session(user)
            publish_session_create(user) if declared_params[:platform] == 'icx'
          end

          update_device(user, params[:login_device])

          present user, with: API::V2::Entities::UserWithPhone, csrf_token: csrf_token
          status(200)
        rescue StandardError => e
          Rails.logger.error e.inspect
          error!(e.message, 422)
        end

        desc 'Refresh user\'s jwt session token',
             success: { code: 200, message: 'User\'s JWT token refreshed successfully.' },
             failure: [
               { code: 400, message: 'Required params are empty' },
               { code: 404, message: 'Record is not found' }
             ]
        params do
          optional :refresh_token,
                   type: String,
                   allow_blank: false,
                   desc: 'JWT Refresh token'
        end
        post '/refresh' do
          authorize_by_refresh_header!

          token   = codec.decode_token(found_token, Barong::App.config.keystore.public_key)
          user    = User.find_by_uid(token[:uid])
          error!({ errors: ['identity.session.not_found'] }, 404) unless user

          payload = codec.merge_claims(user.jwt_payload).except(:iat, :exp)
          tokens  = Barong::JWTSession::Session.renew_session(token, payload)

          header['access-token']   = tokens[:access]
          header['access-expire']  = tokens[:access_expires_at]
          header['refresh-token']  = tokens[:refresh]
          header['refresh-expire'] = tokens[:refresh_expires_at]

          present user, with: API::V2::Entities::UserWithPhone
          status(200)
        end

        desc 'Destroy current session with jwt refresh token',
             failure: [
               { code: 400, message: 'Required params are empty' },
               { code: 404, message: 'Record is not found' }
             ],
             success: { code: 200, message: 'Session was destroyed' }
        params do
          optional :device_id,
                   type: String,
                   desc: 'User device id'
          optional :device_type,
                   type: String,
                   default: 'web',
                   desc: 'User device type Android/IOS'
        end
        delete '/refresh' do
          authorize_by_refresh_header!

          token   = codec.decode_token(found_token, Barong::App.config.keystore.public_key)
          user    = User.find_by_uid(token[:uid])
          error!({ errors: ['identity.session.not_found'] }, 404) unless user

          session = JWTSessions::Session.new
          session.flush_by_uuid(token[:uuid])

          if params[:device_id]
            device = user.devices.active.find_by(device_id: params[:device_id], device_type: params[:device_type])
            if device.present?
              device.update(active: false)

              notify_session_destroy(user.uid, 'logout')
            end
          end

          activity_record(user: user.id, action: 'logout', result: 'succeed', topic: 'session')

          status(200)
        end

        # :: TODO: Remove me in future, if not needed.
        # desc 'Auth0 authentication by id_token',
        #      success: { code: 200, message: 'User authenticated' },
        #      failure: [
        #        { code: 400, message: 'Required params are empty' },
        #        { code: 404, message: 'Record is not found' }
        #      ]
        # params do
        #   requires :id_token,
        #            type: String,
        #            allow_blank: false,
        #            desc: 'ID Token'
        # end
        # post '/auth0' do
        #   begin
        #     # Decode ID token to get user info
        #     claims = Barong::Auth0::JWT.verify(params[:id_token]).first
        #     error!({ errors: ['identity.session.auth0.invalid_params'] }, 401) unless claims.key?('email')
        #     user = User.find_by(email: claims['email'])
        #
        #     # If there is no user in platform and user email verified from id_token
        #     # system will create user
        #     if user.blank? && claims['email_verified']
        #       user = User.create!(email: claims['email'], state: 'active')
        #       user.labels.create!(scope: 'private', key: 'email', value: 'verified')
        #     elsif claims['email_verified'] == false
        #       error!({ errors: ['identity.session.auth0.invalid_params'] }, 401) unless user
        #     end
        #
        #     activity_record(user: user.id, action: 'login', result: 'succeed', topic: 'session')
        #     csrf_token = open_session(user)
        #     publish_session_create(user)
        #
        #     present user, with: API::V2::Entities::UserWithFullInfo, csrf_token: csrf_token
        #   rescue StandardError => e
        #     report_exception(e)
        #     error!({ errors: ['identity.session.auth0.invalid_params'] }, 422)
        #   end
        # end
      end
    end
  end
end
