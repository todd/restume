require 'rubygems'
require 'bundler/setup'

require './main.rb'
require 'test/unit'
require 'yaml'

Bundler.setup

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
    # Test individual objects
    source.each do |k, v|
      assert resp.include?(k)
      # Exclude education and experience objects as they will not
      # be equivalent to their source representations.
      if k != 'education' and k != 'experience' then
        # Cast the last-updated date in the source to a string
        if k == 'last-updated' then
          v = v.to_s
        end
        assert_equal v, resp[k]
      end
    end
  end

  # Test the education resource
  def test_education
    get '/resume/education'
    assert last_response.ok?
    source = YAML.load(File.open('resume.yml'))['education']
    resp = JSON.load(last_response.body)
    assert_equal source, resp
  end

  # Test the education/:id resource
  def test_education_id
    source = YAML.load(File.open('resume.yml'))['education']
    (0..source.length()).each do |i|
      # Don't call resource if the iterator equals the length
      # of the array
      if i == source.length() then
        break
      end
      get '/resume/education/' + (i+1).to_s
      assert last_response.ok?
      resp = JSON.load(last_response.body)
      assert_equal source[i], resp
    end
  end

  # Test the experience resource
  def test_experience
    get '/resume/experience'
    assert last_response.ok?
    source = YAML.load(File.open('resume.yml'))['experience']
    resp = JSON.load(last_response.body)
    assert_equal source, resp
  end

  # Test the experience/:id resource
  def test_education_id
    source = YAML.load(File.open('resume.yml'))['experience']
    (0..source.length()).each do |i|
      # Don't call resource if the iterator equals the length
      # of the array
      if i == source.length() then
        break
      end
      get '/resume/experience/' + (i+1).to_s
      assert last_response.ok?
      resp = JSON.load(last_response.body)
      assert_equal source[i], resp
    end
  end

  # Test the activities resource
  def test_activities
    get '/resume/activities'
    assert last_response.ok?
    source = YAML.load(File.open('resume.yml'))['extra-curricular']
    resp = JSON.load(last_response.body)
    assert_equal source, resp
  end

  # Test the skills resource
  def test_skills
    get '/resume/skills'
    assert last_response.ok?
    source = YAML.load(File.open('resume.yml'))['technical-skills']
    resp = JSON.load(last_response.body)
    assert_equal source, resp
  end

  # Test the interests resource
  def test_interests
    get '/resume/interests'
    assert last_response.ok?
    source = YAML.load(File.open('resume.yml'))['interests']
    resp = JSON.load(last_response.body)
    assert_equal source, resp
  end
end
