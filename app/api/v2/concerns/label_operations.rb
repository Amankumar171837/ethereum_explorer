# frozen_string_literal: true

module API::V2::Concerns
  module LabelOperations
    extend ActiveSupport::Concern
    
    included do
      helpers do
        # Create label with validation and activity logging
        def create_user_label!(user, label_params)
          # Check if label exists
          existing = user.labels.find_by(key: label_params[:key], scope: label_params[:scope] || 'private')
          error!({ errors: ['admin.label.already_exist'] }, 422) if existing
          
          # Create label
          label = user.labels.build(label_params)
          code_error!(label.errors.details, 422) unless label.save
          
          # Log activity
          activity_record(
            user: user.id,
            action: "#{label_params[:key]} label created",
            result: 'succeed',
            topic: 'label'
          )
          
          label
        end
        
        # Update label with validation
        def update_user_label!(user, key, scope, updates, replace: false)
          label = user.labels.find_by(key: key, scope: scope)
          
          if label.nil?
            if replace
              # Create new label if replace is true
              create_user_label!(user, updates.merge(key: key, scope: scope))
            else
              error!({ errors: ['admin.label.doesnt_exist'] }, 404)
            end
          else
            # Update existing label
            code_error!(label.errors.details, 422) unless label.update(updates)
            
            # Log activity
            activity_record(
              user: user.id,
              action: "#{key} label updated",
              result: 'succeed',
              topic: 'label'
            )
            
            label
          end
        end
        
        # Delete label
        def delete_user_label!(user, key, scope)
          label = user.labels.find_by(key: key, scope: scope)
          error!({ errors: ['admin.label.doesnt_exist'] }, 404) unless label
          
          label.destroy
          
          # Log activity
          activity_record(
            user: user.id,
            action: "#{key} label deleted",
            result: 'succeed',
            topic: 'label'
          )
        end
      end
    end
    
    # Module with class methods for Grape DSL
    module ClassMethods
      # Generate all label CRUD endpoints
      def label_crud_endpoints
        namespace :labels do
          # List all labels
          desc 'Returns existing labels keys and values'
          get '/list' do
            admin_authorize! :read, User
            
            labels = Rails.cache.fetch('private_labels_grouped', expires_in: 1.hour) do
              Label.where(scope: 'private').group(:key, :value).size
            end
            
            present labels
          end
          
          # Get users by label
          desc 'Returns array of users as paginated collection',
            success: API::V2::Admin::Entities::User
          params do
            requires :key, type: String, desc: 'Label key'
            requires :value, type: String, desc: 'Label value'
            use :pagination_filters
          end
          get do
            admin_authorize! :read, User
            
            # Eager load associations to prevent N+1 queries
            users = User.includes(:labels, :referrer)
                        .joins(:labels)
                        .where(labels: { key: params[:key], value: params[:value] })
            
            present paginate(users), with: API::V2::Admin::Entities::User
          end
          
          # Create label
          desc 'Add label for user',
            success: { code: 200, message: 'Label was created' }
          params do
            requires :uid, type: String, allow_blank: false, desc: 'User UID'
            requires :key, type: String, allow_blank: false, desc: 'Label key'
            requires :value, type: String, allow_blank: false, desc: 'Label value'
            optional :description, type: String, allow_blank: false, desc: 'Label description'
            optional :scope, type: String, desc: "Label scope: 'public' or 'private'", allow_blank: false
          end
          post do
            admin_authorize! :create, Label
            
            target_user = find_user!(params[:uid])
            authorize_user_modification!(target_user, :superadmin)
            
            create_user_label!(
              target_user,
              params.slice(:key, :value, :description, :scope)
            )
            
            status 200
          end
          
          # Update label
          desc 'Update user label value',
            success: { code: 200, message: 'Label was updated' }
          params do
            requires :uid, type: String, allow_blank: false, desc: 'User UID'
            requires :key, type: String, allow_blank: false, desc: 'Label key'
            requires :scope, type: String, allow_blank: false, desc: 'Label scope'
            requires :value, type: String, allow_blank: false, desc: 'Label value'
            optional :description, type: String, allow_blank: false, desc: 'Label description'
            optional :replace, type: Boolean, default: true, desc: 'Create if not exist'
          end
          post '/update' do
            admin_authorize! :update, Label
            
            target_user = find_user!(params[:uid])
            authorize_user_modification!(target_user, :superadmin)
            
            update_user_label!(
              target_user,
              params[:key],
              params[:scope],
              params.slice(:value, :description),
              replace: params[:replace]
            )
            
            status 200
          end
          
          # Update label scope
          desc 'Update user label scope',
            success: { code: 200, message: 'Label was updated' }
          params do
            requires :uid, type: String, allow_blank: false, desc: 'User UID'
            requires :key, type: String, allow_blank: false, desc: 'Label key'
            requires :scope, type: String, allow_blank: false, desc: 'Label scope'
            requires :value, type: String, allow_blank: false, desc: 'Label value'
            optional :description, type: String, allow_blank: false, desc: 'Label description'
          end
          put do
            admin_authorize! :update, Label
            
            target_user = find_user!(params[:uid])
            authorize_user_modification!(target_user, :superadmin)
            
            update_user_label!(
              target_user,
              params[:key],
              params[:scope],
              params.slice(:value, :description).compact,
              replace: false
            )
            
            status 200
          end
          
          # Delete label
          desc 'Deletes label for user',
            success: { code: 200, message: 'Label was deleted' }
          params do
            requires :uid, type: String, allow_blank: false, desc: 'User UID'
            requires :key, type: String, allow_blank: false, desc: 'Label key'
            requires :scope, type: String, allow_blank: false, desc: 'Label scope'
          end
          delete do
            admin_authorize! :destroy, Label
            
            target_user = find_user!(params[:uid])
            authorize_user_modification!(target_user, :superadmin)
            
            delete_user_label!(target_user, params[:key], params[:scope])
            
            status 200
          end
        end
      end
    end
    
    # Automatically extend the class with ClassMethods when included
    def self.included(base)
      base.extend(ClassMethods)
    end
  end
end
