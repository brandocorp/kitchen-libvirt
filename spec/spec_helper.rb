# -*- encoding: utf-8 -*-
#
# Author:: Brandon Raabe (<brandocorp@gmail.com>)
#
# Copyright:: 2018, Brandon Raabe
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

if ENV["CODECLIMATE_REPO_TOKEN"]
  require "codeclimate-test-reporter"
  CodeClimate::TestReporter.start
elsif ENV["COVERAGE"]
  require "simplecov"
  SimpleCov.profiles.define "gem" do
    command_name "Specs"

    add_filter ".gem/"
    add_filter "/spec/"

    add_group "Libraries", "/lib/"
  end
  SimpleCov.start "gem"
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.filter_run :focus
  config.run_all_when_everything_filtered = true
  config.disable_monkey_patching!
  config.warnings = true

  if config.files_to_run.one?
    config.default_formatter = "doc"
  end

  config.order = :random

  Kernel.srand config.seed

  config.expose_dsl_globally = true

end

require "fog/libvirt"
require "support/fog"
