# frozen_string_literal: true

require_dependency 'barong/jwt'

module API::V2
  module Identity
    class Users < Grape::API
      helpers do

        # @deprecated
        def parse_refid!
          error!({ errors: ['identity.user.invalid_referral_format'] }, 422) unless params[:refid].start_with?(Barong::App.config.uid_prefix.upcase)
          user = User.find_by_uid(params[:refid])
          error!({ errors: ['identity.user.referral_doesnt_exist'] }, 422) if user.nil?

          user.id
        end

        def parse_referral_code!
          user = User.find_by_referral_code(params[:referral_code])
          error!({ errors: ['identity.user.referral_doesnt_exist'] }, 422) if user.nil?

          user.id
        end

        def validate_user!(phone_number, params)
          user = User.find_by('email = ? or phone_number = ?', params['email'], phone_number)
          return if user.nil?

          error!({ errors: ['identity.user.is_pending'] }, 422) if user.state == 'pending'

          if user.state == 'banned'
            login_error!(reason: 'Your account is banned', error_code: 401,
                         user: user.id, action: 'login', result: 'failed', error_text: 'banned')
          end

          if user.state == 'deleted'
            login_error!(reason: 'Your account is deleted', error_code: 401,
                         user: user.id, action: 'login', result: 'failed', error_text: 'deleted')
          end

          if params[:email].present?
            label = user.labels.find_or_initialize_by(key: 'login_email', scope: 'private')
            unless label.value == 'pending' || label.value.to_s == ''
              error!({ errors: ['identity.user.already_registered'] }, 422)
            end
          else
            error!({ errors: ['identity.user.already_registered'] }, 422) if user.state == 'active'
          end
          user
        end

        def validate_username!(username)
          user = User.find_by(username: username)
          if user&.state == 'active'
            error!({ errors: ['username.taken'] }, 422)
          elsif user&.state == 'pending'
            user.update(username: user.send(:generate_username))
          end
        end
      end

      desc 'User related routes'
      resource :users do

        desc 'Creates new user',
          success: API::V2::Entities::UserWithPhone,
          failure: [
            { code: 400, message: 'Required params are missing' },
            { code: 422, message: 'Validation errors' }
          ]
        params do
          requires :email,
                   type: String,
                   allow_blank: false,
                   desc: 'User Email'
          optional :first_name,
                   type: String,
                   values: { value: -> (v){ v.length <= 70 }, message: 'identity.first_name.too_long' },
                   desc: 'User\'s first name'
          optional :last_name,
                   type: String,
                   values: { value: -> (v){ v.length <= 35 }, message: 'identity.last_name.too_long' },
                   desc: 'User\'s last name'
          optional :referral_code,
                   type: String,
                   desc: 'User\'s referral code'
          optional :captcha_response,
                   types: [String, Hash],
                   desc: 'Response from captcha widget'
          optional :client_id,
                   types: String,
                   desc: 'Unique client id.'
          requires :password,
                   type: String,
                   message: 'identity.user.missing_password',
                   allow_blank: false,
                   desc: 'User\'s password'
          requires :role,
                   type: String,
                   values: { value: -> { User::ROLE }, message: 'identity.user.invalid_role'},
                   desc: 'User\'s role'
        end
        post '/new' do
          verify_captcha!(response: params['captcha_response'], endpoint: 'user_create')

          declared_params = declared(params, include_missing: false)

          client = if declared_params[:client_id]
                     RegisteredClient.active.find_by(kid: declared_params[:client_id])&.name
                   end

          unless SendgridService.validate_email!(declared_params[:email], source: 'Signup via Phone or Email')
            error!({ errors: ['identity.users.invalid_email'] }, 422)
          end

          old_user = validate_user!(nil, params)

          user_params = declared_params.slice('email', 'first_name', 'last_name', 'password', 'role')

          user_params[:referral_id] = parse_referral_code! unless params[:referral_code].blank?

          user = User.new(user_params.merge(password_enabled: true, platform: client))

          ActiveRecord::Base.transaction do
            old_user.update(email: "#{'pending_user_'}#{SecureRandom.hex(7)}@blockmaze.network",
                            older_email: old_user.email) if old_user.present?

            code_error!(user.errors.details, 422) unless user.save

          end

          user.profiles.create(first_name: user_params['first_name'],
                               last_name: user_params['last_name'],
                               state: 'social')
          activity_record(user: user.id, action: 'signup', result: 'succeed', topic: 'account')


          user.labels.create(key: 'login_email', value: 'pending', scope: 'private')
          user.set_code
          publish_otp_confirmation(user, Barong::App.config.otp_domain)

          present user, with: API::V2::Entities::UserWithPhone
        end

        desc 'Register Geetest captcha'
        get '/register_geetest' do
          CaptchaService::GeetestVerifier.new.register
        end

        namespace :username do
          desc 'Check if user is available with the username'
          params do
            requires :username,
                     type: String,
                     allow_blank: false,
                     regexp: { value: /\A[[:word:]_.]+\z/, message: 'Username is invalid' },
                     desc: 'User\'s Username'
          end
          get '/available' do
            user = User.active.find_by_username(params[:username])
            error!({ errors: ['identity.user.username_doesnt_exist_or_invalid'] }, 404) if user.nil?

            status 201
          end

          desc 'Check referral code through username'
          params do
            requires :username,
                     type: String,
                     allow_blank: false,
                     values: { value: ->(v) { v.length > 4}, message: 'username.length.not_valid'},
                     regexp: { value: /\A[[:word:]_.]+\z/, message: 'Username is invalid' },
                     desc: 'User\'s Username'
          end
          get '/referral' do
            user = User.find_by_username(params[:username])
            error!({ errors: ['identity.user.username_does_not_exists'] }, 422) if user.nil?

            present user, with: API::V2::Entities::ReferralCode
            status 201
          end
        end

        namespace :email do
          desc 'Send confirmations instructions',
            success: { code: 201, message: 'Generated verification code' },
            failure: [
              { code: 400, message: 'Required params are missing' },
              { code: 422, message: 'Validation errors' }
            ]
          params do
            requires :email,
                     type: String,
                     allow_blank: false,
                     desc: 'Account email'
            optional :captcha_response,
                     types: [String, Hash],
                     desc: 'Response from captcha widget'
          end
          post '/generate_code' do
            verify_captcha!(response: params['captcha_response'], endpoint: 'email_confirmation')

            current_user = User.find_by_email(params[:email])

            if current_user.nil? || current_user.active?
              return status 201
            end

            publish_confirmation(current_user, Barong::App.config.domain)
            status 201
          end

          desc 'Confirms an account',
            success: API::V2::Entities::UserWithFullInfo,
            failure: [
              { code: 400, message: 'Required params are missing' },
              { code: 422, message: 'Validation errors' }
            ]
          params do
            requires :token,
                     type: String,
                     allow_blank: false,
                     desc: 'Token from email'
          end
          post '/confirm_code' do
            payload = codec.decode_and_verify(
              params[:token],
              pub_key: Barong::App.config.keystore.public_key,
              sub: 'confirmation'
            )
            current_user = User.find_by_email(payload[:email])

            if current_user.nil? || current_user.active?
              error!({ errors: ['identity.user.active_or_doesnt_exist'] }, 422)
            end

            if token_uniq?(payload[:jti])
              current_user.labels.create!(key: 'email', value: 'verified', scope: 'private')
              label = current_user.labels.find_or_initialize_by(key: 'login_email', scope: 'private')
              label.update(value: 'verified')
            end

            csrf_token = open_session(current_user)

            EventAPI.notify('system.user.email.confirmed',
                            record: {
                              user: current_user.as_json_for_event_api,
                              domain: Barong::App.config.domain
                            })

            present current_user, with: API::V2::Entities::UserWithFullInfo, csrf_token: csrf_token
          end
        end

        namespace :password do
          desc 'Send password reset instructions',
            success: { code: 201, message: 'Generated password reset code' },
            failure: [
              { code: 400, message: 'Required params are missing' },
              { code: 422, message: 'Validation errors' },
              { code: 404, message: 'User doesn\'t exist'}
            ]
          params do
            requires :email,
                     type: String,
                     desc: 'User\'s email or username'
            optional :captcha_response,
                     types: [String, Hash],
                     desc: 'Response from captcha widget'
            optional :platform,
                     type: String,
                     desc: 'User login platform'
          end
          post '/generate_code' do
            verify_captcha!(response: params['captcha_response'], endpoint: 'password_reset')

            current_user = get_user(params)

            if current_user.nil? || (current_user.state == 'pending' && current_user.social_media_status == 'active')
              error!({ errors: ['identity.session.invalid_params'] }, 422)
            end

            label = current_user.labels.find_by(key: 'login_email')
            error!({ errors: ['identity.email.not_active'] }, 422) unless label&.value.to_s == 'verified'

            reset_token = SecureRandom.hex(10)
            token = codec.encode(sub: 'reset', email: current_user.email, uid: current_user.uid, reset_token: reset_token)
            # save reset_password_id in cache to validate as latest requested
            Rails.cache.write("reset_password_#{current_user.email}", reset_token, expires_in: Barong::App.config.jwt_expire_time.seconds)

            activity_record(user: current_user.id, action: 'request password reset', result: 'succeed', topic: 'password')

            EventAPI.notify('system.user.password.reset.token',
                            record: {
                              user: current_user.as_json_for_event_api,
                              domain: Barong::App.config.domain,
                              token: token,
                              platform: params[:platform]
                            })
            status 201
          end

          desc 'Sets new account password',
            success: { code: 201, message: 'Resets password' },
            failure: [
              { code: 400, message: 'Required params are empty' },
              { code: 404, message: 'Record is not found' },
              { code: 422, message: 'Validation errors' }
            ]
          params do
            requires :reset_password_token,
                     type: String,
                     message: 'identity.user.missing_pass_token',
                     allow_blank: false,
                     desc: 'Token from email'
            requires :password,
                     type: String,
                     message: 'identity.user.missing_password',
                     allow_blank: false,
                     desc: 'User password'
            requires :confirm_password,
                     type: String,
                     message: 'identity.user.missing_confirm_password',
                     allow_blank: false,
                     desc: 'User password'
          end
          post '/confirm_code' do
            unless params[:password] == params[:confirm_password]
              error!({ errors: ['identity.user.passwords_doesnt_match'] }, 422)
            end

            payload = codec.decode_and_verify(
              params[:reset_password_token],
              pub_key: Barong::App.config.keystore.public_key, sub: 'reset'
            )

            # check if reset_password token is latest requested and was not used before
            if Rails.cache.read("reset_password_#{payload[:email]}") != payload[:reset_token] || Rails.cache.read(payload[:jti]) == 'utilized'
              error!({ errors: ['identity.user.utilized_token'] }, 422)
            end

            current_user = User.find_by_email(payload[:email])

            unless current_user.update(password: params[:password], password_reset_at: Time.now, password_enabled: true)
              error_note = { reason: current_user.errors.full_messages.to_sentence }.to_json
              activity_record(user: current_user.id, action: 'password reset',
                              result: 'failed', topic: 'password', data: error_note)
              code_error!(current_user.errors.details, 422)
            end

            # remove latest token id cache record
            Rails.cache.delete("reset_password_#{params[:email]}")
            # invalidate token used
            Rails.cache.write(payload[:jti], 'utilized', expires_in: Barong::App.config.jwt_expire_time.seconds)

            activity_record(user: current_user.id, action: 'password reset', result: 'succeed', topic: 'password')

            EventAPI.notify('system.user.password.reset',
                            record: {
                              user: current_user.as_json_for_event_api,
                              domain: Barong::App.config.domain
                            })
            status 201
          end

          desc 'Reset account password',
               success: { code: 201, message: 'Code was sent successfully via sms/call.' },
               failure: [
                          { code: 400, message: 'Required params are missing' },
                          { code: 422, message: 'Validation errors' }
                        ]
          params do
            optional :phone_number,
                     type: String,
                     desc: 'User Phone Number'
            optional :email,
                     type: String,
                     desc: 'User email'
            optional :channel,
                     type: String,
                     default: 'sms',
                     values: { value: -> { Phone::TWILIO_CHANNELS }, message: 'resource.phone.invalid_channel'},
                     desc: 'The verification method to use'
            optional :captcha_response,
                     types: [String, Hash],
                     desc: 'Response from captcha widget'
            exactly_one_of :phone_number, :email, message: 'resource.identity.invalid_parameter'
          end
          post '/send-otp' do
            verify_captcha!(response: params['captcha_response'], endpoint: 'password_reset')

            user = if params[:phone_number].present?
                     identifier = 'phone'
                     phone_number = Phone.international(params[:phone_number])
                     validate_phone!(phone_number)
                     User.find_by(phone_number: phone_number)
                   else
                     identifier = 'email'
                     User.find_by(email: params[:email])
                   end

            if user.nil? || (user.state == 'pending' && user.social_media_status == 'active')
              error!({ errors: ['identity.session.not_found'] }, 422)
            end

            if identifier == 'email'
              label = user.labels.find_by(key: 'login_email')
              error!({ errors: ['identity.email.not_active'] }, 422) unless label&.value.to_s == 'verified'
            end

            public_send("send_#{identifier}_otp", user,
                        { action: "request password reset with #{identifier}",
                          topic: 'password' })
          rescue => e
            Rails.logger.error e.inspect
            error!({ errors: ['identity.user.password.reset_error'] }, 422)
          end

          desc 'Set new account password through phone number',
               success: { code: 201, message: 'Reset password' },
               failure: [
                          { code: 400, message: 'Required params are empty' },
                          { code: 404, message: 'Record is not found' },
                          { code: 422, message: 'Validation errors' }
                        ]
          params do
            optional :phone_number,
                     type: String,
                     desc: 'User Phone Number'
            optional :email,
                     type: String,
                     desc: 'User email'
            requires :password,
                     type: String,
                     allow_blank: false,
                     desc: 'User password'
            requires :confirm_password,
                     type: String,
                     allow_blank: false,
                     desc: 'User password'
            requires :verification_otp,
                     type: String,
                     allow_blank: false,
                     desc: 'Verification code from email'
            exactly_one_of :phone_number, :email, message: 'resource.identity.invalid_parameter'
          end
          post '/reset' do
            unless params[:password] == params[:confirm_password]
              error!({ errors: ['identity.user.passwords_doesnt_match'] }, 422)
            end

            user = if params[:phone_number].present?
                     identifier = 'phone'
                     phone_number = Phone.international(params[:phone_number])
                     validate_phone!(phone_number)
                     User.find_by(phone_number: phone_number)
                   else
                     identifier = 'email'
                     User.find_by(email: params[:email])
                   end

            if user.nil? || (user.state == 'pending' && user.social_media_status == 'active')
              error!({ errors: ['identity.session.not_found'] }, 422)
            end

            if identifier == 'email'
              label = user.labels.find_by(key: 'login_email')
              error!({ errors: ['identity.email.not_active'] }, 422) unless label&.value.to_s == 'verified'
            end

            expired, verify = if identifier == 'email'
                                [user.code_expiry_date >= Time.now,
                                 PlatformSetting.verify_service(user.phone_number, identifier).verify_email_user?(
                                   code: params[:verification_otp], user: user
                                 )]
                              else
                                [user.phone_code_expiry_date >= Time.now,
                                 PlatformSetting.verify_service(user.phone_number).verify_phone_user?(
                                   code: params[:verification_otp], user: user
                                 )]
                              end
            error!({ errors: ['identity.user.code_is_expired'] }, 422) unless expired

            unless user.role == 'mock'
              error!({ errors: ['identity.user.verification_invalid'] }, 401) unless verify
            end

            if identifier == 'email'
              user.update(code_expiry_date: 1.minute.ago(Time.now),
                          time_before_resend: 1.minute.ago(Time.now))
            else
              user.update(phone_code_expiry_date: 1.minute.ago(Time.now),
                          phone_time_before_resend: 1.minute.ago(Time.now),
                          phone_resend_counter: 0)
            end

            unless user.update!(password: params[:password], password_enabled: true, password_reset_at: Time.now)
              error_note = { reason: user.errors.full_messages.to_sentence }.to_json
              activity_record(user: user.id, action: "password reset with #{identifier}",
                              result: 'failed', topic: 'password', data: error_note)
              code_error!(user.errors.details, 422)
            end

            activity_record(user: user.id, action: "password reset with #{identifier}", result: 'succeed', topic: 'password')

            status 201
          rescue StandardError => e
            Rails.logger.error e
            error!(e.message, 422)
          end
        end

        desc 'Check user existence through email.'
        params do
          requires :email,
                   type: String,
                   allow_blank: false,
                   desc: 'User Email'
          optional :platform,
                   type: String,
                   values: { value: -> { ::User::PLATFORM },
                             message: 'identity.platform.invalid_platform'},
                   default: 'app',
                   desc: 'User Signup platform'
          requires :device_id,
                   type: String,
                   desc: 'User device id'
          requires :device_type,
                   type: String,
                   default: 'web',
                   desc: 'User device type Android/IOS'
        end
        get '/exists' do
          validate_signature?('singup')

          return 201 unless request_from_app?

          unless SendgridService.validate_email!(params[:email])
            error!({ errors: ['identity.users.invalid_email'] }, 422)
          end

          error!({ errors: ['email.undisposable'] }, 422) if disposable_email?(params[:email])

          user = User.find_by(email: params[:email])

          if user.present?
            label = user.labels.find_or_initialize_by(key: 'login_email', scope: 'private')
            label.update(value: 'pending') if label.value.blank?

            if user.state == 'pending' || label.value == 'pending'
              error!({ errors: ['identity.user.not_verified'] }, 422)
            end

            error!({ errors: ['identity.users.already_registered'] }, 422)
          end

          status 200
        end

        desc 'Check user existence through referral code.'
        params do
          requires :referral_code,
                   type: String,
                   desc: 'User\'s referral code'
        end
        get 'referral/exists' do
          user = User.find_by(referral_code: params[:referral_code], state: 'active')
          error!({ errors: ['identity.user.not_found'] }, 404) unless user

          if user.created_at < Time.at(Barong::App.config.users_valid_from)
            error!({ errors: ['identity.user.not_valid'] }, 422)
          end

          status 200
        end
      end
    end
  end
end
