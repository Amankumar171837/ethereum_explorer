module Barong
  class Seed
    class ConfigError < RuntimeError; end

    def initialize
      @result = []
    end

    def seeds
      YAML.safe_load(
        ERB.new(
          File.read(
            Barong::App.config.seeds_file
          )
        ).result
      )
    end

    def inspect
      str = "Seeded users:\n"
      str += @result.map do |user|
        "Email: #{user[:email]}, password: #{user[:password]}"
      end.join("\n")
      return str
    end

    def logger
      @logger ||= Logger.new(STDERR, progname: "db:seed")
    end

    def seed_levels
      logger.info "Seeding levels"
      seeds["levels"].each_with_index do |level, index|
        logger.info "---"
        if Level.find_by(key: level["key"], value: level["value"]).present?
          logger.info "Level '#{level['key']}:#{level['value']}' already exists"
          next
        end
        level[:id] = index+1
        Level.create!(level)
      end
    end

    def seed_permissions
      logger.info "Seeding permissions"
      seeds["permissions"].each do |perm|
        logger.info "---"
        if Permission.find_by(role: perm["role"], verb: perm["verb"], path: perm["path"], action: perm["action"]).present?
          logger.info "Permission for '#{perm['role']}' : '#{perm['verb']} to #{perm['path']}' already exists"
          next
        end

        permission = Permission.new(perm)

        unless permission.save
          raise ConfigError.new("Can't create permission: #{permission.errors.full_messages.join('; ')}")
        end
      end
    end

    def seed_users
      logger.info "Seeding users"
      seeds["users"].each do |seed|
        logger.info "---"

        raise ConfigError.new("Email missing in users seed") if seed["email"].to_s.empty?
        raise ConfigError.new("Level is missing for user #{seed["email"]}") unless seed["level"].is_a?(Integer)

        # Skip existing users
        if User.find_by(email: seed["email"]).present?
          logger.info "User '#{seed['email']}' already exists"
          @result.push(email: seed["email"])
          next
        end

        user = User.new(seed)
        user.password ||= SecureRandom.base64(30)

        if user.save
          logger.info "Created user for '#{user.email}'"

          # Set correct level with labels
          levels = Level.where(id: 1..user.level)
          raise ConfigError.new("No enough levels found in database to grant the user to level #{user.level}") if levels.count < user.level
          levels.find_each do |level|
            user.labels.create(key: level.key, value: level.value, scope: 'private')
          end

          @result.push(email: user.email, password: user.password, level: user.level)
        else
          logger.error "Can't create user '#{user.email}': #{user.errors.full_messages.join('; ')}"
        end
      end
    end

    def seed_restrictions
      logger.info "Seeding restrictions"
      return logger.info "Restrictions seed is empty!" if seeds["restrictions"].empty?

      seeds["restrictions"].each do |seed|
        logger.info "---"
        if Restriction.find_by(category: seed["category"], scope: seed["scope"], value: seed["value"], state: seed["state"]).present?
          logger.info "Restriction '#{seed['category']}' '#{seed['scope']} #{seed['value']}' #{seed['state']}' already exists"
          next
        end
        raise ConfigError.new("category missing in restrictions seed") if seed["category"].nil?
        raise ConfigError.new("scope is missing in restrictions seed") if seed["scope"].nil?
        raise ConfigError.new("value is missing in restrictions seed") if seed["value"].nil?
        raise ConfigError.new("state is missing in restrictions seed") if seed["state"].nil?

        restriction = Restriction.new(
          category: seed["category"],
          scope: seed["scope"],
          value: seed["value"],
          state: seed["state"],
          code: seed["code"]
        )

        unless restriction.save
          raise ConfigError.new("Can't create restriction: #{restriction.errors.full_messages.join('; ')}")
        end
      end
    end

    def platform_settings
      logger.info "Seeding platform settings"
      return logger.info "Platform Settings seed is empty!" if seeds["platform_settings"].empty?

      seeds['platform_settings'].each do |seed|
        logger.info "---"
        if PlatformSetting.find_by(service_type: seed["service_type"], service_key: seed["service_key"]).present?
          logger.info "Platform Settings '#{seed['service_type']}' '#{seed['service_name']} #{seed['service_key']}' already exists"
          next
        end
        raise ConfigError.new('Service type missing in platform settings seed') if seed['service_type'].nil?
        raise ConfigError.new('Service name is missing in platform settings seed') if seed['service_name'].nil?
        raise ConfigError.new('Service key is missing in platform settings seed') if seed['service_key'].nil?

        ps = PlatformSetting.new(
          service_type: seed['service_type'],
          service_key: seed['service_key'],
          service_name: seed['service_name']
        )

        unless ps.save!
          raise ConfigError.new("Can't create platform settings: #{ps.errors.full_messages.join('; ')}")
        end
      end
    end

    def country_services
      logger.info "Seeding Country Services"
      return logger.info "Country Services seed is empty!" if seeds["country_services"].empty?

      seeds['country_services'].each do |seed|
        logger.info "---"
        if CountryService.find_by(service_type: seed["service_type"], country_name: seed['country_name']).present?
          logger.info "Country Service for '#{seed['service_type']}' already exists"
          next
        end

        raise ConfigError.new('Service type missing in country service seed') if seed['service_type'].nil?
        raise ConfigError.new('Country Name is missing in country service seed') if seed['country_name'].nil?

        platform_setting_id = seed['service_type'] == 'email' ?
                                PlatformSetting.find_by(service_key: "sendgrid").id :
                                PlatformSetting.find_by(service_key: "mock").id

        cs = CountryService.new(
          service_type: seed['service_type'],
          country_name: seed['country_name'],
          country_code: seed['country_code'],
          continent: seed['continent'],
          platform_setting_id: platform_setting_id
        )

        unless cs.save!
          raise ConfigError.new("Can't create country services: #{cs.errors.full_messages.join('; ')}")
        end
      end
    end
  end
end
