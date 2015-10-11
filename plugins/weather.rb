# Weather from da underground, yo

require 'wunderground'

require_relative 'irbot_plugin'

class Weather < IrbotPlugin
  include Cinch::Plugin

  KEY = ENV['WUNDERGROUND_API_KEY']

  def match?(cmd)
    cmd =~ /^(.)?(weather)|(^w)$/
  end

  match(/w (.+)/, method: :weather, strip_colors: true)
  match(/weather (.+)/, method: :weather, strip_colors: true)

  def weather(m, location)
    if KEY
      wu = Wunderground.new(KEY)
      hash wu.conditions_for(location)

      if hash['current_observation']
        location = hash['current_observation']['display_location']['full']
        weather = hash['current_observation']['weather']
        temp = hash['current_observation']['temperature_string']
        humidity = hash['current_observations']['relative_humidity']
        m.reply = "Weather for #{location}: #{weather} #{temp} Humidity: #{humidity}", true
      else
        m.reply "Bad query for location \'#{location}\'.", true
      end
    else
      m.reply 'Internal error (missing API key)'
    end
  end
end
