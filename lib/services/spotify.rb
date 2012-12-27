
module Services
  class Spotify
  	include HttpUtils
  	include Utils

  	# Searches for track based on the given query string.
  	# 
  	#
  	# @params
  	# q:: A query string (e.g., 'Elvis', 'Rolling+Stones', 'Stairway+to+Heaven'). Required.
  	# page:: The page number of results to return.  Defaults to 1.
  	def searchForTracks(q, page=1)
  	  response_body = get_body(http_get("http://ws.spotify.com/search/1/track.json?q=#{q}&page=#{page}"))
  	  json = ActiveSupport::JSON.decode(response_body)
      to_tracks(json["tracks"])
  	end

    private

    # Converts raw track objects returned from Spotify to our model
    def to_tracks(raw_tracks)
      result = []
      raw_tracks.each do |raw_track|
      	result << to_track(raw_track)
      end

      return result
    end

    # Converts a raw track object returned from Spotify to our model
    def to_track(raw_track)
      Models::Track.new( 
        {
          :url => raw_track["href"],
          :title => raw_track["name"],
          :album => nested_lookup(raw_track, "album","name"),
          :artists => to_artists(raw_track["artists"])
        }
      )
    end

    # Converts raw artist array to an array of artist names
    def to_artists(raw_artists)
      result = []
      raw_artists.each do |raw_artist|
      	result << raw_artist["name"]
      end

      result
    end
  end
end
