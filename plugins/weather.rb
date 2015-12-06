# Weather from da underground, yo

require 'cinch/cooldown'
require 'wunderground'
require 'time-lord'

require_relative 'irbot_plugin.rb'

class Weather < IrbotPlugin
  include Cinch::Plugin

  enforce_cooldown

  KEY = ENV['WUNDERGROUND_API_KEY']

  def match?(cmd)
    cmd =~ /^(.)?(^w)|(weather)$/
  end

  match(/w (.+)/, method: :weather, strip_colors: true)
  match(/weather (.+)/, method: :weather, strip_colors: true)

  def weather(m, location)
    if KEY
      wu = Wunderground.new(KEY)
      hash = wu.conditions_for(location)

      if hash['current_observation']
        loc = hash['current_observation']['display_location']['full']
        weather = hash['current_observation']['weather']
        temp = hash['current_observation']['temperature_string']
        humidity = hash['current_observation']['relative_humidity']
        wind_str = hash['current_observation']['wind_string']
        updated = Time.parse(hash['current_observation']['observation_time']).ago.to_words
        m.reply "Weather for #{loc}: #{weather} #{temp} Humidity: #{humidity} Wind: #{wind_str} (updated #{updated})", true
      else
        m.reply "Bad query for location \'#{loc}\'.", true
      end
    else
      m.reply 'Internal error (missing API key)'
    end
  end
end
