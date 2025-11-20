# frozen_string_literal: true

module API
  module V2
    module Admin
      class SmsSenderConfig < Grape::API
        resource :sms_sender do

          helpers ::API::V2::Admin::NamedParams

          desc 'Get sms sender config',
               success: API::V2::Admin::Entities::SmsSenderConfig,
               failure: [
                 { code: 401, message: 'admin.sms_sender_config.invalid.token' }
               ]
          params do
            optional :id,
                     type: Integer,
                     desc: 'SMS Sender config Id'
            optional :country_code,
                     type: String,
                     desc: 'SMS Sender config country code'
            optional :country,
                     type: String,
                     desc: 'SMS Sender config used in the platform.'
            optional :platform_setting_id,
                     type: String,
                     desc: 'SMS Sender config used in the platform.'
            optional :status,
                     type: String,
                     values: { value: -> { %w[active inactive] }, message: 'admin.platform_setting.status.invalid' },
                     desc: 'SMS Sender config is active or inactive'
            optional :from,
                     type: Time,
                     desc: 'An integer represents the seconds elapsed since Unix epoch.'\
                           'If set, only records FROM the time will be retrieved.'
            optional :to,
                     type: Time,
                     desc: 'An integer represents the seconds elapsed since Unix epoch.'\
                           'If set, only records BEFORE the time will be retrieved.'
            use :pagination_filters
          end
          get do
            ::SmsSenderConfig.order(id: :desc)
                             .tap { |q| q.where!(id: params[:id]) if params[:id] }
                             .tap { |q| q.where!(country: params[:country]) if params[:country] }
                             .tap { |q| q.where!(country_code: params[:country_code]) if params[:country_code] }
                             .tap { |q| q.where!(status: params[:status]) if params[:status] }
                             .tap { |q| q.where!(platform_setting_id: params[:platform_setting_id]) if params[:platform_setting_id] }
                             .tap { |q| q.where!('created_at >= ?', params[:from]) if params[:from] }
                             .tap { |q| q.where!('created_at < ?', params[:to]) if params[:to] }
                             .tap { |q| present paginate(q), with: API::V2::Admin::Entities::SmsSenderConfig }
          end

          desc 'Create SMS Sender config',
               success: API::V2::Admin::Entities::SmsSenderConfig,
               failure: [
                 { code: 400, message: 'admin.sms_sender_config.required_parameters.empty' },
                 { code: 401, message: 'admin.sms_sender_config.invalid_token' },
                 { code: 422, message: 'admin.sms_sender_config.validation.error' }
               ]
          params do
            requires :country_code,
                     type: String,
                     desc: 'Service Name of platform.'
            requires :sender,
                     type: String,
                     desc: 'Setting type sms or email'
            requires :platform_setting_id,
                     type: String,
                     desc: 'Platform setting id'
            optional :status,
                     type: String,
                     desc: 'Setting status active or inactive',
                     values: { value: ->{ %w[active inactive] }, message: 'admin.sms_sender_config.status.invalid' },
                     default: 'inactive'
            optional :metadata,
                     type: JSON,
                     desc: 'Setting Description or Credentials'
          end
          post do
            declared_params = declared(params)

            setting = PlatformSetting.find_by(id: declared_params[:platform_setting_id])
            error!({ errors: ['admin.sms_sender_config.doesnt_exists'] }, 422) unless setting

            sender = ::SmsSenderConfig.new(declared_params)
            error!({ errors: sender.errors.details }, 422) unless sender.save

            present sender, with: API::V2::Admin::Entities::SmsSenderConfig
            status 200
          rescue StandardError => e
            Rails.logger.error e.inspect
            error!(e.message, 422)
          end

          desc 'Update SMS Sender Config details',
               success: API::V2::Admin::Entities::SmsSenderConfig,
               failure: [
                 { code: 400, message: 'admin.sms_sender_config.required_parameters.empty' },
                 { code: 401, message: 'admin.sms_sender_config.invalid_token' },
                 { code: 422, message: 'admin.sms_sender_config.validation.error' }
               ]
          params do
            requires :id,
                     type: Integer,
                     desc: 'Sms sender config Id'
            optional :status,
                     type: String,
                     values: { value: -> { %w[active inactive] }, message: 'admin.sms_sender_config.status.invalid' },
                     desc: 'Setting status enabled or disabled'
            optional :metadata,
                     type: JSON,
                     desc: 'Setting Description or Credentials'
          end
          put do
            declared_params = declared(params)
            sender = ::SmsSenderConfig.find_by(id: declared_params[:id])
            error!({ errors: ['admin.sms_sender_config.doesnt_exists'] }, 422) unless sender

            unless sender.update(declared_params)
              error!({ errors: sender.errors.details }, 422)
            end
            present sender, with: API::V2::Admin::Entities::SmsSenderConfig
            status 200
          rescue StandardError => e
            Rails.logger.error e.inspect
            error!(e.message, 422)
          end

          desc 'Delete SMS Sender Config details',
               success: { code: 201 },
               failure: [
                 { code: 400, message: 'admin.sms_sender_config.required_parameters.empty' },
                 { code: 401, message: 'admin.sms_sender_config.invalid_token' },
                 { code: 422, message: 'admin.sms_sender_config.validation.error' }
               ]
          params do
            requires :id,
                     type: Integer,
                     desc: 'Sms sender config Id'
          end
          delete do
            declared_params = declared(params)
            sender = ::SmsSenderConfig.find_by(id: declared_params[:id])
            error!({ errors: ['admin.sms_sender_config.doesnt_exists'] }, 422) unless sender

            error!({ errors: ['admin.sms_sender_config.should_be_disabled'] }, 422) if sender.status == 'active'

            unless sender.delete
              error!({ errors: sender.errors.details }, 422)
            end
            status 201
          rescue StandardError => e
            Rails.logger.error e.inspect
            error!(e.message, 422)
          end
        end
      end
    end
  end
end
