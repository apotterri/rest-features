require 'httparty'
require 'hashie'

CLIENT_IP_ADDRESS='1.2.3.4'
When /^I (\w+) "(.*?)"(?:(?: with data "(.*?)")|(?: with privilege "(.*?)"))?$/ do |method, path, data, privilege|
  http_authenticate
  url = "#{$service_url}#{path.gsub('$ns', namespace)}"

  options = {
    :verify => false,
    :headers => {
      # Use a routable (though bogus) IP address. If we don't do this,
      # and authz is running in a VM (e.g. in a docker container on a
      # Mac), Rack::Request#ip returns 127.0.0.1
      'X-Forwarded-For' => CLIENT_IP_ADDRESS,
      "Accept" => 'application/json',
      "Authorization" => @auth_header
    }
  }
  options.merge!(:body => JSON.parse(data)) if data
  options[:headers].merge!('X-Conjur-Privilege' => privilege ) if privilege

  @response = HTTParty.send(method.downcase.to_sym, url, options)
end

Then /^the request should succeed$/ do
  expect(200...300).to cover(@response.code.to_i)
end

Then /^the response should be "(.*)"$/ do |resp|
  expect(@response.body).to eq(resp)
end

Then /^the request should fail(?: with status "(.*?)")?$/ do |status|
  if status
    expect(@response.code.to_i).to eq(status.to_i)
  else
    expect(@response.code.to_i).to be >= 400
  end
end

Then /^the response (has|does not have) the field "(.*?)"(?: with value matching "(.*)")?$/ do |assert, key, value|
  json = JSON.parse(@response.body).extend Hashie::Extensions::DeepFind
  Cucumber::logger.debug "body: #{json}"

  field = json.deep_find_all(key.gsub('$ns', namespace))
  expect(field).to be_present
  
  if value
    value.gsub!('$ns', namespace)
    expect(field).to satisfy("#{assert} a value matching #{value}") do |values| 
      values.send(assert == "has" ? :any? : :none?) { |v| v.match(value) }
    end
  end
end

Then /^the response has the field "(.*?)" which matches the IP address$/ do |key|
  step %Q{the response has the field "#{key}" with value matching "#{CLIENT_IP_ADDRESS}"}
end

Then /^the response has JSON field "(.*?)" with value "(.*?)"$/ do |field, expected|
  json = JSON.parse(@response.body)
  Cucumber::logger.debug "body: #{json}"

  actual = json.extract_field(*(field.split '.', -1))
  expect(actual).to eq(expected)
end

Then /^the response (has|does not have) the header "(.*?)"(?: with value matching "(.*)")?$/ do |assert, key, value|
  Cucumber::logger.debug "headers: #{@response.headers.inspect}"

  expect(@response.headers[key]).to satisfy("#{assert} the header)") { |v|
    v.send(assert == "has" ? :present? : :nil?)
  }
  expect(@response.headers[key]).to match(value) if value
end

# 2015-12-16T22:32:02Z
Then /^the response (has|does not have) the header "(.*?)" with an ISO8601 value$/ do |assert, key|
  r = %r{\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z}
  step %Q{the response #{assert} the header "#{key}" with value matching "#{r}"}
end
