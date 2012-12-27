module Models
  class Track
    
    def initialize(params = {})
      @title = params[:title]
      @artists = params[:artists]
      @album = params[:album]
      @url = params[:url]
    end

    def title
      @title
    end

    def title=(t)
      @title = t
    end

    def album
      @album
    end

    def album=(a)
      @album = a
    end

    def artists
      @artists
    end

    def artists=(a)
      @artists = a
    end

    def url
      @url
    end

    def url=(u)
      @url = u
    end
  end
end