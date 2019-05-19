# frozen_string_literal: true

require 'open_api'

desc 'Generate openapi V3 documentation'
namespace :documentation do
  task :generate => :environment do
    OpenApi.write_docs
  end
end

task :test => 'documentation:generate'
