# Wolfram|Alpha plugin

require 'wolfram'

require_relative 'bbot_plugin.rb'

class WolframAlpha < BbotPlugin
  include Cinch::Plugin

  KEY = ENV['WOLFRAM_ALPHA_APPID_KEY']

  match(/(?:wa|wolfram) (.+)/, method: :wolfram_alpha, strip_colors: true)

  def wolfram_alpha(m, query)
    if KEY
      Wolfram.appid = KEY
      result = Wolfram.fetch(query).pods[1]

      if result && !result.plaintext.empty?
        m.reply result.plaintext.gsub(/[\t\r\n]/, ''), true
      else
        m.reply "Wolfram|Alpha has nothing for #{query}", true
      end
    else
      m.reply 'Internal error (missing API key)'
    end
  end
end
