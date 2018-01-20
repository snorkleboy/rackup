require 'socket'
require 'thread'
require './app'
include Socket::Constants

require 'rack/lobster'


#configure socket and port/host
socket = Socket.new(AF_INET, SOCK_STREAM, 0)
if (ENV["PORT"])
    port = ENV["PORT"]
    host = '0.0.0.0'
else
    port = ARGV[0] || 3000
    host = ARGV[1] || 'localhost'
end
sockaddress = Socket.pack_sockaddr_in(port,host )

#bind and listen
socket.bind(sockaddress)
listen = socket.listen(5)

p "socket bound and listening on #{[host,port]}"

# init rack app

app = Rack::Lobster.new
p app
p app.call({})
# app = App_maker.new.make
while(true) do
p 'waiting for connection'
    Thread.start(socket.accept) do |connection| 
        client = connection[0]
        request = client.gets
        puts request
        status, headers, body = app.call({})

        # HTTP:STATUS
        client.print "HTTP/1.1 #{status}\r\n"
        # HTTP:HEADERS
        headers.each do |key, value|
            client.print "#{key}: #{value}\r\n"
        end
        # HTTP:BODY BREAK
        client.print "\r\n"
        # HTTP:BODY
        body.each do |part|
            client.print part
        end
        # client.print "HTTP/1.1 200\r\n" # 1
        # client.print "Content-Type: text/html\r\n" # 2
        # client.print "\r\n" # 3
        # client.print "Hello world! The time is #{Time.now}" #4

        client.close
    end


end