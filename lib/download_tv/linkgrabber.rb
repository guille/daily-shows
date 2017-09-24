module DownloadTV
  ##
  # Interface for the grabbers
  class LinkGrabber
    attr_reader :url

    def initialize(url)
      @url = url
      @agent = Mechanize.new
      @agent.user_agent = DownloadTV::USER_AGENT
    end

    def online?
      @agent.read_timeout = 2
      @agent.head(format(@url, 'test'))
      true
    rescue Mechanize::ResponseCodeError, Net::HTTP::Persistent::Error
      false
    end

    def get_links(_s)
      raise NotImplementedError
    end
  end
end
