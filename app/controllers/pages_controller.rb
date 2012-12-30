class PagesController < ApplicationController

  def index
    @playlist = Models::Playlist.default
    @current_track = @playlist.current_track
    next_start_index = @playlist.current_track_index + 1
    @next_tracks = @playlist.tracks.slice(next_start_index, @playlist.tracks.length)
  end

  def queue
    track = Models::Track.new params
    playlist = Models::Playlist.default
    playlist.add_track track
    render nothing: true, status: 200, content_type: 'text/html'
  end

  def current_playlist
    current_playlist = Models::Playlist.default
    if( params[:current_index] ) then
      index = params[:current_index].to_i
      if( current_playlist.tracks.length > index ) then
        current_playlist.current_track_index = index
      end
    end
    render :json => current_playlist
  end

end
