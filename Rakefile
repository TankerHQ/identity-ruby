require 'bundler/audit/task'
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubygems/tasks'

Bundler::Audit::Task.new
Gem::Tasks.new
RSpec::Core::RakeTask.new(:spec)

task :default => :spec

