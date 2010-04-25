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
    gemspec.name = "Aegis"
    gemspec.summary = "Role-based permissions for your user models."
    gemspec.email = "github@makandra.de"
    gemspec.homepage = "http://github.com/makandra/aegis"
    gemspec.description = "Aegis is a role-based permission system, where all users are given a role. It is possible to define detailed and complex permissions for each role very easily."
    gemspec.authors = ["Henning Koch"]
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

