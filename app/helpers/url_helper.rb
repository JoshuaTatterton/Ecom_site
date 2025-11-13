module UrlHelper
  # Modifies the uri params.
  # uri - URI object
  # params - Hash, flat object e.g. { "page[per]" => 2 }
  def self.add_params(uri, params)
    params = Hash[URI.decode_www_form(uri.query || "") + params.to_a]
    uri.query = params.map { |(key, value)|
      "#{key}=#{value}"
    }.join("&")
    uri
  end
end
