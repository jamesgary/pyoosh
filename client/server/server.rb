require 'em-websocket'

FRAMERATE = 1.0 / 60.0

EM.run do
  EM::WebSocket.run(:host => "0.0.0.0", :port => 8080, :debug => false) do |ws|

    foo = 0
    interval = 1

    ws.onopen do |handshake|
      puts "WebSocket opened #{{
        :path => handshake.path,
        :query => handshake.query,
        :origin => handshake.origin,
      }}"

      EM.add_periodic_timer(FRAMERATE) do
        ws.send(foo.to_s)
        interval = -1 if foo >= 100
        interval =  1 if foo <= 0
        foo += interval
      end
    end

    ws.onclose do
      puts "WebSocket closed"
    end

    ws.onerror do |e|
      puts "Error: #{e.message}"
    end

    ws.onmessage do |msg|
      # ignore, who cares
    end
  end
end
