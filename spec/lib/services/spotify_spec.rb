require 'spec_helper'

describe Services::Spotify do

  before(:each) do
    @api = Services::Spotify.new
  end


  it "should return results for album search" do
    results = @api.search_tracks("Beggars Banquet")
    results.count.should > 0
    results_found = false
    # We should have some results that reference the album
    for result in results do
      if (result.album =~ /Beggars\s+Banquet/i)
        results_found = true
        break
      end
    end
    results_found.should be_true
  end

  it "should return results for artist search" do
    results = @api.search_tracks("Rolling Stones")
    results.count.should > 0
    results_found = false
    break_outer = false
    # We should have some results that reference the artist
    for result in results do
      break if break_outer
      for artist in result.artists do
        if (artist =~ /Rolling\s+Stones/)
          results_found = true
          break_outer = true
          break
        end
      end
    end
    results_found.should be_true
  end

  it "should return results for track title search" do
    results = @api.search_tracks("Sympathy Devil")
    results.count.should > 0
    results_found = false
    # We should have some results that reference the title
    for result in results do
      if (result.title =~ /Sympathy/)
        results_found = true
        break
      end
    end
    results_found.should be_true
  end

  it "should return correct page of results" do
    # For now just verify that we get different results for each page
    result_set = Set.new
    (1..10).each do |i|
      results = @api.search_tracks("Rolling Stones", i)
      urls = results.map(&:url)
      for url in urls
        result_set << url
      end
    end
    
    result_set.count.should == 1000
  end

end
