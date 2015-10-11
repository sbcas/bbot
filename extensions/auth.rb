module Cinch
  module Plugin
    module ClassMethods
      def use_auth(silent: false)
        if silent
          hook :pre, :for => [:match], :method => :authed_silent?
        else
          hook :pre, :for => [:match], :method => :authed?
        end
      end

      def authed_silent?(m)
        @bot.admins.include?(m.user.nick) && User(m.user.nick).authed?
      end

      def authed?(m)
        if authed_silent?(m)
          return true
        else
          m.reply "Permission denied", true
          return false
        end
      end
    end
  end
end
