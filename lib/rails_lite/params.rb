require 'uri'

class Params
  def initialize(req, route_params)
    @params = route_params
    to_parse = [req.query_string, req.body]
    to_parse.each do |p|
      parsed = parse_www_encoded_form(p)
      @params.deep_merge!(parsed)
    end
    unless req.body.nil?
      params[:authenticity_token] ||= "NO FORM TOKEN"
    end
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
        query_vals.deep_merge!(nest_hash(keys, val.last))
      end
    end
  end

  def nest_hash(keys, value)
    hash = {}
    complete_hash = hash
    keys.each_with_index do |key, idx|
      hash[key.to_sym] = idx == keys.size - 1 ? value : {}
      hash = hash[key.to_sym]
    end

    complete_hash
  end

  def parse_key(key)
    regexp = /[^\]\[|\[|\]]+/
    keys = key.split("[")
    keys.map { |k| k.match(regexp) }.map(&:to_s)
  end
end
