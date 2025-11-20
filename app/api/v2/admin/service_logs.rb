# frozen_string_literal: true

module API
  module V2
    module Admin
      # Admin functionality over users table
      class ServiceLogs < Grape::API
        resource :service_logs do

          helpers ::API::V2::NamedParams
          helpers ::API::V2::Admin::NamedParams

          desc 'Returns array of service logs as paginated collection '
          params do
            optional :uid,
                     type: String,
                     desc: API::V2::Admin::Entities::ServiceLogs.documentation[:uid][:desc]
            optional :email,
                     type: String,
                     desc: API::V2::Admin::Entities::ServiceLogs.documentation[:email][:desc]
            optional :service_name,
                     type: String,
                     desc: API::V2::Admin::Entities::ServiceLogs.documentation[:service_name][:desc]
            optional :service_type,
                     type: String,
                     desc: API::V2::Admin::Entities::ServiceLogs.documentation[:service_type][:desc]
            optional :phone_number,
                     type: String,
                     desc: API::V2::Admin::Entities::ServiceLogs.documentation[:phone_number][:desc]
            optional :result,
                     type: String,
                     desc: API::V2::Admin::Entities::ServiceLogs.documentation[:result][:desc]
            optional :country_code,
                     type: String,
                     desc: API::V2::Admin::Entities::ServiceLogs.documentation[:country_code][:desc]
            optional :user_country,
                     type: String,
                     desc: API::V2::Admin::Entities::ServiceLogs.documentation[:user_country][:desc]
            use :timeperiod_filters
            use :pagination_filters
          end
          get do
            admin_authorize! :read, ServiceLog

            user = User.find_by('email = ? or uid = ?', params[:email], params[:uid])
            ServiceLog.order(id: :desc)
                      .tap { |q| q.where!(user_id: user&.id) if params[:email] || params[:uid]}
                      .tap { |q| q.where!(service_name: params[:service_name]) if params[:service_name] }
                      .tap { |q| q.where!(phone_number: params[:phone_number]) if params[:phone_number] }
                      .tap { |q| q.where!(service_type: params[:service_type]) if params[:service_type] }
                      .tap { |q| q.where!(result: params[:result]) if params[:result] }
                      .tap { |q| q.where!(country_code: params[:country_code]) if params[:country_code] }
                      .tap { |q| q.where!(user_country: params[:user_country]) if params[:user_country] }
                      .tap { |q| q.where!('created_at >= ?', params[:from]) if params[:from] }
                      .tap { |q| q.where!('created_at < ?', params[:to]) if params[:to] }
                      .tap { |q| present paginate(q), with: API::V2::Admin::Entities::ServiceLogs }
          end

          desc 'Returns array of service logs as paginated collection through influxdb'
          params do
            optional :uid,
                     type: String,
                     values: { value: -> (v) { User.exists?(uid: v) }, message: 'admin.service_log.user_doesnt_exist' },
                     desc: API::V2::Admin::Entities::ServiceLogs.documentation[:uid][:desc]
            optional :email,
                     as: :user_email,
                     type: String,
                     desc: API::V2::Admin::Entities::ServiceLogs.documentation[:email][:desc]
            optional :service_name,
                     type: String,
                     desc: API::V2::Admin::Entities::ServiceLogs.documentation[:service_name][:desc]
            optional :service_type,
                     type: String,
                     desc: API::V2::Admin::Entities::ServiceLogs.documentation[:service_type][:desc]
            optional :result,
                     type: String,
                     desc: API::V2::Admin::Entities::ServiceLogs.documentation[:result][:desc]
            optional :user_country,
                     type: String,
                     desc: API::V2::Admin::Entities::ServiceLogs.documentation[:user_country][:desc]
            use :timeperiod_filters
            use :pagination_filters
            use :ordering
          end
          get 'data' do
            admin_authorize! :read, ServiceLog

            params[:user_id] = User.find_by(uid: params[:uid]).id if params[:uid].present?
            services = ServiceLog.get_influx_data(params.except(:uid))
            present paginate(services), with: API::V2::Admin::Entities::ServiceLogsWithInflux
          end
        end
      end
    end
  end
end
