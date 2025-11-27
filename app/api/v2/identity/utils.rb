# frozen_string_literal: true
module API::V2
  module Identity
    module Utils
      def session
        request.session
      end

      def open_session(user)
        csrf_token = SecureRandom.hex(10)
        session.merge!(
          "uid": user.uid,
          "user_ip": remote_ip,
          "user_agent": request.env['HTTP_USER_AGENT'],
          "expire_time": Time.now.to_i + Barong::App.config.session_expire_time,
          "csrf_token": csrf_token
        )

        csrf_token
      end

      def verify_captcha!(response:, endpoint:, error_statuses: [400, 422])
        # by default we protect user_create session_create password_reset email_confirmation endpoints
        return unless BarongConfig.list['captcha_protected_endpoints']&.include?(endpoint)

        case Barong::App.config.captcha
        when 'recaptcha'
          recaptcha(response: response)
        when 'geetest'
          geetest(response: response)
        when 'turnstile'
          turnstile(response: response)
        end
      end

      def recaptcha(response:, error_statuses: [400, 422])
        error!({ errors: ['identity.captcha.required'] }, error_statuses.first) if response.blank?

        captcha_error_message = 'identity.captcha.verification_failed'

        return if CaptchaService::RecaptchaVerifier.new(request: request).response_valid?(skip_remote_ip: true, response: response)

        error!({ errors: [captcha_error_message] }, error_statuses.last)
      rescue StandardError
        error!({ errors: [captcha_error_message] }, error_statuses.last)
      end

      def geetest(response:, error_statuses: [400, 422])
        error!({ errors: ['identity.captcha.required'] }, error_statuses.first) if response.blank?

        geetest_error_message = 'identity.captcha.verification_failed'
        validate_geetest_response(response: response)

        return if CaptchaService::GeetestVerifier.new.validate(response)

        error!({ errors: [geetest_error_message] }, error_statuses.last)
      rescue StandardError
        error!({ errors: [geetest_error_message] }, error_statuses.last)
      end

      def turnstile(response:, error_statuses: [400, 422])
        error!({ errors: ['identity.captcha.required'] }, error_statuses.first) if response.blank?

        captcha_error_message = 'identity.captcha.verification_failed'

        return if CaptchaService::TurnstileVerifier.new(request: request).response_valid?(skip_remote_ip: true, response: response)

        error!({ errors: [captcha_error_message] }, error_statuses.last)
      rescue StandardError => _e
        error!({ errors: [captcha_error_message] }, error_statuses.last)
      end

      def validate_geetest_response(response:)
        unless (response['geetest_challenge'].is_a? String) &&
               (response['geetest_validate'].is_a? String) &&
               (response['geetest_seccode'].is_a? String)
          error!({ errors: ['identity.captcha.mandatory_fields'] }, 400)
        end
      end

      def login_error!(options = {})
        options[:data] = { reason: options[:reason] }.to_json
        options[:topic] = 'session'
        activity_record(options.except(:reason, :error_code, :error_text))
        error!({ errors: ['identity.session.' + options[:error_text]] }, options[:error_code])
      end

      def activity_record(options = {})
        params = {
          category:     'user',
          user_id:      options[:user],
          user_ip:      remote_ip,
          user_agent:   request.env['HTTP_USER_AGENT'],
          topic:        options[:topic],
          action:       options[:action],
          result:       options[:result],
          data:         options[:data]
        }.merge(Barong::GeoIP.info(ip: remote_ip))
        Activity.create(params)
      end

      def token_uniq?(jti)
        error!({ errors: ['identity.user.utilized_token'] }, 422) if Rails.cache.read(jti) == 'utilized'
        Rails.cache.write(jti, 'utilized', expires_in: Barong::App.config.jwt_expire_time.seconds)
      end

      def publish_welcome_email(user)
        EventAPI.notify('system.user.create',
                        record: { user: user.as_json_for_event_api })
      end

      def publish_confirmation(user, domain)
        token = codec.encode(sub: 'confirmation', email: user.email, uid: user.uid)
        EventAPI.notify(
          'system.user.email.confirmation.token',
          record: {
            user: user.as_json_for_event_api,
            domain: domain,
            token: token
          }
        )
      end

      def publish_session_create(user)
        user.update(last_ip: remote_ip, last_country: Barong::GeoIP.info(ip: remote_ip, keys: [:country])[:country])
        # browser = Browser.new(request.env['HTTP_USER_AGENT'])
        # EventAPI.notify('system.session.create',
        #                 record: {
        #                   user: user.as_json_for_event_api,
        #                   user_ip: remote_ip,
        #                   user_agent: "#{browser.name} #{browser.version} (#{browser.platform.name})"
        #                 })
      end

      def validate_phone!(phone_number)
        phone_number = Phone.international(phone_number)

        error!({ errors: ['identity.session.invalid_num'] }, 400) \
          unless Phone.valid?(phone_number)
      end

      def find_identifier(params)
        if EmailValidator.valid?(params[:identity])
          'email'
        elsif /\A[[:word:]_.]+\z/.match?(params[:identity])
          'username'
        elsif Phone.valid?(Phone.international(params[:identity]))
          'phone'
        end
      end

      def request_from_app?
        user_agents.any? {|key, _| request.env['HTTP_USER_AGENT'].match?(key) }
      end

      def user_agents
        YAML.safe_load(
          ERB.new(
            File.read(
              Barong::App.config.user_agents
            )
          ).result
        )['user_agents']
      end

      def sign_auth
        YAML.safe_load(
          ERB.new(
            File.read(
              Barong::App.config.sign_auth
            )
          ).result
        )['sign_auth_enabled']
      end

      def get_user(params, identifier)
        user = if identifier == 'email'
                 User.find_by(email: params[:identity])
               elsif identifier == 'username'
                 User.find_by(username: params[:identity])
               elsif identifier == 'phone'
                 phone_number = Phone.international(params[:identity])
                 validate_phone!(phone_number)
                 User.find_by(phone_number: phone_number)
               else
                 error!({ errors: ['identity.session.invalid_identifier'] }, 401)
               end
        error!({ errors: ['identity.session.invalid_params'] }, 401) unless user

        if user.state == 'banned'
          login_error!(reason: 'Your account is banned', error_code: 401,
                       user: user.id, action: 'login', result: 'failed', error_text: 'banned')
        end

        if user.state == 'deleted'
          login_error!(reason: 'Your account is deleted', error_code: 401,
                       user: user.id, action: 'login', result: 'failed', error_text: 'deleted')
        end

        # if user is not active or pending, then return 401
        unless user.state.in?(%w[active pending])
          login_error!(reason: 'Your account is not active', error_code: 401,
                       user: user.id, action: 'login', result: 'failed', error_text: 'not_active')
        end
        user
      end

      def update_device(user, params)
        return unless params.present?

        device = user.devices.find_or_initialize_by(device_id: params[:device_id],
                                                    device_type: params[:device_type])

        device.update!(device_token: params[:device_token], active: true)
      end

      def set_phone_key(number)
        sent = false

        Rails.cache.fetch("phone_otp_#{number}", expires_in: 10.seconds) { sent = true }

        error!({ errors: ['identity.session.resend_time'] }, 422) unless sent
      end

      def app_version(platform)
        request.env['HTTP_USER_AGENT'][/BlockmazeX1-#{platform}\/(\d+\.\d+)/, 1]
      end

      def send_email_otp(user, options = {})
        if user.time_before_resend && user.time_before_resend >= Time.now
          error!({ errors: ['identity.session.resend_time'] }, 422)
        end

        user.set_code
        publish_otp_confirmation(user, Barong::App.config.otp_domain)
        activity_record(user: user.id, action: options[:action],
                        result: 'succeed', topic: options[:topic])
        { message: 'Code was sent successfully via email', email: user.email }
      end

      def send_phone_otp(user, options = {})
        if user.phone_time_before_resend && user.phone_time_before_resend >= Time.now
          error!({ errors: ['identity.session.resend_time'] }, 422)
        end

        set_phone_key(user.phone_number)

        unless ((user.phone_code_expiry_date&.to_datetime || 10.hours.ago) + Barong::App.config.resend_otp_limit_reached.to_i.minutes) >= Time.now
          user.update(phone_resend_counter: 0) if user.phone_resend_counter.to_i.positive?
        end

        if Barong::App.config.resend_otp_max.to_i <= user.phone_resend_counter.to_i
          if ((user.phone_code_expiry_date&.to_datetime || 10.hours.ago) + Barong::App.config.resend_otp_limit_reached.to_i.minutes) >= Time.now
            error!({ errors: ['identity.session.too_many_resend'] }, 429)
          else
            user.update(phone_resend_counter: 0)
          end
        end

        user.set_phone_code
        send_verify_user(user, 'sms') unless user.role == 'mock'
        activity_record(user: user.id, action: options[:action],
                        result: 'succeed', topic: options[:topic])
        { message: 'Code was sent successfully via sms' }
      end

      def otp_channel(user)
        phone_otp = user.labels.find_by(key: 'login_phone')&.value != 'verified' ||
          user.labels.find_by(key: 'login_email')&.value != 'verified'

        return 'phone' if phone_otp

        return 'email' if app_version('ios').nil? && app_version('android').nil?

        (app_version('ios').to_f >= 1.3 || app_version('android').to_f > 1.4) ? 'email' : 'phone'
      end

      def verify_client!
        client = RegisteredClient.active.find_by(kid: params[:client_id])
        error!({ errors: ['identity.invalid_client'] }, 422) unless client

        client
      end
    end
  end
end
