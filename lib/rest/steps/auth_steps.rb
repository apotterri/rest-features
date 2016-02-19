Then /^I login as new user "(.*?)"$/ do |user|
  user.gsub!('$ns', @namespace)

  api_key = @conjur_api.create_user(user).api_key
  Conjur::Authn.save_credentials :username => user, :password => api_key
  @conjur_api = Conjur::Authn.connect
end

Then /^I login as admin$/ do
  Conjur::Authn.save_credentials :username => $admin_user, :password => $admin_password
  @conjur_api = Conjur::Authn.connect
end
