# frozen_string_literal: true

module API::V2
  module Resource
    class Users < Grape::API
      helpers ::API::V2::NamedParams
      helpers ::API::V2::Resource::Validations

      helpers do
        def password_error!(options = {})
          options[:topic] = 'password'
          record_error!(options)
        end

        def validate_topic!(topic)
          unless %w[all session otp password account].include?(topic)
            error!({ errors: ['resource.user.wrong_topic'] }, 422)
          end
        end

        def verify_otp!
          error!({ errors: ['resource.user.missing_otp_code'] }, 422) if params[:otp_code].nil?

          error!({ errors: ['resource.user.empty_otp_code'] }, 422) if params[:otp_code].empty?

          error!({ errors: ['resource.user.invalid_otp'] }, 422) unless TOTPService.validate?(current_user.uid, params[:otp_code])
        end
      end

      resource :users do
        desc 'Returns current user',
          success: API::V2::Entities::UserWithFullInfo
        get '/me' do
          present current_user, with: API::V2::Entities::UserWithFullInfo
        end

        desc 'Returns current user',
          success: API::V2::Entities::UserWithPhone
        get '/info' do
          present current_user, with: API::V2::Entities::UserWithPhone
        end

        #TODO:: Remove me as there is no need for this API
        # desc 'Updates current user data field',
        #   success: API::V2::Entities::UserWithFullInfo
        # params do
        #   requires :data, type: String, allow_blank: false, desc: 'Any additional key: value pairs in json string format'
        # end
        # put '/me' do
        #   code_error!(current_user.errors.details, 422) unless current_user.update(data: params[:data])
        #
        #   present current_user, with: API::V2::Entities::UserWithFullInfo
        # end

        desc 'Blocks current user',
          success: { code: 200, message: 'Current user was blocked' }
        params do
          requires :password, type: String, allow_blank: false, desc: 'Account password'
          optional :otp_code, type: String, allow_blank: false, desc: 'Code from Google Authenticator'
        end
        delete '/me' do
          error!({ errors: ['resource.user.invalid_password'] }, 422) unless password_valid?(params[:password])

          verify_otp! if current_user.otp

          current_user.labels.create(key: 'delete', value: 'by_user', scope: 'private')
          EventAPI.notify(
            'system.user.account.deleted',
            record: { user: current_user.as_json_for_event_api }
          )

          status(200)
        end

        desc 'Returns user activity',
          success: Entities::Activity
        params do
          requires :topic,
                   type: String,
                   allow_blank: { value: false, message: 'resource.user.empty_topic' },
                   desc: 'Topic of user activity. Allowed: [all, password, session, otp]'
          optional :time_from,
                   type: { value: Time, message: 'resource.user.non_integer_time_from' },
                   allow_blank: { value: false, message: 'resource.user.empty_time_from' },
                   desc: "An integer represents the seconds elapsed since Unix epoch."\
                         "If set, only activities created after the time will be returned."
          optional :time_to,
                   type: { value: Time, message: 'resource.user.non_integer_time_to' },
                   allow_blank: { value: false, message: 'resource.user.empty_time_to' },
                   desc: "An integer represents the seconds elapsed since Unix epoch."\
                         "If set, only activities created before the time will be returned."
          optional :result,
                   type: { value: String, message: 'resource.user.non_string_result' },
                   allow_blank: { value: false, message: 'resource.user.empty_result' },
                   desc: "Result of user activity. Allowed: [succeed, failed, denied]"
          use :pagination_filters
        end
        get '/activity/:topic' do
          validate_topic!(params[:topic])
          data = current_user.activities.order('id DESC')
          data = data.where(topic: params[:topic]) if params[:topic] != 'all'
          data = data.tap { |q| q.where!('created_at >= ?', params[:time_from]) if params[:time_from] }
                     .tap { |q| q.where!('created_at < ?', params[:time_to]) if params[:time_to] }
                     .tap { |q| q.where!(result: params[:result]) if params[:result] }

          error!({ errors: ['resource.user.no_activity'] }, 422) unless data.present?

          present paginate(data), with: Entities::Activity
        end

        desc 'Sets new account password',
          success: { code: 201, message: 'Changes password' },
          failure: [
            { code: 400, message: 'Required params are empty' },
            { code: 404, message: 'Record is not found' },
            { code: 422, message: 'Validation errors' }
          ]
        params do
          requires :old_password,
                   type: String,
                   allow_blank: false,
                   desc: 'Previous account password'
          requires :new_password,
                   type: String,
                   allow_blank: false,
                   desc: 'User password'
          requires :confirm_password,
                   type: String,
                   allow_blank: false,
                   desc: 'User password'
        end
        put '/password' do
          unless params[:new_password] == params[:confirm_password]
            password_error!(reason: 'New passwords don\'t match',
              error_code: 422, user: current_user.id, action: 'password change', error_text: 'doesnt_match')
          end

          unless password_valid?(params[:old_password])
            password_error!(reason: 'Previous password is not correct',
              error_code: 400, user: current_user.id, action: 'password change', error_text: 'prev_pass_not_correct')
          end

          if params[:old_password] == params[:new_password]
            password_error!(reason: 'New password cant be the same, as old one',
              error_code: 400, user: current_user.id, action: 'password change', error_text: 'no_change_provided')
          end

          unless current_user.update(password: params[:new_password], password_reset_at: Time.now)
            error_note = { reason: current_user.errors.full_messages.to_sentence }.to_json
            activity_record(user: current_user.id, action: 'password change',
                            result: 'failed', topic: 'password', data: error_note)
            code_error!(current_user.errors.details, 422)
          end

          activity_record(user: current_user.id, action: 'password change', result: 'succeed', topic: 'password')

          EventAPI.notify('system.user.password.change',
                          record: {
                            user: current_user.as_json_for_event_api,
                            domain: Barong::App.config.domain
                          })
          status 201
        end

        desc 'Sets new account password',
             success: { code: 201, message: 'set password' },
             failure: [
               { code: 400, message: 'Required params are empty' },
               { code: 404, message: 'Record is not found' },
               { code: 422, message: 'Validation errors' }
             ]
        params do
          requires :password,
                   type: String,
                   allow_blank: false,
                   desc: 'User password'
          requires :confirm_password,
                   type: String,
                   allow_blank: false,
                   desc: 'User password'
        end
        post '/set-password' do
          error!({ errors: ['resource.user.password_enabled'] }, 422) if current_user.password_enabled?

          unless params[:password] == params[:confirm_password]
            error!({ errors: ['resource.user.passwords_doesnt_match'] }, 422)
          end

          unless current_user.update!(password: params[:password], password_enabled: true, password_reset_at: Time.now)
            error_note = { reason: current_user.errors.full_messages.to_sentence }.to_json
            activity_record(user: current_user.id, action: 'set password',
                            result: 'failed', topic: 'password', data: error_note)
            code_error!(current_user.errors.details, 422)
          end

          activity_record(user: current_user.id, action: 'set password', result: 'succeed', topic: 'password')

          status 201
        rescue StandardError => e
          Rails.logger.error e
          error!(e.message, 422)
        end

        desc 'Api for first login Activity',
             success: { code: 201, message: 'Confirms an account' },
             failure: [
               { code: 400, message: 'Required params are missing' },
               { code: 422, message: 'Validation errors' }
             ]
        params do
          requires :search,
                   type: String,
                   message: 'identity.user.missing_search',
                   allow_blank: false,
                   desc: 'activity of user'
        end
        get '/user_activity' do
          present current_user.activities.find_by(action: params[:search]),
                  with: API::V2::Admin::Entities::ActivityWithUser
        end

        desc 'update user\'s details',
             success: API::V2::Entities::UserWithPhone,
             failure: [
               { code: 400, message: 'Required params are missing' },
               { code: 422, message: 'Validation errors' }
             ]
        params do
          optional :first_name,
                   type: String,
                   values: { value: -> (v){ v.length <= 70 }, message: 'identity.first_name.too_long' },
                   desc: 'User\'s first name'
          optional :last_name,
                   type: String,
                   values: { value: -> (v){ v.length <= 35 }, message: 'identity.last_name.too_long' },
                   desc: 'User\'s last name'
          optional :username,
                   type: String,
                   values: { value: -> (v){ v.length <= 30 }, message: 'identity.username.too_long' },
                   desc: 'User\'s username'
          optional :dob,
                   type: String,
                   desc: 'User\'s date of Birth'
          optional :role,
                   type: String,
                   values: { value: -> { %w[issuer] }, message: 'identity.user.invalid_role'},
                   desc: 'User\'s role'
          requires :client_id,
                   types: String,
                   desc: 'Unique client id.'
        end
        post '/update' do
          client = verify_client!

          params[:secret] = client.secret

          validate_signature?('user_update')

          declared_params = declared(params, include_missing: false)
          user_params = declared_params.slice('username', 'first_name', 'last_name')

          if params[:username]
            user = User.find_by('username=? and not id=?', user_params[:username], current_user.id)
            if user&.state == 'active'
              error!({ errors: ['username.taken'] }, 422)
            elsif user&.state == 'pending'
              email      = user.email
              username   = user.send(:generate_username)
              user.email = email
              user.update(username: username)
            end
          end

          user = current_user
          unless user.update(user_params)
            code_error!(user.errors.details, 422)
          end

          current_user.social_profile.update!(first_name: declared_params['first_name'],
                                               last_name: declared_params['last_name'],
                                               dob: declared_params['dob'],
                                               state: 'social')

          activity_record(user: current_user.id, action: 'update', result: 'succeed', topic: 'user')
          present current_user, with: API::V2::Entities::UserWithPhone
        rescue => e
          Rails.logger.error e
          error!({ errors: ["resource.user.update_error"] }, 422)
        end

        desc 'Upload a new profile picture for current user',
             success: { code: 201, message: 'Profile picture is uploaded' },
             failure: [
               { code: 400, message: 'Required params are empty' },
               { code: 401, message: 'Invalid bearer token' },
               { code: 422, message: 'Validation errors' }
             ]
        params do
          requires :upload,
                   allow_blank: false,
                   desc: 'Array of Rack::Multipart::UploadedFile'
          use :dimensions
        end
        post '/media' do
          file = if params[:upload]['data:image/png;base64,'.length..-1].present?
                   Media.generate_file(params)
                 end

          media = current_user.medias.new(upload: file || params[:upload],
                                          type: 'default', state: 'inactive')
          code_error!(media.errors.details, 422) unless media.save!

          File.delete(file.to_path) if file && File.exist?(file.to_path)
          media.create_versions(params)

          moderation = Barong::Moderation::ImageModeration.image(media.upload.path)

          media.update(moderation_score: moderation[:avg_confidence],
                       moderation_metadata: moderation[:reasons])

          if moderation[:avg_confidence].to_f >= Barong::App.config.avatar_allowed_moderation_min_confidence.to_f
            error!({ errors: ['users.media.moderation_check_failed'] }, 422)
          else
            media.update!(state: 'active')
            status 201
          end
        rescue StandardError => e
          Rails.logger.error e.inspect
          error!('resource.media.create_error', 422)
        end

        desc 'Remove profile picture for current user',
             success: { code: 200, message: 'Profile picture is removed' },
             failure: [
               { code: 400, message: 'Required params are empty' },
               { code: 401, message: 'Invalid bearer token' },
               { code: 422, message: 'Validation errors' }
             ]
        delete '/remove_media' do
          current_user.medias.find_by(state: 'active')&.update!(state: 'inactive')
          status 200

        rescue => e
          Rails.logger.error e.inspect
          error!('resource.media.update_error', 422)
        end

        desc 'Update profile picture for current user',
             success: { code: 201, message: 'Profile picture is uploaded' },
             failure: [
               { code: 400, message: 'Required params are empty' },
               { code: 401, message: 'Invalid bearer token' },
               { code: 422, message: 'Validation errors' }
             ]
        params do
          requires :media_id,
                   desc: 'Unique ID of media.'
        end
        put '/update_media' do
          media = current_user.medias.find_by(id: params[:media_id])
          current_user.medias.find_by(state: 'active').update!(state: 'inactive')
          media.update!(state: 'active')
          status 201

        rescue Excon::Error => e
          Rails.logger.error e
          error!('Connection error', 422)
        end

        desc 'Update member status.'
        params do
          requires :status,
                   type: String,
                   values: { value: -> { ::User::STATE.map(&:to_s).drop(1) },
                             message: 'user.update.invalid_status' },
                   desc: 'member status'
        end
        post '/update_status' do
          current_user.update(social_media_status: params[:status], status_updated_at: Time.now)
          activity_record(user: current_user.id,
                          action: "request account #{current_user.social_media_status}",
                          result: 'succeed',
                          topic: 'account')

          if params[:status] != 'active' && @request.headers['Refresh-Token'].present?
            current_user.labels.find_by(key: 'email').update!(value: 'pending')

            authorize_by_refresh_header!

            token = codec.decode_token(found_token, Barong::App.config.keystore.public_key)

            JWTSessions::Session.new.flush_by_uuid(token[:uuid])

            devices = current_user.devices

            if devices.present?
              devices.update_all(active: false)
              notify_session_destroy(current_user.uid)
            end

            activity_record(user: current_user.id, action: "logout::account::#{params[:status]}",
                            result: 'succeed', topic: 'session')
          end

          { status: "User #{current_user.social_media_status} successfully" }
        end

        desc 'Update user device'
        params do
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
        post '/devices' do
          device = current_user.devices.find_or_initialize_by(device_id: params[:device_id],
                                                              device_type: params[:device_type])

          device.update(device_token: params[:device_token], active: true)

          status 201
        end

        desc 'Create an authorization code.'
        post 'authorize' do
          params do
            requires :client_id,
                     types: String,
                     desc: 'Unique client id.'
            optional :captcha_response,
                     types: { value: [String, Hash], message: 'identity.session.invalid_captcha_format' },
                     desc: 'Response from captcha widget'
          end
          verify_captcha!(response: params['captcha_response'], endpoint: 'authorization_code')

          client = verify_client!

          code = SecureRandom.hex(32)
          data = { uid: current_user.uid, client_id: client.kid }

          Rails.cache.write("auth_code_#{code}", data, expires_in: Barong::App.config.auth_code_expiry)

          present code: code, redirect_url: client.redirect_url
          status 201
        end

        desc 'Api for last login Activity'
        get '/last_login' do
          present current_user.activities.where(action: 'login', result: 'succeed').last,
                  with: API::V2::Entities::ActivityWithLastLogin
        end

        desc 'User\'s associated with authorized client'
        get '/clients' do
          present current_user.authorized_clients.active, with: API::V2::Entities::AuthorizedClient
        end
      end
    end
  end
end
