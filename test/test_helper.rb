ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'minitest/reporters'
require 'minitest/spec'
Minitest::Reporters.use!
ActiveRecord::Base.logger.level = 1

class ActiveSupport::TestCase
	Rails.backtrace_cleaner.remove_silencers! # for messier errors

	# make fixtures available as a class variable so it's available in integration tests for looping thru
	# accessible points:
	# 	:name - name of fixture loaded
	# 	:application - parsed JSON blob of application data
	# 	:application_raw - raw string
	# 	:response - parsed JSON blob of application response
  @@fixtures = []
  Dir.glob(Rails.root.to_s + '/test/fixtures/*.json') do |file|
    puts 'loading ' + file
    json = File.read(file).to_s
    response = Application.new(json, 'application/json').to_json
    @@fixtures << {name: file.gsub(/\.json/,'').gsub(/#{Rails.root.to_s}\/test\/fixtures\//,''), application: JSON.parse(json), application_raw: json, response: JSON.parse(response)}
  end
end
