# Large portions of this code are grokked from https://github.com/rdio/rdio-simple/blob/master/ruby/rdio.rb.  Hence, the licensing spiel below:

# (c) 2011 Rdio Inc
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require 'uri'
require 'cgi'
require 'digest'
require 'digest/sha1'

module Services
  class Rdio
  	include Utils

    # Support consumer level auth ONLY at this point
    
    def initialize()
      consumer_key = env('RDIO_CONSUMER_KEY')
      consumer_secret = env('RDIO_CONSUMER_SECRET')
      @consumer = [consumer_key, consumer_secret]
    end

    # Searches for tracks based on the given query string.
  	# 
  	#
  	# @params
  	# query:: A query string (e.g., 'Elvis', 'Rolling Stones', 'Stairway to Heaven'). Required.
  	# offset:: Optional. The offset of the first result to return.
  	# count:: Optional.
    def search_tracks(query, offset=0,count=nil)
      params = {
      	"query" => query,
      	"types" => "Track",
      	"start" => offset
      }
      params["count"] = count if count

      hash = call("search", params)
      
      to_tracks(nested_lookup(hash, "result", "results") || [])
    end

    private

    def call(method, params={})
      # make a copy of the dict
      params = params.clone
      # put the method in the dict
      params['method'] = method
      # call to the server and parse the response
      return JSON.load(signed_post('http://api.rdio.com/1/', params))
    end

  
    def signed_post(url, params)
      auth = om(@consumer, url, params, @token)
      url = URI.parse(url)
      http = Net::HTTP.new(url.host, url.port)
      req = Net::HTTP::Post.new(url.path, {'Authorization' => auth})
      req.set_form_data(params)
      res = http.request(req)
      return res.body
    end

    def method_missing(method, *params)
      call(method.to_s, params[0])
    end

    def env(key)
      value = ENV[key]
      raise "ENV variable '#{key}' not set." unless value
      value
    end

    # Converts raw tracks from Rdio to our track model
    def to_tracks(raw_tracks)
      result = []
      for raw_track in raw_tracks do
      	result << to_track(raw_track)
      end

      result
    end

    # Converts a raw track to our model
    def to_track(raw_track)
      Models::Track.new(
        {
        	:title => raw_track["name"],
        	:album => raw_track["album"],
        	:artists => [raw_track["artist"]],
        	:url => raw_track["url"]
        }
      )
    end


    # Ginormous simple oauth impl grokked from https://github.com/rdio/rdio-simple/blob/master/ruby/rdio.rb (See top of file).
    def om(consumer, url, post_params, token=nil, method='POST', realm=nil, timestamp=nil, nonce=nil)
      # A one-shot simple OAuth signature generator

      # the method must be upper-case
	  method = method.upcase

	  # we want params as an Array of name / value pairs
	  if post_params.is_a?(Array)
        params = post_params
	  else
	    params = post_params.collect { |x| x }
	  end

	  # we want those pairs to be strings
	  params = params.collect { |k,v| [k.to_s, v.to_s]}

	  # normalize the URL
	  url = URI.parse(url)
	  # scheme is lower-case
	  url.scheme = url.scheme.downcase
	  # remove username & password
	  url.user = url.password = nil
	  # host is lowercase
	  url.host = url.host.downcase

	  # add URL params to the params
	  if url.query
	    CGI.parse(url.query).each { |k,vs| vs.each { |v| params.push([k,v]) } }
	  end

	  # remove the params and fragment
	  url.query = nil
	  url.fragment = nil

	  # add OAuth params
	  params = params + [
	    ['oauth_version', '1.0'],
	    ['oauth_timestamp', timestamp || Time.now.to_i.to_s],
	    ['oauth_nonce', nonce || rand(1000000).to_s],
	    ['oauth_signature_method', 'HMAC-SHA1'],
	    ['oauth_consumer_key', consumer[0]],
	  ]

	  # the consumer secret is the first half of the HMAC-SHA1 key
	  hmac_key = consumer[1] + '&'

	  if token != nil
        # include a token in params
        params.push ['oauth_token', token[0]]
        # and the token secret in the HMAC-SHA1 key
        hmac_key += token[1]
      end

      def percent_encode(s)
        if s.respond_to?(:encoding)
          # Ruby 1.9 knows about encodings, convert the string to UTF-8
          s = s.encode(Encoding::UTF_8)
        else
          # Ruby 1.8 does not, just check that it's valid UTF-8
          begin
            $__om_utf8_checker.iconv(s)
          rescue Iconv::IllegalSequence => exception
            throw ArgumentError.new("Non-UTF-8 string: "+s.inspect)
          end
        end
        chars = s.bytes.map do |b|
          c = b.chr
          if ((c >= '0' and c <= '9') or
              (c >= 'A' and c <= 'Z') or
              (c >= 'a' and c <= 'z') or
              c == '-' or c == '.' or c == '_' or c == '~')
            c
          else
            '%%%02X' % b
          end
        end
        chars.join
      end

      # Sort lexicographically, first after key, then after value.
      params.sort!
      # escape the key/value pairs and combine them into a string
      normalized_params = (params.collect {|p| percent_encode(p[0])+'='+percent_encode(p[1])}).join '&'

      # build the signature base string
      signature_base_string = (percent_encode(method) +
                           '&' + percent_encode(url.to_s) +
                           '&' + percent_encode(normalized_params))

      # HMAC-SHA1
      hmac = Digest::HMAC.new(hmac_key, Digest::SHA1)
      hmac.update(signature_base_string)

      # Calculate the digest base 64. Drop the trailing \n
      oauth_signature = [hmac.digest].pack('m0').strip

      # Build the Authorization header
      if realm
        authorization_params = [['realm', realm]]
      else
        authorization_params = []
      end
      authorization_params.push(['oauth_signature', oauth_signature])

      # we only want certain params in the auth header
      oauth_params = ['oauth_version', 'oauth_timestamp', 'oauth_nonce',
                  'oauth_signature_method', 'oauth_signature',
                  'oauth_consumer_key', 'oauth_token']
      authorization_params.concat(params.select { |param| nil != oauth_params.index(param[0]) })

      return 'OAuth ' + (authorization_params.collect {|param| '%s="%s"' % param}).join(', ')
    end
  end
end
