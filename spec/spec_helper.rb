# encoding: UTF-8

require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start

require 'expert'
Expert.environment.require_all

require 'json'
require 'pry-nav'
require 'rspec'
require 'tmpdir'
require 'rosette/core'
require 'rosette/tms/filestore-tms'
require 'rosette/test-helpers'

RSpec.configure do |config|
  config.after(:each) do
    if respond_to?(:rosette_config)
      rosette_config.repo_configs.each do |repo_config|
        if tms = repo_config.tms
          # clean up after tests by deleting store files
          tms.phrase_store.delete
          tms.trans_stores.each_pair { |_, store| store.delete }
        end
      end
    end
  end
end

Rosette.logger = NullLogger.new
