# frozen_string_literal: true

module API::V2
  module Resource
    class UserAccount < Grape::API
      resource :user do

        desc 'Send OTP for the registered email'
        post '/send-otp' do
          unless current_user.time_before_resend.nil?
            error!({ errors: ['resource.user.resend_time'] }, 422) unless current_user.time_before_resend <= Time.now
          end
          current_user.set_code
          publish_otp_confirmation(current_user, Barong::App.config.otp_domain)
          activity_record(user: current_user.id, action: 'user::account_delete::email_otp',
                          result: 'succeed', topic: "email OTP session")

          { message: 'Code was sent successfully via email' }
        end

        desc 'Delete user account.'
        params do
          requires :verification_code,
                   type: String,
                   allow_blank: false,
                   desc: 'Verification code from email'
        end
        delete '/delete-account' do
          error!({ errors: ['resource.user.code_is_expired'] }, 422) if current_user.code_expiry_date < Time.now

          verification = PlatformSetting.verify_service(current_user.phone_number, 'email')
                           .verify_email_user?(code: params[:verification_code], user: current_user)
          error!({ errors: ['resource.user.verification_invalid'] }, 422) unless verification

          current_user.update(code_expiry_date: 1.minute.ago(Time.now),
                              time_before_resend: 1.minute.ago(Time.now))

          response = Barong::Management::User.new.check_user_status({ uid: current_user.uid })
          error!('resource.user_delete.response_error', 422) if response['status'].nil?

          error!('resource.user.cant_be_deleted', 422) if response['status']

          current_user.update(social_media_status: 'deleted',
                              status_updated_at: Time.now,
                              state: 'pending')

          EventAPI.notify('system.user.delete', record: { user: current_user.as_json_for_event_api })

          activity_record(user: current_user.id,
                          action: "request account #{current_user.social_media_status}",
                          result: 'succeed',
                          topic: 'account')

          { status: "User deactivated successfully" }
        rescue => e
          Rails.logger.error e
          error!({ errors: ['resource.user.delete_error'] }, 422)
        end
      end
    end
  end
end
