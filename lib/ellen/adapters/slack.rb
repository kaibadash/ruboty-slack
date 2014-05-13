require "xrc"

module Ellen
  module Adapters
    class Slack < Base
      env :SLACK_PASSWORD, "Account's XMPP password (See https://tqhouse.slack.com/account/gateways)"
      env :SLACK_ROOM, "Room name to join in at first (e.g. general)"
      env :SLACK_TEAM, "Account's team name (e.g. wonderland)"
      env :SLACK_USERNAME, "Account's username (e.g. alice)"

      def run
        bind
        connect
      end

      def say(message)
        client.say(
          body: message[:body],
          from: message[:from],
          to: message[:original][:type] == "chat" ? message[:to] + "/resource" : message[:to],
          type: message[:original][:type],
        )
      end

      private

      def client
        @client ||= Xrc::Client.new(
          jid: jid,
          nickname: username,
          password: password,
          room_jid: room_jid,
        )
      end

      def jid
        "#{username}@#{host}"
      end

      def room_jid
        "#{room}@#{room_host}"
      end

      def host
        "#{team}.xmpp.slack.com"
      end

      def room_host
        "conference.#{host}"
      end

      def room
        ENV["SLACK_ROOM"]
      end

      def username
        ENV["SLACK_USERNAME"]
      end

      def password
        ENV["SLACK_PASSWORD"]
      end

      def team
        ENV["SLACK_TEAM"]
      end

      def bind
        client.on_private_message(&method(:on_message))
        client.on_room_message(&method(:on_message))
      end

      def connect
        client.connect
      end

      def on_message(message)
        robot.receive(
          body: message.body,
          from: message.from,
          to: message.to,
          type: message.type,
        )
      end
    end
  end
end
