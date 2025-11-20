# frozen_string_literal: true

module API
  module V2
    module Admin
      class Devices < Grape::API
        resource :devices do

          helpers ::API::V2::Admin::NamedParams

          desc 'Get all Devices',
               success: Entities::Device,
               failure: [
                 { code: 401, message: 'admin.device.invalid.token' }
               ]
          params do
            optional :id,
                     type: Integer,
                     desc: 'Device unique identifier'
            optional :uid,
                     type: String,
                     desc: 'UID of a user'
            optional :device_id,
                     type: String,
                     desc: 'Device id'
            optional :device_type,
                     type: String,
                     desc: 'Device type'
            optional :active,
                     type: Boolean,
                     desc: 'Device state'
            optional :ordering,
                     values: { value: -> (p){ %w[asc desc].include?(p) }, message: 'admin.device.invalid_ordering' },
                     default: 'asc',
                     desc: 'If set, returned values will be sorted in specific order, defaults to \'asc\'.'
            optional :order_by,
                     default: 'id',
                     desc: 'Name of the field, which result will be ordered by.'
            use :pagination_filters
          end
          get do
            admin_authorize! :read, Device

            user = User.find_by(uid: params[:uid]) if params[:uid].present?

            Device.order("#{params[:order_by]} #{params[:ordering]}")
                  .tap { |q| q.where!(id: params[:id]) if params[:id] }
                  .tap { |q| q.where!(user: user) if params[:uid] }
                  .tap { |q| q.where!(device_id: params[:device_id]) if params[:device_id] }
                  .tap { |q| q.where!(device_type: params[:device_type]) if params[:device_type] }
                  .tap { |q| q.where!(active: params[:active]) unless params[:active].nil? }
                  .tap { |q| present paginate(q), with: Entities::Device }
          end
        end
      end
    end
  end
end
