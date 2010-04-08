require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "validates_date_time"
    gemspec.summary = "A Rails plugin adds the ability to validate dates and times with ActiveRecord."
    gemspec.description = "A Rails plugin that adds an ActiveRecord validation helper to do range and start/end date checking in."
    gemspec.email = ["jonathan.viney@gmail.com", "nick@whiteink.com"]
    gemspec.homepage = "http://github.com/nickstenning/validates_date_time"
    gemspec.authors = ["Jonathan Viney", "Nick Stenning"]
  end
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end


desc 'Default: run unit tests.'
task :default => :test

desc 'Test the validates_date_time plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Generate documentation for the validates_date_time plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'validates_date_time'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
