require 'spec_helper'

describe Models::Playlist do

  before (:each) do
    @tracks = [
       Models::Track.new(:title => "Bernadette", :artists => ["The Four Tops"], :album => "The Four Tops Greatest Hits", :url => "foo:bar:blah"),
       Models::Track.new(:title => "(I Know) I'm Losing You", :artists => ["The Temptations"], :album => "The Best of The Temptations", :url => "foo:bar:blag"),
       Models::Track.new(:title => "The Tracks of My Tears", :artists => ["The Miracles"], :album => "Whatever", :url => "foo:bar:blab")

    ]

    # Clear cache
    Rails.cache.clear
  end

  after(:each) do
  	Rails.cache.clear
  end

  it "should initialize a playlist with an an array of tracks" do
  	playlist = Models::Playlist.new(@tracks)
  	playlist.current_track_index == 0
  	playlist.current_track.title.should == "Bernadette"
  	playlist.next_track.title.should == "(I Know) I'm Losing You"
  	playlist.previous_track.should == nil
  end

  it "should support adding tracks" do
    playlist = Models::Playlist.new(@tracks)
    playlist.tracks.count.should == 3
    playlist.add_track(Models::Track.new(:title => "I Want to Tell You", :artists => ["The Beatles"], :album => "Revolver", :url => "foo:bar:fab"))
    playlist.tracks.count.should == 4
    playlist.tracks.last.title.should == "I Want to Tell You"
  end

  it "should support an index method" do
  	playlist = Models::Playlist.new(@tracks)
    playlist.index(@tracks[0]).should == 0
    playlist.index(@tracks[2]).should == 2
    playlist.index(@tracks[1]).should == 1
  end

  it "should set the current track with a song already in the list" do
  	playlist = Models::Playlist.new(@tracks)
  	playlist.current_track = @tracks[1]
  	playlist.current_track.title.should == "(I Know) I'm Losing You"
  	playlist.next_track.title.should == "The Tracks of My Tears"
  	playlist.previous_track.title.should == "Bernadette"
  end

  it "should set the current track using a song not in the list" do
    playlist = Models::Playlist.new(@tracks)
    playlist.current_track = Models::Track.new(:title => "I Want to Tell You", :artists => ["The Beatles"], :album => "Revolver", :url => "foo:bar:fab")
    playlist.current_track.title.should == "I Want to Tell You"
  	playlist.next_track.should == nil
  	playlist.previous_track.title.should == "The Tracks of My Tears"
  end

  it "should support a default instance" do
  	default = Models::Playlist.default
  	default.tracks.should == []
  	default.current_track_index = 0

  	# Lets add tracks
  	default.add_track(@tracks[0])
  	default.add_track(@tracks[1])
  	default.add_track(@tracks[2])
  	default.current_track_index = 1
  	default.tracks.count.should == 3
  	default.current_track.title.should == "(I Know) I'm Losing You"

  	# Retrieve default again and verify updates
  	default = Models::Playlist.default
  	default.tracks.count.should == 3
  	default.current_track.title.should == "(I Know) I'm Losing You"

    default.tracks.slice(0,3)
    default.tracks.slice(0,10)
    default.tracks.slice(0,3)
    default.tracks.slice(0,10)

  end


end