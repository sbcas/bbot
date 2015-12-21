# -*- coding: utf-8 -*-
require 'yaml'

require 'cinch'

require 'cinch/plugins/quotes'
require 'cinch/plugins/identify'
require 'marky_markov'

Dir[File.dirname(__FILE__) + '/extensions/**/*.rb'].each do |extension|
  require extension
end

Dir[File.dirname(__FILE__) + '/plugins/**/*.rb'].each do |plugin|
  require plugin
end

config_file = File.expand_path(File.join(File.dirname(__FILE__), 'config.yml'))
version_file = File.expand_path(File.join(File.dirname(__FILE__), 'version.yml'))
plugins_file = File.expand_path(File.join(File.dirname(__FILE__), 'plugins.yml'))
brain = File.expand_path(File.join(File.dirname(__FILE__), 'brain'))
markov = MarkyMarkov::Dictionary.new(brain)
server_threads = []

if File.file?(config_file) && File.file?(version_file) && File.file?(plugins_file)
  config = YAML::load_file(config_file)
  version = YAML::load_file(version_file)
  plugins = YAML::load_file(plugins_file)['plugins']
else
  abort('Fatal: Missing one of: config.yml, version.yml, plugins.yml')
end

config['servers'].each do |server_name, server_info|
  server_threads << Thread.new do
    Cinch::Bot.new do
      @starttime = Time.now
      @version = ['major', 'minor', 'patch'].map { |v| version[v] }.join('.')
      @admins = server_info['admins'] or []
      @blacklist = Set.new
      @all_plugins = plugins.map do |plugin|
        Object.const_get(plugin)
      end

      def starttime
        @starttime
      end

      def version
        @version
      end

      def admins
        @admins
      end

      def blacklist
        @blacklist
      end

      def all_plugins
        @all_plugins
      end

      configure do |conf|
        conf.nick = server_info['nick'] or 'irbot'
        conf.realname = 'The Honorable I.R. Botsford III'
        conf.user = 'irbot'
        conf.max_messages = 1
        conf.server = server_name
        conf.channels = server_info['channels']
        conf.port = server_info['port'] or 6667
        conf.ssl.use = server_info['ssl'] or false
        conf.plugins.prefix = /^\./
        conf.plugins.plugins = @all_plugins.dup
        conf.plugins.plugins << Cinch::Plugins::Identify
        conf.plugins.plugins << Cinch::Plugins::Quotes
        conf.plugins.options[Cinch::Plugins::Quotes] = {
          :quotes_file => File.expand_path(File.join(File.dirname(__FILE__), './config/quotes.yml'))
        }

        if server_info.key?('auth')
          conf.plugins.options[Cinch::Plugins::Identify] = {
            type: server_info['auth']['type'].to_sym,
            password: server_info['auth']['password']
          }
        end

        if server_info.key?('disabled_plugins')
          server_info['disabled_plugins'].each do |plugin|
            conf.plugins.plugins.delete(Object.const_get(plugin))
          end
        end
      end

      # learn all the things
      on :message, /(.*)/ do |m, message|
        if rand(5) == 0
          markov.save_dictionary!
        end

        # all the things.
        markov.parse_string message
      end

      on :message, /(.*)/ do |m, message|
        if rand(10) == 0
          m.reply markov.generate_n_sentences 1
        end
      end

    end.start
  end
end

server_threads.each do |thread|
  thread.join
end
