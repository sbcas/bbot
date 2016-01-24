# look words up on urban dictionary with .ud

require 'json'
require 'open-uri'

require_relative 'irbot_plugin'

class UrbanDictionary < IrbotPlugin
  include Cinch::Plugin

  URL = 'http://api.urbandictionary.com/v0/define?term=%{query}'

  def match?(cmd)
    cmd =~ /^(.)?(ud)|(urban)$/
  end

  match /ud (.+)/, method: :urban_dict, strip_colors: true
  match /urban (.+)/, method: :urban_dict, strip_colors: true

  def urban_dict(m, phrase)
    query = URI.encode(phrase)
    url = URL % { query: query }

    begin
      hash = JSON.parse(open(url).read)

      if !hash['list'].nil?
        list = hash['list'].first
        definition = list['definition'][0..255].gsub(/[\r\n]/, '')
        link = list['permalinl']
        m.reply "#{phrase} - #{definition}... (#{link})", true
      else
        m.reply "Urban Dictionary has nothing for #{phrase}."
      end
    rescue Exception => e
      m.reply e.to_s, true
    end
  end
end
