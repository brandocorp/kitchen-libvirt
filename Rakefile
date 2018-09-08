# frozen_string_literal: true

require 'bundler/gem_tasks'

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:test)

require 'rubocop/rake_task'
RuboCop::RakeTask.new(:style) do |task|
  task.options << '--display-cop-names'
end

desc 'Run all quality tasks'
task quality: [:style]

require 'yard'
YARD::Rake::YardocTask.new

begin
  task default: %i[test quality]

  require 'github_changelog_generator/task'
  GitHubChangelogGenerator::RakeTask.new :changelog do |config|
    config.future_release = Kitchen::Driver::LIBVIRT_VERSION
    config.enhancement_labels = 'enhancement,Enhancement,New Feature,Feature'.split(',')
    config.bug_labels = 'bug,Bug,Improvement'.split(',')
    config.exclude_labels = %w[invalid wontfix no_changelog]
  end
rescue LoadError
  task :changelog do
    raise 'github_changelog_generator not installed! gem install github_changelog_generator.'
  end
end
