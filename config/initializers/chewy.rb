# config/initializers/chewy.rb

if File.exists?('config/elasticsearch.yml')
  yaml = ::Pathname.new('config/elasticsearch.yml')
  return {} unless yaml.exist?

  config = ::YAML.load(::ERB.new(yaml.read).result)[Rails.env].deep_symbolize_keys
  hosts = if config[:urls].nil?
            config[:hosts].map { |con| "#{con[:protocol]}://#{con[:host]}:#{con[:port]}" }.join(',')
          else
            config[:urls]
          end
end

Chewy.settings = {
  host: hosts
}
