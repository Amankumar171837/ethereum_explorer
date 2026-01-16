# frozen_string_literal: true

module API::V2::Concerns
  module UserManagement
    extend ActiveSupport::Concern
    
    included do
      helpers do
        # Find user with automatic error handling
        def find_user!(uid)
          User.find_by_uid(uid).tap do |user|
            error!({ errors: ['admin.user.doesnt_exist'] }, 404) if user.nil?
          end
        end
        
        # Authorization checks with flexible options
        def authorize_user_modification!(target_user, *checks)
          checks.each do |check|
            case check
            when :superadmin
              check_superadmin_modification!(target_user)
            when :self_modification
              check_self_modification!(target_user)
            else
              send("check_#{check}!", target_user) if respond_to?("check_#{check}!", true)
            end
          end
        end
        
        private
        
        def check_superadmin_modification!(target_user)
          if target_user.superadmin? && !current_user.superadmin?
            error!({ errors: ['admin.user.superadmin_change'] }, 422)
          end
        end
        
        def check_self_modification!(target_user)
          if target_user.uid == current_user.uid
            error!({ errors: ['admin.user.update_himself'] }, 422)
          end
        end
      end
    end
    
    # Module with class methods that Grape can extend
    module ClassMethods
      # DSL for defining user update endpoints
      def user_update_endpoint(path, attribute, **options)
        method_type = options[:method] || :post
        
        desc options[:description] || "Update user #{attribute}",
          failure: [{ code: 401, message: 'Invalid bearer token' }],
          success: { code: 200, message: options[:success_message] || "User #{attribute} was updated" }
        
        params do
          requires :uid, type: String, allow_blank: false, desc: 'User UID'
          requires attribute, 
                   type: options[:type] || String, 
                   allow_blank: false,
                   desc: options[:param_desc] || "User #{attribute}"
          
          # Execute extra params block if provided
          instance_eval(&options[:extra_params]) if options[:extra_params]
        end
        
        send(method_type, path) do
          admin_authorize! :update, User
          
          target_user = find_user!(params[:uid])
          authorize_user_modification!(target_user, :superadmin, :self_modification)
          
          # Custom validations
          instance_exec(target_user, params[attribute], &options[:validate]) if options[:validate]
          
          # Check for no change
          unless options[:allow_same]
            if params[attribute] == target_user[attribute]
              error!({ errors: ["admin.user.#{attribute}_no_change"] }, 422)
            end
          end
          
          # Perform update
          unless target_user.update(attribute => params[attribute])
            code_error!(target_user.errors.details, 422)
          end
          
          # After update callback
          instance_exec(target_user, params[attribute], &options[:after_update]) if options[:after_update]
          
          status 200
        end
      end
    end
    
    # Automatically extend the class with ClassMethods when included
    def self.included(base)
      base.extend(ClassMethods)
    end
  end
end
