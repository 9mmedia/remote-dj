require 'spec_helper'

describe Services::Rdio do

  before(:each) do
    @api = Services::Rdio.new
  end

  it "should return results for an album search" do
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

  it "should return results for an artist search" do
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

  it "should return results for a track title search" do
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

  it "should limit results to the requested count" do
    results = @api.search_tracks("Rolling Stones", 0, 10)
    results.count.should == 10
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

  it "should return results starting at specified offset" do
    results0 = @api.search_tracks("Rolling Stones", 0, 10)
    results1 = @api.search_tracks("Rolling Stones", 1, 10)
    results2 = @api.search_tracks("Rolling Stones", 2, 10)
    results0[1].url.should == results1[0].url
    results1[1].url.should == results2[0].url
  end
end
