# frozen_string_literal: true

module API
  module V2
    module Admin
      class PlatformSettings < Grape::API
        resource :platform_settings do

          helpers ::API::V2::Admin::NamedParams

          desc 'Get Platform Settings',
               success: API::V2::Admin::Entities::PlatformSettings,
               failure: [
                 { code: 401, message: 'admin.platform_settings.invalid.token' }
               ]
          params do
            optional :id,
                     type: Integer,
                     desc: 'Platform Setting Id'
            optional :service_type,
                     type: String,
                     desc: 'Setting type sms or email'
            optional :service_name,
                     type: String,
                     desc: 'Service used in the platform.'
            optional :state,
                     type: String,
                     values: { value: ->(p) { %w[enabled disabled].include?(p) }, message: 'admin.platform_setting.state.invalid' },
                     desc: 'Setting State enabled or disabled'
            use :pagination_filters
          end
          get do
            admin_authorize! :read, PlatformSetting

            PlatformSetting.order(id: :desc)
               .tap { |q| q.where!(id: params[:id]) if params[:id]}
               .tap { |q| q.where!(service_name: params[:service_name]) if params[:service_name] }
               .tap { |q| q.where!(service_type: params[:service_type]) if params[:service_type] }
               .tap { |q| q.where!(state: params[:state]) if params[:state] }
               .tap { |q| present paginate(q), with: API::V2::Admin::Entities::PlatformSettings }
          end

          desc 'Create Platform Settings',
               success: API::V2::Admin::Entities::PlatformSettings,
               failure: [
                 { code: 400, message: 'admin.platform_settings.required_parameters.empty' },
                 { code: 401, message: 'admin.platform_settings.invalid_token' },
                 { code: 422, message: 'admin.platform_settings.validation.error' }
               ]
          params do
            requires :service_name,
                     type: String,
                     desc: 'Service Name of platform.'
            requires :service_type,
                     type: String,
                     desc: 'Setting type sms or email'
            requires :service_key,
                     type: String,
                     values: { value: -> { PlatformSetting::SERVICES_KEYS }, message: 'admin.platform_settings.invalid.service_key' },
                     desc: 'Service key of setting'
            optional :state,
                     type: String,
                     desc: 'Setting State enabled or disabled',
                     values: { value: ->(p) { %w[enabled disabled].include?(p) }, message: 'admin.platform_settings.state.invalid' }
            optional :metadata,
                     type: JSON,
                     desc: 'Setting Description or Credentials'
          end
          post do
            admin_authorize! :create, PlatformSetting

            declared_params = declared(params)
            p_setting = PlatformSetting.new(declared_params)

            unless p_setting.save
              error!({ errors: p_setting.errors.details }, 422)
            end
            present p_setting, with: API::V2::Admin::Entities::PlatformSettings
            status 200
          rescue StandardError => e
            Rails.logger.error e.inspect
            error!(e.message, 422)
          end

          desc 'Update Platform Settings',
               success: API::V2::Admin::Entities::PlatformSettings,
               failure: [
                 { code: 400, message: 'admin.platform_settings.required_parameters.empty' },
                 { code: 401, message: 'admin.platform_settings.invalid_token' },
                 { code: 422, message: 'admin.platform_settings.validation.error' }
               ]
          params do
            requires :id,
                     type: Integer,
                     desc: 'Platform Setting Id'
            optional :state,
                     type: String,
                     values: { value: ->(p) { %w[enabled disabled].include?(p) }, message: 'admin.platform_settings.state.invalid' },
                     desc: 'Setting State enabled or disabled'
            optional :metadata,
                     type: JSON,
                     desc: 'Setting Description or Credentials'
          end
          put do
            admin_authorize! :update, PlatformSetting

            declared_params = declared(params)
            p_setting = PlatformSetting.find_by(id: declared_params[:id])
            error!({ errors: ['admin.platform_settings.doesnt_exists'] }, 422) unless p_setting

            unless p_setting.update(declared_params)
              error!({ errors: p_setting.errors.details }, 422)
            end
            present p_setting, with: API::V2::Admin::Entities::PlatformSettings
            status 200
          rescue StandardError => e
            Rails.logger.error e.inspect
            error!(e.message, 422)
          end

          desc 'Get Services of Platform Setting'
          get 'services' do
            present PlatformSetting::SERVICES.deep_transform_values {|x| x.to_s}
            status 200
          end
        end
      end
    end
  end
end
