# search youtube for stuff. what stuff? stuff.

require 'json'
require 'open-uri'

require_relative 'irbot_plugin'

class YouTubeSearch < IrbotPlugin
  include Cinch::Plugin

  KEY = ENV['YOUTUBE_API_KEY']
  URL = 'https://www.googleapis.com/youtube/v3/search?part=snippet&type=video&q=%{query}&key=%{key}'

  def match?(cmd)
    cmd =~ /^(.)?(youtube)|(yt)$/
  end

  match /yt (.+)/, method: :youtube_search, strip_colors: true

  def youtube_search(m, search)
    if KEY
      query = URI.encode(search)
      url = URL % { query: query, key: KEY }

      begin
        hash = JSON.parse(open(url).read)
        hash.default = '?'

        if !hash['items'].nil?
          entry = hash['items'].first
          title = entry['snippet']['title']
          video_id = entry['id']['videoId']

          m.reply "#{title} - https://youtu.be/#{video_id}", true
        else
          m.reply "No results for #{search}.", true
        end
      rescue Exception => e
        m.reply e.to_s, true
      end
    else
      m.reply 'Internal error (missing API key).'
    end
  end
end
