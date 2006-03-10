if SeleniumConfig[:environments].map { |e| e.to_s }.include?(RAILS_ENV)
  $LOAD_PATH << File.expand_path(File.dirname(__FILE__) + '/lib/controllers')
  require File.dirname(__FILE__) + '/routes.rb'
end
