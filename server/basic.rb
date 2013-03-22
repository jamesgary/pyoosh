require 'em-websocket'

EM.run do
  EM::WebSocket.start(:host => "0.0.0.0", :port => 8080, :debug => false) do |ws|
    ws.onopen do |handshake|
      ws.send('Welcome!')
    end

    ws.onmessage do |ws_data|
      ws.send('How fascinating!')
    end

    ws.onclose do
    end

    ws.onerror do |e|
    end
  end

  puts 'Running...'
end

