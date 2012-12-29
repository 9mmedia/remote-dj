class SearchesController < ApplicationController

  def show
    @query = params[:q]
    spotify = Services::Spotify.new
    @results = spotify.search_tracks @query
  end

end
