class PagesController < ApplicationController

  def index
    @playlist = Models::Playlist.default
    @current_track = @playlist.current_track
    next_start_index = @playlist.current_track_index + 1
    @next_tracks = @playlist.tracks.slice(next_start_index, [@playlist.tracks.length, 10].min)
  end

  def queue
    track = Models::Track.new params
    playlist = Models::Playlist.default
    playlist.add_track track
    render nothing: true, status: 200, content_type: 'text/html'
  end

  def now_playing
    
  end

  def up_next
    
  end

end
