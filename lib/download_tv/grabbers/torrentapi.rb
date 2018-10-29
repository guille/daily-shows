# frozen_string_literal: true

module DownloadTV
  ##
  # TorrentAPI.org grabber
  # Interfaces with http://torrentapi.org/apidocs_v2.txt
  class TorrentAPI < LinkGrabber
    attr_accessor :token
    attr_reader :wait

    def initialize
      super('https://torrentapi.org/pubapi_v2.php?'\
            'mode=search&search_string=%s&token=%s&'\
            'app_id=DownloadTV&sort=seeders')
      @wait = 0.1
    end

    ##
    # Specific implementation for TorrentAPI (requires token)
    def online?
      @agent.read_timeout = 2
      renew_token
      true
    rescue Mechanize::ResponseCodeError, Net::HTTP::Persistent::Error => e
      if e.response_code == '429'
        sleep(@wait)
        retry
      else
        false
      end
    end

    ##
    # Makes a get request tp the given url.
    # Returns the JSON response parsed into a hash
    def request_and_parse(url)
      page = @agent.get(url).content
      JSON.parse(page)
    end

    ##
    # Connects to Torrentapi.org and requests a token, returning it
    # Tokens automatically expire every 15 minutes
    def renew_token
      obj = request_and_parse('https://torrentapi.org/pubapi_v2'\
                              '.php?get_token=get_token&app_id='\
                              'DownloadTV')

      @token = obj['token']
    end

    def get_links(show)
      @token ||= renew_token

      search = format(@url, show, @token)

      obj = request_and_parse(search)

      if obj['error_code'] == 4 # Token expired
        renew_token
        search = format(@url, show, @token)
        obj = request_and_parse(search)
      end

      while obj['error_code'] == 5 # Violate 1req/2s limit
        sleep(@wait)
        obj = request_and_parse(search)
      end

      raise NoTorrentsError if obj['error']

      names = obj['torrent_results'].collect { |i| i['filename'] }
      links = obj['torrent_results'].collect { |i| i['download'] }

      names.zip(links)
    rescue Mechanize::ResponseCodeError => e
      if e.response_code == '429'
        sleep(@wait)
        retry
      else
        warn 'An unexpected error has occurred. Try updating the gem.'
        exit 1
      end
    end
  end
end
