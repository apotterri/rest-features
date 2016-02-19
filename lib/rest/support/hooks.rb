require 'conjur/authn'

$admin_user,$admin_password = Conjur::Authn.get_credentials
raise "Not logged in to Conjur" unless $admin_user && $admin_password

Before do
  Conjur::Authn.save_credentials username: $admin_user, password: $admin_password

  @conjur_api = Conjur::Authn.connect

  $ns = @namespace = @conjur_api.create_variable("text/plain", "id").id
  Cucumber::logger.debug "namespace: #{@namespace}"
end

at_exit do
  Conjur::Authn.save_credentials username: $admin_user, password: $admin_password
end

