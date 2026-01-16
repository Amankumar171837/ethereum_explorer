RSpec.configure do |config|
  config.before(:suite) do
    Chewy.strategy(:bypass)
  end

  config.around(:each) do |example|
    Chewy.strategy(:urgent) do
      example.run
    end
  end
end
