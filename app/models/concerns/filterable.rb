# frozen_string_literal: true

module Filterable
  extend ActiveSupport::Concern
  
  class_methods do
    # Define filterable attributes with metaprogramming
    def filterable_by(*attributes, **options)
      attributes.each do |attr|
        column = columns_hash[attr.to_s]
        
        # Generate scope for exact match
        scope "by_#{attr}", ->(value) { where(attr => value) if value.present? }
        
        # Generate scope for LIKE match (for strings)
        if column&.type == :string && !options[:exact_only]
          scope "by_#{attr}_like", ->(value) { 
            where("#{table_name}.#{attr} LIKE ?", "%#{sanitize_sql_like(value)}%") if value.present? 
          }
        end
        
        # Generate scope for range (for numbers/dates)
        if [:integer, :datetime, :date, :decimal].include?(column&.type)
          scope "by_#{attr}_min", ->(value) { where("#{table_name}.#{attr} >= ?", value) if value.present? }
          scope "by_#{attr}_max", ->(value) { where("#{table_name}.#{attr} <= ?", value) if value.present? }
        end
      end
    end
    
    # Apply filters from params hash
    def apply_filters(params)
      result = all
      
      params.each do |key, value|
        next if value.blank?
        
        # Try exact match scope first
        scope_name = "by_#{key}"
        if respond_to?(scope_name)
          result = result.send(scope_name, value)
        # Try LIKE match scope for string searches
        elsif respond_to?("#{scope_name}_like")
          result = result.send("#{scope_name}_like", value)
        end
      end
      
      result
    end
  end
end
