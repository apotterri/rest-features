# Add extract_field methods for "jsonfield"ish support
class Hash
  def extract_field head = nil, *tail
    return self unless head
    field_not_found! head unless has_key? head
    self[head].extract_field *tail
  end
end

class Array
  def extract_field head = nil, *tail
    return self unless head
    index = Integer(head) rescue field_not_found!(head)
    field_not_found! index if index >= size
    self[index].extract_field *tail
  end
end

class Object
  def extract_field head = nil, *tail
    field_not_found! head if head
    self
  end

  def field_not_found! field
    raise "No field #{field} in #{inspect}"
  end
end

class WSWorld
  include RSpec::Expectations
  include RSpec::Matchers

  def namespace
    @namespace
  end

  def http_authenticate
    require 'base64'
    @auth_header = "Token token=\"#{Base64.strict_encode64 @conjur_api.token.to_json}\""
  end

  def namespace_var var
    CGI.escape "#{namespace}/#{var}"
  end

end

World do
  WSWorld.new
end
