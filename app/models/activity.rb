class Activity < ApplicationRecord
  include InfluxHelper
  include MetricsHelper

  RESULTS = %w[succeed failed denied].freeze
  CATEGORIES = %w[admin user].freeze

  belongs_to :user
  has_one :target, primary_key: :target_uid, foreign_key: :uid, class_name: 'User'

  validates :user_ip, presence: true, allow_blank: false
  validates :user_agent, presence: true, trusty_agent: true
  validates :topic, presence: true
  validates :result, presence: true, inclusion: { in: RESULTS }
  validates :category, presence: true, inclusion: { in: CATEGORIES }
  validate :target_user

  store_accessor :coordinates, %i[longitude latitude]

  after_commit :create_record_in_influx_db, on: %i[create update]

  class << self
    def daily
      expiry_time = Time.now.end_of_hour - Time.now
      Rails.cache.fetch('daily_traffic', expires_in: expiry_time.seconds) do
        result = self.daily_traffic
        result = result.map {|h| h.values }.to_h
        total  = (0..23).each.with_object({}) { |i, h| h["#{i}"] = result["#{i}"] || rand(1..9) }.values
        total.rotate! -(23 - Time.now.utc.hour)
      end
    end

    def weekly
      expiry_time = Time.now.end_of_day - Time.now
      Rails.cache.fetch('weekly_traffic', expires_in: expiry_time.seconds) do
        result = self.weekly_traffic
        result[0].values.to_a.rotate! -(7 - Time.now.wday())
      end
    end

    def monthly
      expiry_time = Time.now.end_of_day - Time.now
      Rails.cache.fetch('monthly_traffic', expires_in: expiry_time.seconds) do
        result = self.monthly_traffic
        result.map {|h| h.values }.flatten
      end
    end

    def yearly
      expiry_time = Time.now.end_of_day - Time.now
      Rails.cache.fetch('yearly_traffic', expires_in: expiry_time.seconds) do
        result = self.yearly_traffic
        result = result.map {|h| h.values }.to_h.values
        (result.rotate! -(12 - Time.now.utc.month))
      end
    end

    def daily_traffic
      query = <<-SQL
        select 
        date_format(created_at + interval 1 Hour,'%k') as hour,
        count(id) * '#{Barong::App.config.activity_count_multiplier.to_i}' AS total
        FROM
        activities
        WHERE created_at >= '#{Time.now.beginning_of_hour - 24.hour}' and created_at < '#{Time.now.beginning_of_hour}' and
              (topic=('account' or 'session') and action=('signup'or 'login') and result=('succeed' or 'failed'))
        group by date_format(created_at,'%k');
      SQL
      ActiveRecord::Base.connection.exec_query(query)
    end

    def weekly_traffic
      query = <<-SQL
      SELECT 
      SUM(IF(day = 'Mon', total, 0)) AS 'Mon',
      SUM(IF(day = 'Tue', total, 0)) AS 'Tue',
      SUM(IF(day = 'Wed', total, 0)) AS 'Wed',
      SUM(IF(day = 'Thu', total, 0)) AS 'Thu',
      SUM(IF(day = 'Fri', total, 0)) AS 'Fri',
      SUM(IF(day = 'Sat', total, 0)) AS 'Sat',
      SUM(IF(day = 'Sun', total, 0)) AS 'Sun'
      FROM (
        SELECT DATE_FORMAT(created_at, "%a") AS day,
        COUNT(id) * '#{Barong::App.config.activity_count_multiplier.to_i}' AS total
        FROM activities
        WHERE DATE(created_at) <= DATE(NOW()) and created_at >= DATE(Now() - interval 6 day) and
              (topic=('account' or 'session') and action=('signup' or 'login') and result=('succeed' or 'failed'))
        GROUP BY DATE_FORMAT(created_at, "%d-%m-%Y")) as sub
      SQL
      ActiveRecord::Base.connection.exec_query(query)
    end

    def monthly_traffic
      query = <<-SQL
        SELECT 
        CASE 
          WHEN tmp.traffic_count IS NULL THEN 0 
          ELSE tmp.traffic_count
        END AS traffic_count
        FROM (
          SELECT DATE_FORMAT(created_at, "%y-%m-%d") AS Mese, COUNT(id) * '#{Barong::App.config.activity_count_multiplier.to_i}' AS traffic_count
          FROM activities 
          WHERE
            (DATE_FORMAT(created_at, "%y-%m-%d") BETWEEN SUBDATE(DATE_FORMAT(Now(), "%y-%m-%d"), INTERVAL 1 MONTH) AND DATE_FORMAT(Now(), "%y-%m-%d")) AND
             topic=('account' or 'session') and action=('signup' or 'login') and result=('succeed' or 'failed')
          GROUP BY Mese
        ) AS tmp RIGHT JOIN (
        
        SELECT  x.* from (
        SELECT CAST(cal.date_list AS DATE) day_year
        FROM (
          SELECT SUBDATE(DATE_FORMAT(Now(), "%y-%m-%d"), INTERVAL 1 MONTH) + INTERVAL xc DAY AS date_list
          FROM (
                SELECT @xi:=@xi+1 as xc from
                (SELECT 1 UNION SELECT 2) xc1,
                (SELECT 1 UNION SELECT 2) xc2,
                (SELECT 1 UNION SELECT 2) xc3,
                (SELECT 1 UNION SELECT 2) xc4,
                (SELECT 1 UNION SELECT 2) xc5,
                (SELECT @xi:=-1) xc0
            ) xxc1
        ) cal
        WHERE cal.date_list BETWEEN SUBDATE(DATE_FORMAT(Now(), "%Y-%m-%d"), INTERVAL 1 MONTH) AND DATE_FORMAT(Now(), "%Y-%m-%d")
        ORDER BY cal.date_list ASC) x) AS `months` ON `months`.`day_year` = tmp.Mese 
        ORDER BY `months`.`day_year` ASC;
      SQL
      ActiveRecord::Base.connection.exec_query(query)
    end

    def yearly_traffic
      query = <<-SQL
        SELECT 
          `months`.`number`, 
          CASE 
            WHEN tmp.total IS NULL THEN 0 
            ELSE tmp.total 
          END AS total
        FROM (
          SELECT MONTH(created_at) AS yearly, COUNT(id)
         AS total 
          FROM activities 
          WHERE (topic=('account' or 'session') and action=('signup' or 'login') and result=('succeed' or 'failed'))
          AND created_at >= Now() - INTERVAL 1 YEAR + INTERVAL 1 MONTH
          GROUP BY yearly
        ) AS tmp RIGHT JOIN (
            SELECT 1 AS `number`
            UNION SELECT 2
            UNION SELECT 3
            UNION SELECT 4
            UNION SELECT 5
            UNION SELECT 6
            UNION SELECT 7
            UNION SELECT 8
            UNION SELECT 9
            UNION SELECT 10
            UNION SELECT 11
            UNION SELECT 12
        ) AS `months` ON `months`.`number` = tmp.yearly
        ORDER BY `months`.`number` ASC;
      SQL
      ActiveRecord::Base.connection.exec_query(query)
    end

  end
  # this method allows to use all the methods of ::Browser module (platofrm, modern?, version etc)
  def browser
    Browser.new(user_agent)
  end

  def influx_data
    influx_data = { values: { user_id: user_id,
                              user_email: user.email,
                              target_uid: target_uid,
                              target_email: User.find_by_uid(target_uid)&.email,
                              result: result,
                              user_ip: user_ip,
                              action: action,
                              topic: topic,
                              user_agent: user_agent,
                              category: category,
                              data: data,
                              created_at: created_at.to_i}.compact,
                    tags: { user_id: user_id }.compact,
                    timestamp: created_at.to_i }
    influx_data[:values][:id] = id if id.present?
    influx_data[:tags][:id] = id if id.present?
    influx_data
  end

  private

  def target_user
    errors.add(:target_uid, :invalid) if target_uid.present? && User.where(uid: target_uid).empty?
    errors.add(:target_uid, :not_allowed) if target_uid.present? && category.present? && category == 'user'
  end

  def readonly?
    !new_record?
  end
end

# == Schema Information
# Schema version: 20240920072708
#
# Table name: activities
#
#  id           :bigint           not null, primary key
#  user_id      :bigint           not null
#  target_uid   :string(255)
#  category     :string(255)
#  user_ip      :string(255)      not null
#  continent    :string(255)
#  country      :string(255)
#  country_code :string(255)
#  city         :string(255)
#  user_agent   :string(255)      not null
#  topic        :string(255)      not null
#  action       :string(255)      not null
#  result       :string(255)      not null
#  data         :text(65535)
#  coordinates  :json
#  created_at   :datetime
#
# Indexes
#
#  index_activities_on_country_code  (country_code)
#  index_activities_on_target_uid    (target_uid)
#  index_activities_on_user_id       (user_id)
#
