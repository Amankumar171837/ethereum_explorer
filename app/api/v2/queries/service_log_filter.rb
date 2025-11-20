# frozen_string_literal: true

# queries helping module
module API::V2::Queries
  class ServiceLogFilter
    attr_accessor :initial_scope

    # initialize query
    def initialize(initial_scope)
      @initial_scope = initial_scope
    end

    # returns query with with all applied filters
    def call(params)
      params[:with_user] ? @initial_scope = @initial_scope.joins(:user) : @initial_scope

      scoped = filter_by_date(@initial_scope, params[:from], params[:to])
      scoped = filter_by_topic(scoped, params[:topic])
      scoped = filter_by_result(scoped, params[:result])
      scoped = filter_by_uid(scoped, params[:uid])
      scoped = filter_by_email(scoped, params[:email])
      scoped = filter_by_service_name(scoped, params[:service_name])
      scoped = filter_by_service_type(scoped, params[:service_type])
      scoped = filter_by_country_code(scoped, params[:country_code])
      scoped = scoped.order('service_logs.id' => 'DESC') if params[:ordered]
      scoped
    end

    private

    # adds where(service_logs.created_at > from and service_logs.created_at < to) to query
    def filter_by_date(scoped, from = nil, to = nil)
      updated_scope = from ? scoped.where('service_logs.created_at >= ?', from) : scoped
      to ? updated_scope.where('service_logs.created_at <= ?', to) : updated_scope
    end

    # adds where(service_logs.topic = topic) to query
    def filter_by_topic(scoped, topic = nil)
      topic ? scoped.where(service_logs: { topic: topic }) : scoped
    end

    # adds where(service_logs.result = result) to query
    def filter_by_result(scoped, result = nil)
      result ? scoped.where(service_logs: { result: result }) : scoped
    end

    # adds where(users.uid = uid) to query
    def filter_by_uid(scoped, uid = nil)
      uid ? scoped.where(users: { uid: uid }) : scoped
    end

    # adds where(users.email = email) to query
    def filter_by_email(scoped, email = nil)
      email ? scoped.where(users: { email: email }) : scoped
    end

    # adds where(service_logs.service_name = service_name) to query
    def filter_by_service_name(scoped,  service_name = nil)
      service_name ? scoped.where(service_logs: { service_name: service_name }) : scoped
    end

    def filter_by_service_type(scoped,  service_type = nil)
      service_type ? scoped.where(service_logs: { service_type: service_type }) : scoped
    end

    def filter_by_country_code(scoped, country_code = nil)
      country_code ? scoped.where(service_logs: { country_code: country_code }) : scoped
    end
  end
end

