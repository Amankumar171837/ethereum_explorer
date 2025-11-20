# frozen_string_literal: true

module API::V2
  module Resource
    class UserUpdate < Grape::API
      helpers ::API::V2::Resource::Validations

      resource :user do
        desc 'update email address',
             success: API::V2::Entities::UserWithPhone,
             failure: [
               { code: 400, message: 'Required params are missing' },
               { code: 422, message: 'Validation errors' }
             ]
        params do
          requires :email,
                   type: String,
                   desc: 'User Email'
        end
        post '/email' do
          declared_params = declared(params, include_missing: false)

          error!({ errors: ['user.email.invalid'] }, 422) unless EmailValidator.valid?(declared_params[:email])

          error!({ errors: ['email.undisposable'] }, 422) if disposable_email?(params[:email])

          unless current_user.time_before_resend.nil?
            error!({ errors: ['user.email.resend_time'] }, 422) unless current_user.time_before_resend <= Time.now
          end

          unless SendgridService.validate_email!(declared_params[:email], source: 'User Update')
            error!({ errors: ['resource.user.invalid_email'] }, 422)
          end

          user = User.find_by('email=? and not id=?', declared_params[:email], current_user.id)

          if user.present?
            label = user.labels.find_or_initialize_by(key: 'login_email', scope: 'private')

            if label.value == 'pending' || label.value.to_s == ''
              label.update(value: 'pending')
            end

            if (user.state == 'active' && label.value == 'verified') || user.social_media_status == 'deactivated'
              error!({ errors: ['email.taken'] }, 422)
            elsif user.state == 'pending' || label.value == 'pending'
              user.update!(latest_email: "#{'pending_user_'}#{SecureRandom.hex(7)}@blockdag.network",
                           older_email: user.email)
            end
          end

          current_user.update!(latest_email: declared_params[:email])

          current_user.set_code
          current_user.email = current_user.latest_email
          publish_otp_confirmation(current_user, Barong::App.config.otp_domain, true)

          current_user.reload

          activity_record(user: current_user.id, action: 'update email address', result: 'succeed', topic: 'user',
                          data: { update: 'Email update initiated  by user' }.to_json)
          present current_user, with: API::V2::Entities::UserWithPhone
        rescue => e
          Rails.logger.error e
          error!(e.message, 422)
        end

        desc 'verify email address with OTP',
             success: API::V2::Entities::UserWithPhone,
             failure: [
               { code: 400, message: 'Required params are missing' },
               { code: 422, message: 'Validation errors' }
             ]
        params do
          requires :email,
                   type: String,
                   desc: 'User Email'
          requires :verification_code,
                   type: String,
                   desc: 'User Email OTP'
        end
        post '/email/verify' do
          declared_params = declared(params, include_missing: false)

          error!({ errors: ['resource.user.verification_invalid'] }, 422) unless current_user.latest_email == declared_params[:email]

          error!({ errors: ['resource.user.code_is_expired'] }, 422) unless current_user.code_expiry_date >= Time.now

          unless PlatformSetting.verify_service(current_user.phone_number, 'email')
                                .verify_email_user?(code: declared_params[:verification_code], user: current_user)
            error!({ errors: ['resource.user.verification_invalid'] }, 422)
          end

          user = User.find_by('email=? and not id=?', declared_params[:email], current_user.id)
          ActiveRecord::Base.transaction do
            if user.present?
              user.update!(email: user.latest_email)
              label = user.labels.find_or_initialize_by(key: 'login_email', scope: 'private')

              if user.state == 'active' && label.value == 'verified' || user.social_media_status == 'deactivated'
                error!({ errors: ['email.taken'] }, 422)
              elsif user.state == 'pending' || label.value == 'pending'
                user.update!(email: user.latest_email)
              end

              label.update(value: 'pending')
            end

            current_user.update!(email: current_user.latest_email,
                                 older_email: current_user.email,
                                 code_expiry_date: 1.minute.ago(Time.now))
            label = current_user.labels.find_or_initialize_by(key: 'login_email', scope: 'private')
            label.update(value: 'verified')
          end
          update_email_notifications(current_user)

          activity_record(user: current_user.id, action: 'updated email address',
                          result: 'succeed', topic: 'user',
                          data: { current_user: "User has updated their email address from #{current_user.older_email} to #{current_user.email}",
                                  pending_user: "User (#{user&.uid}) email address has updated"}.to_json)
          present current_user, with: API::V2::Entities::UserWithPhone
        rescue => e
          Rails.logger.error e
          error!(e.message, 422)
        end

        desc 'update phone number',
             success: API::V2::Entities::UserWithPhone,
             failure: [
               { code: 400, message: 'Required params are missing' },
               { code: 422, message: 'Validation errors' }
             ]
        params do
          requires :phone_number,
                   type: String,
                   desc: 'User Phone Number'
          optional :channel,
                   type: String,
                   default: 'sms',
                   values: { value: -> { Phone::TWILIO_CHANNELS }, message: 'resource.phone.invalid_channel'},
                   desc: 'The verification method to use'
        end
        post '/phone_number' do
          declared_params = declared(params, include_missing: false)

          unless current_user.phone_time_before_resend.nil?
            error!({ errors: ['user.phone_number.resend_time'] }, 422) unless current_user.phone_time_before_resend <= Time.now
          end

          phone_number = validate_phone!(declared_params[:phone_number])
          user         = User.find_by('phone_number=? and not id=?', phone_number, current_user.id)
          if user.present?
            label = user.labels.find_or_initialize_by(key: 'login_phone', scope: 'private')

            if label.value == 'pending' || label.value.to_s == ''
              label.update(value: 'pending')
            end

            user.update!(older_phone: user.phone_number)
          end

          current_user.update!(latest_phone: phone_number)

          current_user.set_phone_code
          current_user.phone_number = current_user.latest_phone
          send_verify_user(current_user, declared_params[:channel])

          current_user.reload

          activity_record(user: current_user.id, action: 'update phone number', result: 'succeed', topic: 'user',
                          data: { update: 'Phone update initiated  by user' }.to_json)
          present current_user, with: API::V2::Entities::UserWithPhone
        rescue => e
          Rails.logger.error e
          error!(e.message, 422)
        end

        desc 'verify phone number with OTP',
             success: API::V2::Entities::UserWithPhone,
             failure: [
               { code: 400, message: 'Required params are missing' },
               { code: 422, message: 'Validation errors' }
             ]
        params do
          requires :phone_number,
                   type: String,
                   desc: 'User Email'
          requires :verification_code,
                   type: String,
                   desc: 'User Email OTP'
        end
        post '/phone_number/verify' do
          declared_params = declared(params, include_missing: false)
          phone_number    = validate_phone!(declared_params[:phone_number])

          error!({ errors: ['resource.user.verification_invalid'] }, 422) unless current_user.latest_phone == phone_number

          error!({ errors: ['resource.user.code_is_expired'] }, 422) unless current_user.phone_code_expiry_date >= Time.now

          # Temp update the latest phone number in the phone number field, so it can be used while verification
          current_user.phone_number = current_user.latest_phone

          unless PlatformSetting.verify_service(phone_number)
                                .verify_phone_user?(code: declared_params[:verification_code], user: current_user)
            error!({ errors: ['resource.user.verification_invalid'] }, 422)
          end

          current_user.reload

          user = User.find_by('phone_number=? and not id=?', phone_number, current_user.id)
          ActiveRecord::Base.transaction do
            if user.present?
              user.update!(phone_number: '')
              label = user.labels.find_or_initialize_by(key: 'login_phone', scope: 'private')
              label.update!(value: 'pending')
              update_user(user)
            end

            current_user.update!(phone_number: current_user.latest_phone,
                                 older_phone: current_user.phone_number,
                                 phone_code_expiry_date: 1.minute.ago(Time.now))
            label = current_user.labels.find_or_initialize_by(key: 'login_phone', scope: 'private')
            label.update(value: 'verified')
          end

          activity_record(user: current_user.id, action: 'updated phone number',
                          result: 'succeed', topic: 'user',
                          data: { current_user: "User has updated their phone number from #{current_user.older_phone} to #{current_user.phone_number}",
                                  pending_user: "User (#{user&.uid}) phone number has updated"}.to_json)
          present current_user, with: API::V2::Entities::UserWithPhone
        rescue => e
          Rails.logger.error e
          error!(e.message, 422)
        end
      end
    end
  end
end
