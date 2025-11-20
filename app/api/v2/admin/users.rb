# frozen_string_literal: true

module API
  module V2
    module Admin
      # Admin functionality over users table
      class Users < Grape::API
        resource :users do
          helpers ::API::V2::NamedParams
          helpers do
            def permitted_search_params(params)
              params.slice(:uid, :email, :role, :first_name, :last_name, :country, :level, :state, :from, :to, :range)
            end

            def search(field, value)
              error!({ errors: ['admin.user.non_user_field'] }, 422) unless User.attribute_names.include?(field)

              User.where("#{field}": value).order('email ASC')
            end
          end

          desc 'Returns array of users as paginated collection',
            failure: [
              { code: 401, message: 'Invalid bearer token' }
            ],
            success: API::V2::Admin::Entities::User
          params do
            optional :extended,
                     type: { value: Boolean, message: 'admin.user.non_boolean_extended' },
                     default: false,
                     desc: 'When true endpoint returns full information about users'
            optional :uid,
                     type: String
            optional :email,
                     type: String
            optional :role,
                     type: String
            optional :country,
                     type: String
            optional :level,
                     type: Integer
            optional :state,
                     type: String
            optional :phone_number,
                     type: String
            optional :username,
                     type: String
            optional :platform,
                     type: String
            optional :referral_of,
                     type: String
            optional :referral_limit,
                     type: String
            optional :range,
                     type: String,
                     values: { value: -> (p){ %w[created updated].include?(p) }, message: 'admin.user.invalid_range' },
                     default: 'created'
            optional :ordering,
                     values: { value: -> (p){ %w[asc desc].include?(p) }, message: 'user.ordering.invalid_ordering' },
                     default: 'asc',
                     desc: 'If set, returned values will be sorted in specific order, defaults to \'asc\'.'
            optional :order_by,
                     values: { value: -> (p){ User.new.attributes.keys.include?(p) }, message: 'user.ordering.invalid_attribute' },
                     default: 'id',
                     desc: 'Name of the field, which result will be ordered by.'
            use :timeperiod_filters
            use :pagination_filters
          end
          get do
            admin_authorize! :read, User

            declared_params = declared(params, include_missing: false)

            records_per_page = params[:limit] || 10
            page_number = params[:page] || 1
            offset = (page_number - 1) * records_per_page

            entity = params[:extended] ? API::V2::Admin::Entities::UserWithProfile : API::V2::Entities::User

            if declared_params.except(:order_by, :ordering, :limit, :page, :extended, :range).present?
              User.order("#{params[:order_by]} #{params[:ordering]}")
                  .tap { |q| q.where!("email LIKE ?", "%#{params[:email]}%") if params[:email] }
                  .tap { |q| q.where!(state: params[:state]) if params[:state] }
                  .tap { |q| q.where!(uid: params[:uid]) if params[:uid] }
                  .tap { |q| q.where!(role: params[:role]) if params[:role] }
                  .tap { |q| q.where!(level: params[:level]) if params[:level] }
                  .tap { |q| q.where!(country: params[:country]) if params[:country] }
                  .tap { |q| q.where!(platform: params[:platform]) if params[:platform] }
                  .tap { |q| q.where!(referral_id: User.find_by(uid: params[:referral_of])&.id.to_i) if params[:referral_of] }
                  .tap { |q| q.where!("username LIKE ?", "%#{params[:username]}%") if params[:username] }
                  .tap { |q| q.where!(phone_number: params[:phone_number]) if params[:phone_number] }
                  .tap { |q| q.where!('users_count >= ?', params[:referral_limit]) if params[:referral_limit] }
                  .tap { |q| q.where!('created_at >= ?', params[:from]) if params[:from] }
                  .tap { |q| q.where!('created_at < ?', params[:to]) if params[:to] }
                  .tap { |q| present paginate(q), with: entity }
            else
              users = User.order(id: :desc).limit(records_per_page).offset(offset)
              header 'total', User.count
              header 'per-page', records_per_page

              present users, with: entity
            end
          end

          desc 'Returns array of users as paginated collection (Elasticsearch)',
               failure: [
                 { code: 401, message: 'Invalid bearer token' }
               ],
               success: API::V2::Admin::Entities::User
          params do
            optional :uid,
                     type: String
            optional :email,
                     type: String
            optional :role,
                     type: String
            optional :country,
                     type: String
            optional :level,
                     type: Integer
            optional :state,
                     type: String
            optional :phone_number,
                     type: String
            optional :username,
                     type: String
            optional :platform,
                     type: String
            optional :referral_of,
                     as: :referral_id,
                     type: String
            optional :referral_limit,
                     as: :users_count,
                     type: Integer
            optional :range,
                     type: String,
                     values: { value: -> (p){ %w[created updated].include?(p) }, message: 'admin.user.invalid_range' },
                     default: 'created'
            optional :ordering,
                     values: { value: -> (p){ %w[asc desc].include?(p) }, message: 'user.ordering.invalid_ordering' },
                     default: 'asc',
                     desc: 'If set, returned values will be sorted in specific order, defaults to \'asc\'.'
            optional :order_by,
                     values: { value: -> (p){ User.new.attributes.keys.include?(p) }, message: 'user.ordering.invalid_attribute' },
                     default: 'id',
                     desc: 'Name of the field, which result will be ordered by.'
            use :timeperiod_filters
            use :pagination_filters
          end
          get '/search' do
            admin_authorize! :read, User

            params[:referral_id] = User.find_by_uid(params[:referral_id])&.id if params[:referral_id].present?
            results = User.search_query(params)
            add_paginate_header(results[:total], params)
            present results[:records], with: API::V2::Admin::Entities::User
          end

          desc 'Update user attributes',
            failure: [
              { code: 401, message: 'Invalid bearer token' }
            ],
            success: { code: 200, message: 'User attributes were updated' }
          params do
            requires :uid,
                     type: String,
                     allow_blank: false,
                     desc: 'user uniq id'
            optional :state,
                     type: String,
                     allow_blank: false,
                     desc: 'user state'
            optional :remark,
                     type: String,
                     allow_blank: false,
                     desc: 'remark on state change'
            optional :otp,
                     type: Boolean,
                     allow_blank: false,
                     desc: 'user 2fa status'
            all_or_none_of :state, :remark, message: 'admin.user.all_of_state_and_remark'
            exactly_one_of :state, :otp, message: 'admin.user.one_of_state_otp'
          end
          post '/update' do
            admin_authorize! :update, User

            target_user = User.find_by_uid(params[:uid])

            # Ruby Hash returns array on keys and values
            update_param_key = params.except(:uid).keys.first
            update_param_value = params.except(:uid).values.first

            error!({ errors: ['admin.user.doesnt_exist'] }, 404) if target_user.nil?

            if target_user.superadmin? && !current_user.superadmin?
              error!({ errors: ['admin.user.superadmin_change'] }, 422)
            end

            error!({ errors: ['admin.user.update_himself'] }, 422) if target_user.uid == current_user.uid

            if update_param_key == 'otp' && update_param_value == true
              error!({ errors: ['admin.user.enable_2fa'] }, 422)
            end

            if update_param_value == target_user[update_param_key]
              error!({ errors: ["admin.user.#{update_param_key}_no_change"] }, 422)
            end

            unless target_user.update(update_param_key => update_param_value)
              code_error!(target_user.errors.details, 422)
            else
              if (update_param_key == "state")
                target_user.modify_user = current_user.id
                target_user.remark = params[:remark]
                target_user.add_state_log
              end
            end

            target_user.labels.find_by(key: :otp, scope: :private).delete if target_user.labels.find_by(key: :otp, scope: :private) && update_param_key == 'otp'
            status 200
          end

          desc 'Update user role',
            failure: [
              { code: 401, message: 'Invalid bearer token' }
            ],
            success: { code: 200, message: 'User role was created' }
          params do
            requires :uid,
                     type: String,
                     allow_blank: false,
                     desc: 'user uniq id'
            requires :role,
                     type: String,
                     allow_blank: false,
                     desc: 'user role'
          end
          post '/role' do
            admin_authorize! :update, User

            target_user = User.find_by_uid(params[:uid])

            error!({ errors: ['admin.user.doesnt_exist'] }, 404) if target_user.nil?

            if target_user.superadmin? && !current_user.superadmin?
              error!({ errors: ['admin.user.superadmin_change'] }, 422)
            end

            error!({ errors: ['admin.user.update_himself'] }, 422) if target_user.uid == current_user.uid

            if params[:role] == target_user.role
              error!({ errors: ["admin.user.role_no_change"] }, 422)
            end

            if !current_user.superadmin? &&  params[:role] == 'superadmin'
              error!({ errors: ['admin.user.not_superadmin'] }, 422)
            end

            unless target_user.update(role: params[:role])
              code_error!(target_user.errors.details, 422)
            end

            status 200
          end

          desc 'Update user attributes',
            failure: [
              { code: 401, message: 'Invalid bearer token' }
            ],
            success: { code: 200, message: 'User attributes were created' }
          params do
            requires :uid,
                     type: String,
                     allow_blank: false,
                     desc: 'user uniq id'
            optional :email,
                     type: String,
                     allow_blank: false,
                     desc: 'User Email'
            optional :state,
                     type: String,
                     allow_blank: false,
                     desc: 'user state'
            optional :otp,
                     type: Boolean,
                     allow_blank: false,
                     desc: 'user 2fa status'
            exactly_one_of :state, :otp, :email, message: 'admin.user.one_of_state_otp_email'
          end
          put do
            admin_authorize! :update, User

            target_user = User.find_by_uid(params[:uid])

            # Ruby Hash returns array on keys and values
            update_param_key = params.except(:uid).keys.first
            update_param_value = params.except(:uid).values.first

            error!({ errors: ['admin.user.doesnt_exist'] }, 404) if target_user.nil?

            if target_user.superadmin? && !current_user.superadmin?
              error!({ errors: ['admin.user.superadmin_change'] }, 422)
            end

            error!({ errors: ['admin.user.update_himself'] }, 422) if target_user.uid == current_user.uid

            if update_param_key == 'email' && !current_user.superadmin?
              error!({ errors: ['superadmin.user.update_email'] }, 422)
            end

            if update_param_key == 'otp' && update_param_value == true
              error!({ errors: ['admin.user.enable_2fa'] }, 422)
            end

            if update_param_value == target_user[update_param_key]
              error!({ errors: ["admin.user.#{update_param_key}_no_change"] }, 422)
            end

            unless target_user.update(update_param_key => update_param_value)
              code_error!(target_user.errors.details, 422)
            end

            target_user.labels.find_by(key: :otp, scope: :private).delete if target_user.labels.find_by(key: :otp, scope: :private) && update_param_key == 'otp'
            status 200
          end

          namespace :labels do
            desc 'Returns existing labels keys and values',
              failure: [
                { code: 401, message: 'Invalid bearer token' }
              ]
            params do
            end
            get '/list' do
              admin_authorize! :read, User

              labels = Label.where(scope: 'private').group(:key, :value).size

              present labels
            end

            desc 'Returns array of users as paginated collection',
              failure: [
                { code: 401, message: 'Invalid bearer token' }
              ],
              success: API::V2::Admin::Entities::User
            params do
              requires :key,      type: String, desc: 'Label key'
              requires :value,    type: String, desc: 'Label value'
              use :pagination_filters
            end
            get do
              admin_authorize! :read, User

              users = User.joins(:labels).where(labels: { key: params[:key], value: params[:value] })

              present paginate(users), with: API::V2::Admin::Entities::User
            end

            desc 'Add label for user',
              failure: [
                { code: 401, message: 'Invalid bearer token' }
              ],
              success: { code: 200, message: 'Label was created' }
            params do
              requires :uid,
                       type: String,
                       allow_blank: false,
                       desc: 'user uniq id'
              requires :key,
                       type: String,
                       allow_blank: false,
                       desc: 'label key. [a-z0-9_-]+ should be used. Min - 3, max - 255 characters.'
              requires :value,
                       type: String,
                       allow_blank: false,
                       desc: 'label value. [A-Za-z0-9_-] should be used. Min - 3, max - 255 characters.'
              optional :description,
                       type: String,
                       allow_blank: false,
                       desc: 'label description. [A-Za-z0-9_-] should be used. max - 255 characters.'
              optional :scope, type: String, desc: "Label scope: 'public' or 'private'. Default is public", allow_blank: false
            end
            post do
              admin_authorize! :create, Label

              declared_params = declared(params, include_missing: false)

              target_user = User.find_by_uid(params[:uid])
              error!({ errors: ['admin.user.doesnt_exist'] }, 404) if target_user.nil?

              if target_user.superadmin? && !current_user.superadmin?
                error!({ errors: ['admin.user.superadmin_change'] }, 422)
              end

              declared_params[:user_id] = target_user.id

              label = target_user.labels.find_by(key: declared_params[:key])
              error!({ errors: ['admin.label.already_exist'] }, 422) if label

              label = Label.new(declared_params.except(:uid))

              code_error!(label.errors.details, 422) unless label.save
              activity_record(user: target_user.id,
                              action: "#{declared_params[:key]} label created",
                              result: 'succeed', topic: 'label')

              status 200
            end

            desc 'Update user label value',
              failure: [
                { code: 400, message: 'Required params are empty' },
                { code: 401, message: 'Invalid bearer token' },
                { code: 404, message: 'Record is not found' },
                { code: 422, message: 'Validation errors' }
              ],
              success: { code: 200, message: 'Label was updated' }
            params do
              requires :uid,
                       type: String,
                       allow_blank: false,
                       desc: 'user uniq id'
              requires :key,
                       type: String,
                       allow_blank: false,
                       desc: 'Label key.'
              requires :scope,
                       type: String,
                       allow_blank: false,
                       desc: 'label key. [a-z0-9_-]+ should be used. Min - 3, max - 255 characters.'
              requires :value,
                       type: String,
                       allow_blank: false,
                       desc: 'Label value.'
              optional :description,
                       type: String,
                       allow_blank: false,
                       desc: 'label description. [A-Za-z0-9_-] should be used. max - 255 characters.'
              optional :replace,
                       type: { value: Boolean, message: 'admin.user.non_boolean_replace' },
                       default: true,
                       desc: 'When true label will be created if not exist'
            end
            post '/update' do
              admin_authorize! :update, Label

              declared_params = declared(params, include_missing: false)

              target_user = User.find_by_uid(declared_params[:uid])
              error!({ errors: ['admin.user.doesnt_exist'] }, 404) if target_user.nil?

              if target_user.superadmin? && !current_user.superadmin?
                error!({ errors: ['admin.user.superadmin_change'] }, 422)
              end

              label = Label.find_by_key_and_user_id_and_scope(declared_params[:key], target_user.id, declared_params[:scope])

              if label.nil?
                if declared_params[:replace]
                  label = Label.create(
                    user_id: target_user.id,
                    key: declared_params[:key],
                    value: declared_params[:value],
                    scope: declared_params[:scope],
                    description: declared_params[:description]
                  )
                  activity_record(user: target_user.id,
                                  action: "#{declared_params[:key]} label created",
                                  result: 'succeed', topic: 'label')
                else
                  error!({ errors: ['admin.label.doesnt_exist'] }, 404)
                end
              else
                label.update({ value: params[:value], description: params[:description] })
                activity_record(user: target_user.id,
                                action: "#{declared_params[:key]} label updated",
                                result: 'succeed', topic: 'label')
              end
              code_error!(label.errors.details, 422) if label.errors.any?

              status 200
            end

            desc 'Update user label scope',
              failure: [
                { code: 400, message: 'Required params are empty' },
                { code: 401, message: 'Invalid bearer token' },
                { code: 404, message: 'Record is not found' },
                { code: 422, message: 'Validation errors' }
              ],
              success: { code: 200, message: 'Label was updated' }
            params do
              requires :uid,
                       type: String,
                       allow_blank: false,
                       desc: 'user uniq id'
              requires :key,
                       type: String,
                       allow_blank: false,
                       desc: 'Label key.'
              requires :scope,
                       type: String,
                       allow_blank: false,
                       desc: 'label key. [a-z0-9_-]+ should be used. Min - 3, max - 255 characters.'
              optional :description,
                       type: String,
                       allow_blank: false,
                       desc: 'label description. [A-Za-z0-9_-] should be used. max - 255 characters.'
              requires :value,
                       type: String,
                       allow_blank: false,
                       desc: 'Label value.'
            end
            put do
              admin_authorize! :update, Label

              declared_params = declared(params, include_missing: false)

              target_user = User.find_by_uid(declared_params[:uid])
              error!({ errors: ['admin.user.doesnt_exist'] }, 404) if target_user.nil?

              if target_user.superadmin? && !current_user.superadmin?
                error!({ errors: ['admin.user.superadmin_change'] }, 422)
              end

              label = Label.find_by_key_and_user_id_and_scope(declared_params[:key], target_user.id, declared_params[:scope])

              error!({ errors: ['admin.label.doesnt_exist'] }, 404) if label.nil?

              unless label.update({ value: params[:value], description: params[:description] }.compact)
                code_error!(label.errors.details, 422)
              end
              activity_record(user: target_user.id, action: "#{declared_params[:key]} label updated",
                              result: 'succeed', topic: 'label')
              status 200
            end

            desc 'Deletes label for user',
              failure: [
                { code: 401, message: 'Invalid bearer token' }
              ],
              success: { code: 200, message: 'Label was deleted' }
            params do
              requires :uid,
                       type: String,
                       allow_blank: false,
                       desc: 'user uniq id'
              requires :key,
                       type: String,
                       allow_blank: false,
                       desc: 'label key. [a-z0-9_-]+ should be used. Min - 3, max - 255 characters.'
              requires :scope,
                       type: String,
                       allow_blank: false,
                       desc: 'label key. [a-z0-9_-]+ should be used. Min - 3, max - 255 characters.'
            end
            delete do
              admin_authorize! :destroy, Label

              declared_params = declared(params, include_missing: false)

              target_user = User.find_by_uid(params[:uid])
              error!({ errors: ['admin.user.doesnt_exist'] }, 404) if target_user.nil?

              if target_user.superadmin? && !current_user.superadmin?
                error!({ errors: ['admin.user.superadmin_change'] }, 422)
              end

              label = Label.find_by_key_and_user_id_and_scope(declared_params[:key], target_user.id, declared_params[:scope])

              error!({ errors: ['admin.label.doesnt_exist'] }, 404) if label.nil?

              label.destroy
              activity_record(user: target_user.id,
                              action: "#{declared_params[:key]} label deleted",
                              result: 'succeed', topic: 'label')
              status 200
            end
          end

          desc 'Returns user info',
            failure: [
              { code: 401, message: 'Invalid bearer token' }
            ],
            success: API::V2::Admin::Entities::UserWithKYC
          params do
            requires :uid,
                     type: String,
                     allow_blank: false,
                     desc: 'user uniq id'
          end
          get '/:uid' do
            admin_authorize! :read, User

            target_user = User.find_by_uid(params[:uid])
            error!({ errors: ['admin.user.doesnt_exist'] }, 404) if target_user.nil?

            present target_user, with: API::V2::Admin::Entities::UserWithKYC
          end
        end
      end
    end
  end
end
