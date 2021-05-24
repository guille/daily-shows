# frozen_string_literal: true

module DownloadTV
  ##
  # Interface for the grabbers
  class LinkGrabber
    attr_reader :url

    def initialize(url)
      @url = url
      @agent = Mechanize.new do |a|
        a.user_agent = DownloadTV::USER_AGENT
        a.read_timeout = 2
      end
    end

    def online?
      url = if @url.include? '%s'
              format(@url, 'test')
            else
              @url
            end
      @agent.head(url)
      true
    rescue Mechanize::ResponseCodeError, Net::HTTP::Persistent::Error, Errno::ECONNRESET
      false
    end

    def get_links(_show)
      raise NotImplementedError
    end
  end
end
