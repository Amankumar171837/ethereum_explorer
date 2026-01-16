# frozen_string_literal: true

class UserQuery
  attr_reader :relation
  
  def initialize(relation = User.all)
    @relation = relation
  end
  
  # Metaprogramming: Define filter methods dynamically
  %i[email state role level country platform phone_number username].each do |attr|
    define_method("filter_by_#{attr}") do |value|
      return self if value.blank?
      
      # Use LIKE for string fields (except state, role, level which are enums)
      if value.is_a?(String) && ![:state, :role, :level, :platform].include?(attr)
        @relation = @relation.where("users.#{attr} LIKE ?", "%#{value}%")
      else
        @relation = @relation.where(attr => value)
      end
      
      self
    end
  end
  
  # Chainable methods
  def with_associations(*assocs)
    @relation = @relation.includes(*assocs)
    self
  end
  
  def ordered_by(column, direction = :asc)
    direction = direction.to_s.downcase == 'desc' ? :desc : :asc
    @relation = @relation.order(column => direction)
    self
  end
  
  def paginate(page: 1, per_page: 10)
    page = page.to_i
    per_page = per_page.to_i
    @relation = @relation.limit(per_page).offset((page - 1) * per_page)
    self
  end
  
  def by_referral(referral_uid)
    return self if referral_uid.blank?
    
    referrer = User.find_by_uid(referral_uid)
    @relation = @relation.where(referral_id: referrer&.id) if referrer
    self
  end
  
  def by_referral_limit(min_count)
    return self if min_count.blank?
    
    @relation = @relation.where('users_count >= ?', min_count)
    self
  end
  
  def by_date_range(from: nil, to: nil)
    @relation = @relation.where('created_at >= ?', from) if from.present?
    @relation = @relation.where('created_at < ?', to) if to.present?
    self
  end
  
  # Apply all filters from params hash
  def apply_filters(params)
    params.each do |key, value|
      method_name = "filter_by_#{key}"
      send(method_name, value) if respond_to?(method_name)
    end
    
    # Handle special filters
    by_referral(params[:referral_of]) if params[:referral_of]
    by_referral_limit(params[:referral_limit]) if params[:referral_limit]
    by_date_range(from: params[:from], to: params[:to])
    
    self
  end
  
  def results
    @relation
  end
  
  # Convenience method for count
  def count
    @relation.count
  end
end
