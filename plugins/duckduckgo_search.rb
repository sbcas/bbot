# search duckduckgo from irbot. why? because.

require 'json'
require 'open-uri'

require_relative 'irbot_plugin'

class DuckDuckGoSearch < IrbotPlugin
  include Cinch::Plugin

  URL = "https://api.duckduckgo.com/?q=%{query}&format=json&no_html=1&no_redirect=1"

  match /g(?:o)? (.+)/, method: :duckduckgo_search, strip_colors: true

  def duckduckgo_search(m, search)
    query = URI.encode(search)
    url = URL % { query: query }

    begin
      results = JSON.parse(open(url).read)

      if results['Results']
        site = URI.unescape(results['AbstractURL'])
        content = results['Heading']
        m.reply "#{content} - #{site}", true
      else
        m.reply "No DuckDuckGo results for #{search}.", true
      end
    rescue Exception => e
      m.reply e.to_s, true
    end
  end
end
