require 'main'
require 'test/unit'
require 'rack/test'
require 'yaml'
require 'json'

ENV['RACK_ENV'] = 'test'

class AppTest < Test::Unit::TestCase
  include Rack::Test::Methods
  
  def app
    Sinatra::Application
  end
  
  # Test base resource
  def test_resume
    get '/resume'
    assert last_response.ok?
    source = YAML.load(File.open('resume.yml'))
    resp = JSON.load(last_response.body)
    # Number of objects in response should be the same as
    # number of objects in the source YAML file.
    assert_equal source.length(), resp.length()
  end
end