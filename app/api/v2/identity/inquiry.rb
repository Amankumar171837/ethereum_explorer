module API::V2
  module Identity
    class Inquiry < Grape::API
      desc 'Inquiry API'
      params do
        requires :email, type: String, desc: 'User email', allow_blank: false
        requires :subject, type: String, desc: 'Inquiry subject', allow_blank: false
        requires :message, type: String, desc: 'Inquiry message', allow_blank: false
        requires :name, type: String, desc: 'User name', allow_blank: false
        requires :captcha_response, type: String, desc: 'Response from captcha widget'
      end
      post '/inquiry' do
        # validate email given
        error!('contact_us.email.invalid', 422) unless (params[:email] =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i)

        verify_captcha!(response: params['captcha_response'], endpoint: 'inquiry')
        # send mail to admin/support users with inquiry
        ENV['SUPPORT_USER_UIDS'].split(',').each do |recipient|
          # find user by uid
          user = User.find_by(uid: recipient)
          # create inquiry data json for mailler to send
          inquiry = {
            user:user.as_json_for_event_api,
            inquiry_email: params[:email],
            inquiry_subject: params[:subject],
            inquiry_message: params[:message],
            inquiry_name: params[:name]
          }
          # send mail to SUPPORT_USER with inquiry data
          EventAPI.notify('system.user.inquiry', {record: inquiry})
        end
      end
    end
  end
end
