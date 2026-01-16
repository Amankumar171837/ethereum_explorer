# frozen_string_literal: true

module EnhancedFinders
  extend ActiveSupport::Concern
  
  class_methods do
    # Auto-generate bang methods for all find_by_* methods
    def method_missing(method_name, *args, &block)
      if method_name.to_s =~ /^find_by_(.+)!$/
        attribute = $1
        
        # Define the method dynamically for future calls
        define_singleton_method(method_name) do |value|
          find_by(attribute => value).tap do |record|
            raise ActiveRecord::RecordNotFound, 
                  "Couldn't find #{name} with #{attribute}=#{value}" unless record
          end
        end
        
        # Call the newly defined method
        send(method_name, *args)
      else
        super
      end
    end
    
    def respond_to_missing?(method_name, include_private = false)
      method_name.to_s =~ /^find_by_(.+)!$/ || super
    end
  end
end
