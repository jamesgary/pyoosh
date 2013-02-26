require 'em-websocket'
require 'json'
require_relative 'player'

FRAMERATE = 1.0 / 60.0

EM.run do
  @channel = EM::Channel.new # one channel for now

  EM::WebSocket.start(:host => "0.0.0.0", :port => 8080, :debug => true) do |ws|
    player = Player.new # make new player for this scope

    ws.onopen do |handshake|
      player.id   = @channel.subscribe { |msg| ws.send(msg) }
      player.name = handshake.query['name'] || "Guest_#{ id }"
      @channel.push({ chat: {msg: "#{ player.name } has joined" } }.to_json)
    end

    ws.onmessage do |msg|
      @channel.push({ chat: { msg: msg, from: player.name } }.to_json)
    end

    ws.onclose do
      @channel.unsubscribe(@sid)
      @channel.push({ chat: { msg: "#{ player.name } has left" } }.to_json)
    end

    ws.onerror do |e|
      puts "Error: #{ e.message }"
    end
  end

  puts 'Running...'
end
