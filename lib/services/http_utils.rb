require 'addressable/uri'
require 'net/http'

module Services
  module HttpUtils

  	# Grokked a bit of the logic form here: http://stackoverflow.com/questions/6934185/ruby-net-http-following-redirects
    def http_get (url_str, redirect_limit = 10, visited_urls = [])
      url = parse_url(url_str)
      visited_urls << url
      request = Net::HTTP::Get.new(url.path + (url.query.nil? ? "" : "?#{url.query}"),
        {"accept-encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3"})
      http = get_http_connection(url) 
      response = http.start {|http| http.request(request) }
      if (response.is_a?Net::HTTPRedirection)
        raise ArgumentError.new "Too many redirects" if redirect_limit == 0
        # For now. Only merge scheme and host if location lacks them
        location_uri = Addressable::URI.parse(response['location'])
        uri = Addressable::URI.parse(url)
        location_uri.scheme ||= uri.scheme
        location_uri.host ||= uri.host
        url = location_uri.to_s

        response = http_get(url, redirect_limit - 1, visited_urls)
      else
        response['spotdock-resolved-url'] = url
      end
      response['spotdock-visited-urls'] = visited_urls
      response
    end 

    # Converts the given string to a URL object.
    def parse_url(url_str)
      url = Addressable::URI.parse(url_str)
      url.path.empty? ? url.path = "/" : url.path
      url
    end
 
    # Invoked by #http_get and #http_head
    def get_http_connection(url)
      http = Net::HTTP.new(url.host, (url.port || url.inferred_port))
      if (url.scheme == "https")
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end

      http
    end

    # Parses the body of the given HTTP response object.  
    def get_body(response)

      # For now, check for gzip encoding.  May have to add other checks in the future. If so we may have to
      # get a little cleaner about how we handle this
        
      # Grokked from http://stackoverflow.com/questions/4811829/use-ruby-to-get-content-length-of-urls
      headers = response.to_hash
      body = response.body
      
      content_encoding = (headers['content-encoding'] ? headers['content-encoding'][0] : "")
      case content_encoding
      
      when "gzip"
        body = Zlib::GzipReader.new(StringIO.new(body)).read
      when "deflate"
        body = Zlib::Inflate.new(-Zlib::MAX_WBITS).inflate(body)
      end 
          
      body
    end

  end
end