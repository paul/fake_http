# frozen_string_literal: true

begin
  require "bundler/gem_tasks"
  require "rspec/core/rake_task"
  require "reek/rake/task"
  require "rubocop/rake_task"
rescue LoadError => ex
  puts ex.message
end

RSpec::Core::RakeTask.new(:spec)
Reek::Rake::Task.new
RuboCop::RakeTask.new

task default: %w[spec reek rubocop]
