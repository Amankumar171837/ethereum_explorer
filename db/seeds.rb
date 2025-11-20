# frozen_string_literal: true

require_dependency 'barong/seed'

seed = Barong::Seed.new
seed.seed_levels
seed.seed_permissions
seed.seed_users
seed.seed_restrictions
seed.platform_settings
seed.country_services

puts seed.inspect
