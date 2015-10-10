# Wolfram|Alpha plugin

require 'wolfram'

class WolframAlpha
  include Cinch::Plugin

  KEY = ENV['WOLFRAM_ALPHA_APPID_KEY']

  def usage
    '.wa <query> - Query Wolfram|Alpha about something'
  end

  match /wa (.+)/, method: :wolfram_alpha, strip_colors: true

  def wolfram_alpha(m, query)
    if KEY
      Wolfram.appid = KEY
      result = Wolfram.fetch(query).pods[1]

      if result && !result.plaintext.empty?
        m.reply result.plaintext.gsub(/[\t\r\n]/, ''), true
      else
        m.reply "Wolfram|Alpha has nothing for #{query}", true
      end
      m.reply 'Internal error (missing API key)'
    end
  end
end
