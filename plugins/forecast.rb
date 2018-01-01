# Weather from da underground, yo

require 'cinch/cooldown'
require 'wunderground'
require 'time-lord'

require_relative 'bbot_plugin.rb'

class Forecast < BbotPlugin
  include Cinch::Plugin

  enforce_cooldown

  KEY = ENV['WUNDERGROUND_API_KEY']

  def match?(cmd)
    cmd =~ /^(.)?(^f)|(forecast)$/
  end

  match(/f (.+)/, method: :forecast, strip_colors: true)
  match(/forecast (.+)/, method: :forecast, strip_colors: true)

  def forecast(m, location)
    if KEY
      wu = Wunderground.new(KEY)
      hash = wu.forecast_for(location)

      if hash['forecast']

        fc         = hash['forecast']['txt_forecast']

        fd         = fc['forecastday'][0]
        fn         = fc['forecastday'][1]
        updated    = Time.parse(fc['date']).ago.to_words
        day        = fd['title']
        night      = fn['title']
        fctd       = fd['fcttext']
        fctn       = fn['fcttext']

        reply_data = "#{day} conditions will be: #{fctd}" \
                     "#{night} conditions: #{fctn} (updated #{updated})"

        m.reply reply_data, true
      else
        m.reply "Bad query for location \'#{loc}\'.", true
      end
    else
      m.reply 'Internal error (missing API key)'
    end
  end
end
