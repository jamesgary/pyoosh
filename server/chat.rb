require 'em-websocket'
require 'json'
require_relative 'player'

EM.run do
  chat_channel = EM::Channel.new # public, everyone's invited

  EM::WebSocket.start(:host => "0.0.0.0", :port => 8080, :debug => false) do |ws|
    player = Player.new # make new player for this scope

    listeners = [
      {
        key: 'chat',
        callback: lambda do |data|
          chat_channel.push({ chat: { msg: data, from: player.name } }.to_json)
        end
      }
    ]

    ws.onopen do |handshake|
      player.id   = chat_channel.subscribe { |msg| ws.send(msg) }
      player.name = handshake.query['name'] || "Guest_#{ id }"

      chat_channel.push({ chat: { msg: "#{ player.name } has joined" } }.to_json)
    end

    ws.onmessage do |ws_data|
      ws_data = JSON.parse(ws_data)
      listeners.each do |listener|
        if value = ws_data[listener[:key]]
          listener[:callback].call(value)
        end
      end
    end

    ws.onclose do
      chat_channel.unsubscribe(player.id)
      chat_channel.push({ chat: { msg: "#{ player.name } has left" } }.to_json)
    end

    ws.onerror do |e|
      puts "Error: #{ e.message }"
      puts "Backtrace:\n\t#{e.backtrace.join("\n\t")}"
    end
  end

  puts 'Running...'
end
