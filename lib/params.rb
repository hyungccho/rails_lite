require 'uri'

class Params
  # use your initialize to merge params from
  # 1. query string
  # 2. post body
  # 3. route params
  #
  # You haven't done routing yet; but assume route params will be
  # passed in as a hash to `Params.new` as below:
  def initialize(req, route_params = {})
    @params = route_params
    parse_www_encoded_form(req.query_string)
    parse_www_encoded_form(req.body)
  end

  def [](key)
    @params[key.to_s] || @params[key.to_sym]
  end

  # this will be useful if we want to `puts params` in the server log
  def to_s
    @params.to_s
  end

  def require(model)
    @params = @params.select { |key, value| key == model}
  end

  def permit(*args)
    h = {}

    args.each do |key|
      el = @params.find { |k, v| k == key }
      h[el[0]] = h[el[1]]
    end

    @params = h
  end

  class AttributeNotFoundError < ArgumentError; end;

  private
  # this should return deeply nested hash
  # argument format
  # user[address][street]=main&user[address][zip]=89436
  # should return
  # { "user" => { "address" => { "street" => "main", "zip" => "89436" } } }
  def parse_www_encoded_form(www_encoded_form)
    return if www_encoded_form.nil?

    URI::decode_www_form(www_encoded_form).each do |pair|
      target = @params
      keys = parse_key(pair[0])

      keys.each_with_index do |key, i|
        if i != keys.length - 1
          target[key] = {} if target[key].nil?
          target = target[key]
        elsif i == keys.length - 1
          target[key] = pair[1]
        end
      end
    end
  end

  # this should return an array
  # user[address][street] should return ['user', 'address', 'street']
  def parse_key(key)
    split_key = key.split(/\]\[|\[|\]/)
    split_key
  end
end
