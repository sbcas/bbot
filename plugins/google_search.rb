# search google from irbot. why? because.

require 'json'
require 'open-uri'

require_relative 'irbot_plugin'

class GoogleSearch < IrbotPlugin
  include Cinch::Plugin

  URL = 'https://ajax.googleapis.com/ajax/services/search/web?v=1.0&rsz=small&safe=off&q=%{query}&max-results=1&v=2&alt=json'

  match /g(?:oogle)? (.+)/, method: :google_search, strip_colors: true

  def google_search(m, search)
    query = URI.encode(search)
    url = URL % { query: query }

    begin
      hash = JSON.parse(open(url).read)

      if !hash['responseData']['results'].nil?
        site = URI.unescape(hash['responseData']['results'].first['url'])
        content = hash['responseData']['results'].first['content'].gsub(/([\t\r\n])|(<(\/)?b>)/, '')
        content.gsub!(/(&amp;)|(&quot;)|(&lt;)|(&gt;)|(&#39;)/, '&amp;' => '&', '&quot;' => '"', '&lt;' => '<', '&gt;' => '>', '&#39;' => '\'')
        m.reply "#{site} - #{content}", true
      else
        m.reply "No Google results for #{search}.", true
      end
    rescue Exception => e
      m.reply e.to_s, true
    end
  end
end
