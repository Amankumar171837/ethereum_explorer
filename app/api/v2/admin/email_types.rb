# frozen_string_literal: true

module API
  module V2
    module Admin
      class EmailTypes < Grape::API
        resource 'email-types' do

          helpers ::API::V2::Admin::NamedParams

          desc 'Get all Email Types',
               success: Entities::EmailTypes,
               failure: [
                          { code: 401, message: 'admin.email_type.invalid.token' }
                        ]
          params do
            optional :id,
                     type: Integer,
                     desc: 'Email type unique identifier'
            optional :name,
                     type: String,
                     desc: 'Email type name'
            optional :status,
                     type: String,
                     values: { value: -> { EmailType::STATUS }, message: 'admin.email_type.invalid_status'},
                     desc: 'Email type status (enabled/disabled)'
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
            admin_authorize! :read, EmailType

            EmailType.order("#{params[:order_by]} #{params[:ordering]}")
              .tap { |q| q.where!(id: params[:id]) if params[:id] }
              .tap { |q| q.where!(name: params[:name]) if params[:name] }
              .tap { |q| q.where!(status: params[:status]) if params[:status] }
              .tap { |q| present paginate(q), with: Entities::EmailTypes }
          end

          desc 'Create Email type',
               success: Entities::EmailTypes,
               failure: [
                          { code: 400, message: 'admin.email_type.required_parameters.empty' },
                          { code: 401, message: 'admin.email_type.invalid_token' },
                          { code: 422, message: 'admin.email_type.validation.error' }
                        ]
          params do
            requires :name,
                     type: String,
                     desc: 'Name for email type.'
            optional :description,
                     type: String,
                     desc: 'Description for email type'
            requires :status,
                     type: String,
                     values: { value: -> { EmailType::STATUS }, message: 'admin.email_type.invalid_status'},
                     desc: 'State for email type (enabled/disabled)'
          end
          post do
            admin_authorize! :create, EmailType

            declared_params = declared(params)
            email_type = EmailType.create!(declared_params)

            present email_type, with: Entities::EmailTypes
          rescue StandardError => e
            Rails.logger.error "Email Type create error: #{e.inspect}"
            error!({ errors: ['admin.email_type.create_error'] }, 422)
          end

          desc 'Update Email type',
               success: Entities::EmailTypes,
               failure: [
                          { code: 400, message: 'admin.email_type.required_parameters.empty' },
                          { code: 401, message: 'admin.email_type.invalid_token' },
                          { code: 422, message: 'admin.email_type.validation.error' }
                        ]
          params do
            requires :id,
                     type: Integer,
                     desc: 'Id of Email type'
            optional :description,
                     type: String,
                     desc: 'Description for email type'
            optional :status,
                     type: String,
                     values: { value: -> { EmailType::STATUS }, message: 'admin.email_type.invalid_status'},
                     desc: 'State for email type (enabled/disabled)'
          end
          put do
            admin_authorize! :update, EmailType

            declared_params = declared(params, include_missing: false)
            email_type = EmailType.find_by(id: declared_params[:id])
            error!({ errors: ['admin.email_type.doesnt_exists'] }, 422) unless email_type

            email_type.update!(declared_params)

            present email_type, with: Entities::EmailTypes
          rescue StandardError => e
            Rails.logger.error "Email Type update error: #{e.inspect}"
            error!({ errors: ['admin.email_type.update_error'] }, 422)
          end
        end
      end
    end
  end
end
