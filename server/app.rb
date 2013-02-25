require 'em-websocket'
require 'json'

FRAMERATE = 1.0 / 60.0

EM.run do
  @channel = EM::Channel.new # one channel for now

  EM::WebSocket.start(:host => "0.0.0.0", :port => 8080, :debug => false) do |ws|
    ws.onopen do |handshake|
      puts "WebSocket opened #{{
        path:   handshake.path,
        query:  handshake.query,
        origin: handshake.origin,
      }}"

      @sid = @channel.subscribe { |msg| ws.send(msg) }
      @channel.push({from: @sid, msg: 'HATH JOINED'}.to_json)
    end

    ws.onmessage do |msg|
      puts "#{ @sid } says #{ msg.inspect }"
      @channel.push(msg)
    end

    ws.onclose do
      @channel.unsubscribe(@sid)
      puts "WebSocket closed for #{ @sid }"
    end

    ws.onerror do |e|
      puts "Error: #{ e.message }"
    end
  end
end
