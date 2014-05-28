require 'rake'
require 'rake/testtask'

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the aegis gem.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end


begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "aegis"
    gemspec.summary = "Role-based permissions for your user models."
    gemspec.email = "github@makandra.de"
    gemspec.homepage = "http://github.com/makandra/aegis"
    gemspec.description = "Aegis is a role-based permission system, where all users are given a role. It is possible to define detailed and complex permissions for each role very easily."
    gemspec.authors = ["Henning Koch"]
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

