class AlbumArtController < ApplicationController

  # HTTP GET 
  # arguments: uri - Spotify Album URI
  def get_album_art
    ret_val = nil

    resp = HTTParty.get("http://ws.spotify.com/lookup/1/.json?uri=#{params[:uri]}")
    raise ActionController::RoutingError.new('Not Found') if resp.code != 200
    
    spotify_response = JSON.parse(resp.body)
    search_response = nil
    resp = HTTParty.get(URI::escape("http://api.discogs.com/database/search?artist=#{spotify_response['album']['artist']}&release_title=#{spotify_response['album']['name']}&type=releases"))
    raise ActionController::RoutingError.new('Not Found') if resp.code != 200


    if resp then
      search_results = JSON.parse(resp.body)
      album_id = search_results['results'][0]['id']
      resp = HTTParty.get("http://api.discogs.com/releases/#{album_id}")
      raise ActionController::RoutingError.new('Not Found') if resp.code != 200
      album_result = JSON.parse(resp.body)
      ret_val = album_result['images'][0]['uri']
    end
    render :text => ret_val
  end

end
