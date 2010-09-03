require 'rake'
require 'rspec/core/rake_task'
require 'rake/rdoctask'

desc 'Default: run unit tests.'
task :default => :spec

RSpec::Core::RakeTask.new do |t|
  t.spec_opts = ["--color", "--format", "specdoc"]
end  

desc 'Generate documentation for the booleanize plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Booleanize'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
