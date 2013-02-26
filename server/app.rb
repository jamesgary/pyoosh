require 'em-websocket'
require 'json'
require_relative 'player'
require_relative 'playground'

FRAMERATE = 1.0 / 60.0

EM.run do
  @chat_channel = EM::Channel.new # public, everyone's invited
  @playground = Playground.new

  EM.add_periodic_timer(FRAMERATE) do
    @playground.step
  end

  EM::WebSocket.start(:host => "0.0.0.0", :port => 8080, :debug => false) do |ws|
    player = Player.new # make new player for this scope
    player_channel = EM::Channel.new # private channel exclusively for player
    listeners = []
    listeners << {
      key: 'chat',
      callback: lambda do |data|
        @chat_channel.push({ chat: { msg: data, from: player.name } }.to_json)
      end
    }
    listeners << {
      key: 'playground',
      callback: lambda do |data|
        if target = data['target']
          @playground.player_move(player, target)
        else
          @playground.player_exit(player)
        end
        player_channel.push({ playground: @playground.to_h }.to_json)
      end
    }
    attractor = nil

    ws.onopen do |handshake|
      player.id   = @chat_channel.subscribe { |msg| ws.send(msg) }
      player.name = handshake.query['name'] || "Guest_#{ id }"
      @chat_channel.push({ chat: {msg: "#{ player.name } has joined" } }.to_json)
      player_channel.subscribe { |msg| ws.send(msg) }

      # prime the pump
      player_channel.push({ playground: @playground.to_h }.to_json)
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
      player_channel.unsubscribe(1) # will always be 1
      @chat_channel.unsubscribe(@sid)
      @chat_channel.push({ chat: { msg: "#{ player.name } has left" } }.to_json)
    end

    ws.onerror do |e|
      puts "Error: #{ e.message }"
      puts "Backtrace:\n\t#{e.backtrace.join("\n\t")}"
    end
  end

  puts 'Running...'
end
