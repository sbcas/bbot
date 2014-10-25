require "cinch"
require "cinch/plugins/quotes"

bot = Cinch::Bot.new do
    configure do |c|
        c.nick = "irbot"
        c.server = "irc.jaundies.com"
        c.channels = ["#go"]
        c.plugins.plugins = [Cinch::Plugins::Quotes]
        c.plugins.options[Cinch::Plugins::Quotes] = {
          :quotes_file => './config/quotes.yml'
        }
    end
end

bot.start
