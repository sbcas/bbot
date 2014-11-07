# -*- coding: utf-8 -*-
require 'rubygems'
require 'bundler/setup'

require 'yaml'

require 'cinch'

require 'cinch/plugins/quotes'
require 'cinch/plugins/identify'
require 'cinch-weatherman'

conf = YAML::load(File.open('config/irbot.yml'))

bot = Cinch::Bot.new do
    configure do |c|
        c.nick 		= conf['nick']
	c.user 		= conf['user']
	c.realname 	= conf['realname']
	c.server	= conf['server']
        c.channels 	= conf['chans'].map { |chan| "#{chan}" }
	c.max_messages	= 1
	c.port		= conf['port'] if conf.key?('port')

	# Plugins
	c.plugins.prefix  = '.'
        c.plugins.plugins = Cinch::Plugins.constants.map { |c| Class.module_eval("Cinch::Plugins::#{c}") }

        c.plugins.options[Cinch::Plugins::Quotes] = {
          :quotes_file => './config/quotes.yml'
        }
	c.plugins.options[Cinch::Plugins::Identify] = {
	  :username => "irbot",
	  :password => "1rb0tp4ss",
	  :type     => :nickserv
	}
    end
end

bot.start
