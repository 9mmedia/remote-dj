class AdminController < ApplicationController

  def index
    @playlist = Models::Playlist.default
    next_start_index = @playlist.current_track_index + 1
    @tracks = @playlist.tracks.slice(next_start_index, @playlist.tracks.length)
  end

  def delete_tracks
    @playlist = Models::Playlist.default

    params[:trackIds].each do |id|
      index = @playlist.index id
      @playlist.tracks.delete_at index
    end

    @playlist.save

    redirect_to admin_index_path
  end

end
