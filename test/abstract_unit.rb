require 'test/unit'

begin
  require File.dirname(__FILE__) + '/../../../../config/boot'
  require 'active_record'
rescue LoadError
  require 'rubygems'
  require_gem 'activerecord'
end

require 'active_record/fixtures'

require File.dirname(__FILE__) + '/../lib/validates_date_time'

config = YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml'))
ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + '/debug.log')
ActiveRecord::Base.establish_connection(config[ENV['DB'] || 'mysql'])

load(File.dirname(__FILE__) + '/schema.rb')

Test::Unit::TestCase.fixture_path = File.dirname(__FILE__) + '/fixtures/'
$LOAD_PATH.unshift(Test::Unit::TestCase.fixture_path)

class Test::Unit::TestCase #:nodoc:
  def create_fixtures(*table_names)
    if block_given?
      Fixtures.create_fixtures(Test::Unit::TestCase.fixture_path, table_names) { yield }
    else
      Fixtures.create_fixtures(Test::Unit::TestCase.fixture_path, table_names)
    end
  end

  # Turn off transactional fixtures if you're working with MyISAM tables in MySQL
  self.use_transactional_fixtures = true
  
  # Instantiated fixtures are slow, but give you @david where you otherwise would need people(:david)
  self.use_instantiated_fixtures  = false
  
  def p
    people(:jonathan)
  end
  
  def assert_update_and_equal(expected, attributes = {})
    assert p.update_attributes(attributes), "#{attributes.inspect} should be valid"
    assert_equal expected, p.reload.send(attributes.keys.first).to_s
  end
  
  def assert_update_and_match(expected, attributes = {})
    assert p.update_attributes(attributes), "#{attributes.inspect} should be valid"
    assert_match expected, p.reload.send(attributes.keys.first).to_s
  end
  
  def assert_no_update_and_errors(attributes = {})
    assert !p.update_attributes(attributes)
    assert p.errors.on(attributes.keys.first)
  end
  
  def assert_no_update_and_errors_match(expected, attributes = {})
    assert !p.update_attributes(attributes)
    assert_match expected, p.errors.full_messages.join
  end
  
  def with_us_date_format(&block)
    ActiveRecord::Validations::DateTime.us_date_format = true
    yield
    ActiveRecord::Validations::DateTime.us_date_format = false
  end
end
