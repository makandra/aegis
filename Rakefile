require 'rake'
require 'rake/rdoctask'
require 'spec/rake/spectask'

desc 'Default: Run Aegis specs'
task :default => :spec

desc "Run Aegis specs"
Spec::Rake::SpecTask.new() do |t|
  t.spec_opts = ['--options', "\"spec/spec.opts\""]
  t.spec_files = FileList['spec/**/*_spec.rb']
end

desc 'Generate documentation for the Aegis gem'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Aegis'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "aegis"
    gemspec.summary = "Complete authorization solution for Rails"
    gemspec.email = "henning.koch@makandra.de"
    gemspec.homepage = "http://github.com/makandra/aegis"
    gemspec.description = "Aegis is an authorization solution for Ruby on Rails that supports roles and a RESTish, resource-style declaration of permission rules."
    gemspec.authors = ["Henning Koch", "Tobias Kraze"]
    gemspec.post_install_message = "Upgrade notice:\nIf you are using Aegis' automatic controller integration, include Aegis::Controller in your ApplicationController\nAlso see http://wiki.github.com/makandra/aegis/controller-integration\n"
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

