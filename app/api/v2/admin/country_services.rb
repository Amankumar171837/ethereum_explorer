# frozen_string_literal: true

module API
  module V2
    module Admin
      class CountryServices < Grape::API
        resource :country_services do

          helpers ::API::V2::Admin::NamedParams

          desc 'Get Country Services',
               success: API::V2::Admin::Entities::CountryServices,
               failure: [
                 { code: 401, message: 'admin.country_services.invalid.token' }
               ]
          params do
            optional :id,
                     type: Integer,
                     desc: 'Id of Country Service'
            optional :continent,
                     type: String,
                     desc: 'Continent for Service'
            optional :country_name,
                     type: String,
                     desc: 'Country Name for Service'
            optional :service_type,
                     type: String,
                     desc: 'Service type email/sms'
            optional :country_code,
                     type: String,
                     desc: 'Country Code for Service'
            optional :platform_setting_id,
                     type: Integer,
                     desc: 'Platform Setting Selected for the Country'
            optional :state,
                     type: String,
                     values: { value: ->(p) { %w[enabled disabled].include?(p) }, message: 'admin.country_services.state.invalid' },
                     desc: 'Service state is enabled/disabled'
            optional :ordering,
                     values: { value: -> (p){ %w[asc desc].include?(p) }, message: 'user.ordering.invalid_ordering' },
                     default: 'asc',
                     desc: 'If set, returned values will be sorted in specific order, defaults to \'asc\'.'
            optional :order_by,
                     default: 'id',
                     desc: 'Name of the field, which result will be ordered by.'
            use :pagination_filters
          end
          get do
            admin_authorize! :read, CountryService

            data = if params[:order_by] == 'service_name'
                     CountryService.includes(:platform_setting).order("platform_settings.service_name #{params[:ordering]}")
                   else
                     CountryService.order("#{params[:order_by]} #{params[:ordering]}")
                   end
            data.tap { |q| q.where!(id: params[:id]) if params[:id]}
                .tap { |q| q.where!(platform_setting_id: params[:platform_setting_id]) if params[:platform_setting_id]}
                .tap { |q| q.where!(continent: params[:continent]) if params[:continent] }
                .tap { |q| q.where!(service_type: params[:service_type]) if params[:service_type] }
                .tap { |q| q.where!(country_name: params[:country_name]) if params[:country_name] }
                .tap { |q| q.where!(country_code: params[:country_code]) if params[:country_code] }
                .tap { |q| q.where!(state: params[:state]) if params[:state] }
                .tap { |q| present paginate(q), with: API::V2::Admin::Entities::CountryServices }
          end

          desc 'Create Country Service',
               success: API::V2::Admin::Entities::CountryServices,
               failure: [
                 { code: 400, message: 'admin.country_services.required_parameters.empty' },
                 { code: 401, message: 'admin.country_services.invalid_token' },
                 { code: 422, message: 'admin.country_services.validation.error' }
               ]
          params do
            requires :service_type,
                     type: String,
                     desc: 'Service type sms/email'
            requires :country_code,
                     type: String,
                     desc: 'Country Code of Service'
            requires :platform_setting_id,
                     type: Integer,
                     desc: 'Platform Setting Selected for the Country'
            optional :state,
                     type: String,
                     values: { value: ->(p) { %w[enabled disabled].include?(p) }, message: 'admin.country_services.state.invalid' },
                     desc: 'Service state is enabled/disabled'
          end
          post do
            admin_authorize! :create, CountryService

            declared_params = declared(params)
            error!({ errors: ['admin.platform_settings.not_present'] }, 422) unless PlatformSetting.find_by(id: declared_params[:platform_setting_id])

            country = ISO3166::Country.find_country_by_alpha2(declared_params[:country_code])
            error!({ errors: ['admin.country_services.country_code.invalid'] }, 422) unless country

            country_service = CountryService.new(declared_params.merge(country_name: country.name, continent: country.continent))
            unless country_service.save
              code_error!(country_service.errors.details, 422)
            end
            present country_service, with: API::V2::Admin::Entities::CountryServices
            status 200
          rescue StandardError => e
            Rails.logger.error e.inspect
            error!(e.message, 422)
          end

          desc 'Update Country Service',
               success: API::V2::Admin::Entities::CountryServices,
               failure: [
                 { code: 400, message: 'admin.country_services.required_parameters.empty' },
                 { code: 401, message: 'admin.country_services.invalid_token' },
                 { code: 422, message: 'admin.country_services.validation.error' }
               ]
          params do
            requires :id,
                     type: Integer,
                     desc: 'Id of Country Service'
            requires :platform_setting_id,
                     type: Integer,
                     desc: 'Platform Setting Selected for the Country'
            optional :state,
                     type: String,
                     values: { value: ->(p) { %w[enabled disabled].include?(p) }, message: 'admin.country_services.state.invalid' },
                     desc: 'Service state is enabled/disabled'
          end
          put do
            admin_authorize! :update, CountryService

            declared_params = declared(params)
            error!({ errors: ['admin.platform_settings.not_present'] }, 422) unless PlatformSetting.find_by(id: declared_params[:platform_setting_id])

            country_service = CountryService.find_by(id: declared_params[:id])
            error!({ errors: ['admin.country_service.doesnt_exists'] }, 422) unless country_service

            unless country_service.update(declared_params)
              code_error!(country_service.errors.details, 422)
            end
            present country_service, with: API::V2::Admin::Entities::CountryServices
            status 200
          rescue StandardError => e
            Rails.logger.error e.inspect
            error!(e.message, 422)
          end

          desc "Get all the continents and it's countries"
          params do
            optional :service_type,
                     type: String,
                     desc: 'Service type email/sms'
            optional :country_name,
                     type: String,
                     desc: 'Country Name for Service'
            optional :state,
                     type: String,
                     values: { value: ->(p) { %w[enabled disabled].include?(p) }, message: 'admin.country_services.state.invalid' },
                     desc: 'Service state is enabled/disabled'
            optional :platform_setting_id,
                     type: Integer,
                     desc: 'Platform Setting Selected for the Country'
          end
          get 'continent' do
            admin_authorize! :read, CountryService

            continents = ISO3166::Country.all.map(&:continent).uniq - ['Antarctica']
            data = []
            continents.each do |con|
              country = ::CountryService.order(id: :asc)
                                  .tap { |q| q.where!(platform_setting_id: params[:platform_setting_id]) if params[:platform_setting_id] }
                                  .tap { |q| q.where!(continent: con) }
                                  .tap { |q| q.where!(service_type: params[:service_type]) if params[:service_type] }
                                  .tap { |q| q.where!(country_name: params[:country_name]) if params[:country_name] }
                                  .tap { |q| q.where!(state: params[:state]) if params[:state] }
                                  .select(:id, :country_name, :service_type)
              data << { continent: con, country: country }
            end
            present data
            status 200
          end
        end
      end
    end
  end
end
