# queries helping module
module API::V2::Queries
  class UserFilter
    attr_accessor :initial_scope

    # initialize query to get User.all
    def initialize(initial_scope, with_profile = false)
      @initial_scope = if with_profile
                         initial_scope.left_outer_joins(:profiles)
                       else
                         initial_scope
                       end
    end

    # returns query with with all applied filters
    def call(params)
      scoped = filter_by_date(initial_scope, params[:range], params[:from], params[:to])
      scoped = filter_by_referral_of(scoped, params[:referral_of])
      scoped = filter_by_uid(scoped, params[:uid])
      scoped = filter_by_email(scoped, params[:email])
      scoped = filter_by_role(scoped, params[:role])
      scoped = filter_by_country(scoped, params[:country])
      scoped = filter_by_level(scoped, params[:level])
      scoped = filter_by_state(scoped, params[:state])
      scoped = filter_by_username(scoped, params[:username])
      scoped = filter_by_phone_number(scoped, params[:phone_number])
      scoped = filter_by_platform(scoped, params[:platform])
      scoped = filter_by_referral_limit(scoped, params[:referral_limit])
      scoped
    end

    private

    # adds where(users.[created, updated]_at > from and users.[created, updated]_at < to) to query
    def filter_by_date(scoped, range = 'created', from = nil, to = nil)
      newer_than_sql = "users.#{range}_at >= ?"
      older_than_sql = "users.#{range}_at <= ?"

      updated_scope = from ? scoped.where(newer_than_sql, from) : scoped
      to ? updated_scope.where(older_than_sql, to) : updated_scope
    end

    # adds where(users.uid = uid) to query
    def filter_by_uid(scoped, uid = nil)
      uid ? scoped.where(users: { uid: uid }) : scoped
    end

    # adds where(users.email = email) to query
    def filter_by_email(scoped, email = nil)
      email ? scoped.where("email LIKE ?", "%#{email}%") : scoped
    end

    # adds where(users.role = role) to query
    def filter_by_role(scoped, role = nil)
      role ? scoped.where(users: { role: role }) : scoped
    end

    # adds where(users.level = level) to query
    def filter_by_level(scoped, level = nil)
      level ? scoped.where(users: { level: level }) : scoped
    end

    # adds where(users.state = state) to query
    def filter_by_state(scoped, state = nil)
      state ? scoped.where(users: { state: state }) : scoped
    end

    # adds where(users.country = country) to query
    def filter_by_country(scoped, country = nil)
      country ? scoped.where(profiles: { country: country }) : scoped
    end

    def filter_by_username(scoped, username = nil)
      username ? scoped.where('username LIKE ?', "%#{username}%") : scoped
    end

    def filter_by_phone_number(scoped, phone_number = nil)
      phone_number ? scoped.where(users: { phone_number: phone_number }) : scoped
    end

    def filter_by_platform(scoped, platform = nil)
      platform ? scoped.where(users: { platform: platform }) : scoped
    end

    def filter_by_referral_of(scoped, referral_of = nil)
      referral_id = User.find_by(uid: referral_of)&.id
      referral_of ? scoped.where(users: { referral_id: referral_id.to_i }) : scoped
    end

    def filter_by_referral_limit(scoped, referral_limit = nil)
      referral_limit ? scoped.where('users_count >= ?', referral_limit) : scoped
    end
  end
end
