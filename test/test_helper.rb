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
  #   :name - name of fixture loaded
  #   :application - parsed JSON blob of application data
  #   :application_raw - raw string
  #   :response - parsed JSON blob of application response

  # def self.reload_fixtures
  #   @@fixtures = []
   #  Dir.glob(Rails.root.to_s + '/test/fixtures/*.json') do |file|
   #    # puts 'loading ' + file
   #    json = File.read(file).to_s
   #    response = Application.new(json, 'application/json').to_json
   #    @@fixtures << {name: file.gsub(/\.json/,'').gsub(/#{Rails.root.to_s}\/test\/fixtures\//,''), application: JSON.parse(json), application_raw: json, response: JSON.parse(response)}
   #  end
  # end  

  # # reload an individual fixture
  # def self.reload_fixture(fixture_name)
  #   Dir.glob(Rails.root.to_s + "/test/fixtures/#{fixture_name}.json") do |file| 
   #    puts 'loading ' + file
   #    json = File.read(file).to_s
   #    response = Application.new(json, 'application/json').to_json
   #    @@fixtures[@@fixtures.find_index { |f| f[:name] == fixture_name }] = {name: file.gsub(/\.json/,'').gsub(/#{Rails.root.to_s}\/test\/fixtures\//,''), application: JSON.parse(json), application_raw: json, response: JSON.parse(response)}
   #    p @@fixtures[@@fixtures.find_index { |f| f[:name] == fixture_name }][:application]['State']
   #  end
  # end

  # reload_fixtures 
end

def load_fixtures
  fixtures = []
  Dir.glob(Rails.root.to_s + '/test/fixtures/*.json') do |file|
    # puts 'loading ' + file
    json = File.read(file).to_s
    response = Application.new(json, 'application/json').to_json
    fixtures << {name: file.gsub(/\.json/,'').gsub(/#{Rails.root.to_s}\/test\/fixtures\//,''), application: JSON.parse(json), application_raw: json, response: JSON.parse(response)}
  end
  return fixtures
end

def reload_fixture(fixture_name, run_fixture=true)
  fixture = {}
  Dir.glob(Rails.root.to_s + "/test/fixtures/#{fixture_name}.json") do |file| 
    # puts 'loading ' + file
    json = File.read(file).to_s
    fixture = {name: file.gsub(/\.json/,'').gsub(/#{Rails.root.to_s}\/test\/fixtures\//,''), application: JSON.parse(json), application_raw: json}
    if run_fixture
      result = Application.new(json, 'application/json')
      fixture[:result] = result
      response = result.to_json
      fixture[:response] = JSON.parse(response)
    end
  end
  return fixture 
end

class MagiFixture
	include ApplicationComponents
	attr_accessor :magi, :test_sets

	def magi
		@magi = ""
	end

	def test_sets
		@test_sets = []
	end
end