require 'faye/websocket'

module Chat
  class ChatBackend
    KEEPALIVE_TIME = 15 # in seconds

    def initialize(app)
      @app     = app
      @clients = []
    end

    def call(env)
        puts 'in WS middleware'
        if Faye::WebSocket.websocket?(env)
            ws = Faye::WebSocket.new(env, nil, {ping: KEEPALIVE_TIME })

            ws.on :open do |event|
                p ['websocket connection opened', ws.object_id]
                @clients << ws
            end

            ws.on :message do |event|
                p ['websocket message event', event.data]
                @clients.each {|client| client.send(event.data) }
            end

            ws.on :close do |event|
                p ['websocket closing', ws.object_id, event.code, event.reason]
                @clients.delete(ws)
                ws = nil
            end

            ws.rack_response
        else
            @app.call(env)
        end
    end
  end
end