require 'securerandom'

module Models
  
  # Note: currently using track URLs to determine uniqieness.  Might now be ideal if we draw these lists from more than one service.
  class Playlist
    
    attr_accessor :tracks, :current_track_index

    @@lock = Mutex.new

    # Returns the default playlist for the app
    def self.default
      # Create a stub with the default ID
      list = Playlist.new([], "default", false)
      # Load properties from cache and return
      list.reload
      list
    end


    def save
      @@lock.synchronize do 
      	@id ||= SecureRandom.uuid
        # Create new cache version
      	@cache_version = SecureRandom.uuid
        Rails.cache.write(cache_key, self, {:namespace => Rails.env})
        # Update cache version
        Rails.cache.write(cache_version_key, @cache_version, {:namespace => Rails.env})
      end
    end

    def reload
      if (!caller.any?{|c| c =~ /\/playlist\.rb.*`reload'/})  # Check for recursion
        require_dependency 'lib/models/track'
      	@@lock.synchronize do 
          if (@id)
            # Check cache version first
            version = Rails.cache.read(cache_version_key, {:namespace => Rails.env})
            if (version && (version != @cache_version))
              @cache_version = version
              list = Rails.cache.read(cache_key, {:namespace => Rails.env})
        	    if (list)
        	      @tracks = list.tracks
        	      @current_track_index = list.current_track_index
        	    end
            end
      	  end
        end
      end
    end

    def initialize(tracks = [], id = nil, save_on_create=true)
      @tracks = tracks
      @current_track_index = 0
      @id = id
      save if save_on_create
    end

    # Returns the current track
    def current_track
      reload
      @tracks[@current_track_index]
    end

    # Sets the current track in this playlist to the given track.  Will add the track to to the playlist if it isn't already included.
    def current_track=(track)
      if (track)
        reload
        idx = index(track.url)
        if (idx)
      	  @current_track_index = idx
        else
      	  add_track(track)
      	  @current_track_index = @tracks.count - 1
        end
        save
      end
    end

    # Returns the current track index
    def current_track_index
      reload
      @current_track_index
    end

    # Sets the current track index
    def current_track_index=(index)
      reload
      @current_track_index = index
      save
    end

    # Returs the tracks in this playlist
    def tracks
      reload
      @tracks
    end

    # Sets the track list for this playlist.  Resets the current index to 0
    def tracks=(tracks)
      reload
      @tracks = track
      @current_track_index = 0
      save
    end

    # Returns the track immediately preceding the current track in this playlist
    def previous_track
      reload
      (@current_track_index > 0 ? @tracks[@current_track_index - 1] : nil)
    end

    # Returns the track immediately following the current track in this playlist
    def next_track
      reload
      @tracks[@current_track_index + 1]
    end

    # Adds the given track to the playlist
    def add_track(track)
      reload
      @tracks << track
      save
    end

    # Returns the index of the given track in the playlist, or nil if the track was not found.
    def index(url)
      reload
      @tracks.map(&:url).index(url)
    end

    private

    def cache_key
      "playlist:#{@id}"
    end

    def cache_version_key
      "playlist:#{@id}:version"
    end
  end
end