require 'uri'

class Params
  def initialize(req, route_params={})
    @params = route_params
    @params.merge!(parse_www_encoded_form(req.query_string))
    @params.merge!(parse_www_encoded_form(req.body))
  end

  def [](key)
    @params[key]
  end

  def to_s
    @params.to_s
  end

  private
  def parse_www_encoded_form(www_encoded_form)
    return {} if www_encoded_form.nil?
    ary = URI.decode_www_form(www_encoded_form)
    {}.tap do |query_vals|
      ary.each do |val|
        keys = parse_key(val.first)
        hash = {}
        until keys.size == 1
          hash[keys.shift] = hash == {} ? val.last : hash
        end
        query_vals[keys.first] = hash == {} ? val.last : hash
      end
    end
  end

  def parse_key(key)
    regexp = /[^\]\[|\[|\]]+/
    keys = key.split("[]")
    keys.map { |k| k.match(regexp) }.map(&:to_s)
  end
end
