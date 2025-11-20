# frozen_string_literal: true

module API::V2
  module Utils

    def codec
      @_codec ||= Barong::JWT.new(key: Barong::App.config.keystore.private_key)
    end

    def remote_ip
      # default behaviour, IP from HTTP_X_FORWARDED_FOR
      ip = env['action_dispatch.remote_ip'].to_s

      if Barong::App.config.gateway == 'akamai'
        # custom header that contains only client IP
        true_client_ip = request.env['HTTP_TRUE_CLIENT_IP'].to_s
        # take IP from TRUE_CLIENT_IP only if its not nil or empty
        ip = true_client_ip unless true_client_ip.nil? || true_client_ip.empty?
      end

      Rails.logger.debug "User login IP address: #{ip}"
      return ip
    end

    def code_error!(errors, code)
      final = errors.inject([]) do |result, (key, errs)|
        result.concat(
          errs.map { |e| e.values.first }
                .uniq
                .flatten
                .map { |e| [key, e].join('.') }
        )
      end
      error!({ errors: final }, code)
    end

    def admin_authorize!(*args)
      AdminAbility.new(current_user).authorize!(*args)
    rescue CanCan::AccessDenied
      error!({ errors: ['admin.ability.not_permitted'] }, 401)
    end

    def publish_otp_confirmation(user, domain, latest_email = false)
      return true if PlatformSetting.find_by!(service_type: 'email').state.disabled?

      EventAPI.notify(
        'system.user.email.confirmation.otp',
        record: {
          user: user.as_json_for_event_api,
          domain: domain,
          otp: user.code,
          from: Barong::App.config.from_name,
          latest_email: latest_email
        }
      )
      create_service_logs({ service_type: 'email',
                            user: user,
                            topic: 'send::otp',
                            platform_setting: PlatformSetting.find_by(service_type: 'email'),
                            result: 'success' })
    end

    def create_service_logs(p)
      ServiceLog.create!(p.merge(user_ip: remote_ip))
    end

    def service_logs(options = {})
      result         = options[:res].is_a?(Hash) && options[:res][:error]
      status, sms_id = set_result(options[:platform_setting], options[:res])

      params = {
        service_type: options[:channel],
        user: options[:user],
        topic: 'send::otp',
        platform_setting: options[:platform_setting],
        result: status,
        phone_number: options[:phone],
        sms_id: sms_id,
        metadata: {
          errors: result && options[:res][:error],
          response: handle_response(options),
          reason: block_reason(options[:res], options[:platform_setting])
        }.compact
      }

      log = create_service_logs(params)
      error!({ errors: ['resource.otp.send_error'] }, 422) if log.result == 'failed'

      log
    end

    def handle_response(options)
      options[:platform_setting].service_key == 'twilio_sms' ? options[:res].to_s : options[:res]
    end

    def block_reason(res, p_setting)
      res[:reason] if p_setting.service_key == 'ding' && res['status'] == 'blocked'
    end

    def send_confirmation(phone, channel)
      platform_setting = PlatformSetting.service(channel, phone.number)
      settings         = settings(platform_setting)
      res = PlatformSetting.get_service(channel, platform_setting.service_key)
                           .send_confirmation(phone, channel, settings: settings)
      options = {
        res: res,
        channel: channel,
        user: phone.user,
        phone: phone.number,
        platform_setting: platform_setting
      }
      service_logs(options)
    rescue StandardError => e
      Rails.logger.error e.inspect
      error!(e.message, 422)
    end

    def send_verify_user(user, channel)
      number           = user.phone_number
      platform_setting = PlatformSetting.service(channel, number)
      settings         = settings(platform_setting)
      res = PlatformSetting.get_service(channel, platform_setting.service_key)
                           .send_verify_user(user, channel, settings: settings)
      options = {
        res: res,
        channel: channel,
        user: user,
        phone: number,
        platform_setting: platform_setting
      }
      service_logs(options)
    rescue StandardError => e
      Rails.logger.error e.inspect
      error!(e.message, 422)
    end

    def settings(ps)
      if ps.service_key == 'ding'
        {
          'ip': remote_ip,
          'device_id': params[:device_id],
          'device_type': params[:device_type]&.upcase
        }
      else
        ps
      end
    end

    def add_paginate_header(total, params)
      header 'Total',    total.to_s if total
      header 'Per-Page', params[:limit].to_s
      header 'Page',     params[:page].to_s
    end

    def disposable_email?(email)
      return unless Barong::App.config.disable_fake_mail.to_bool

      DisposableMail.include?(email).present?
    end

    private

    def set_result(platform_setting, res)
      case platform_setting.service_key
      when 'bulkgate'
        if res.dig('data', 'sms_id')
          ['accepted', res.dig('data', 'sms_id')]
        else
          ['failed', nil]
        end
      when 'smsala'
        [res['status'] == 'S' ? 'submitted' : 'failed', res['message_id']]
      when 'ding'
        [res['status'] || 'failed', res['id']]
      when 'mobivate'
        if res['id']
          ['accepted', res['id']]
        else
          ['failed', nil]
        end
      else
        ['success', nil]
      end
    end

    def notify_session_destroy(uid, event = 'delete_user', options = {})
      Barong::Management::User.new.notify_session_destroy({ uid: uid, event: event, metadata: options }.compact)
    end
  end
end
