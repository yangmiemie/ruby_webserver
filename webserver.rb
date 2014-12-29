require 'socket'

class Webserver
	def initialize(port) 
		@server = TCPServer.new port
	end

	def start
		loop do
			socket = @server.accept
			data = socket.readpartial(1024)
			puts data

			socket.write "HTTP/1.1 200 OK\r\n"
			socket.write "\r\n"
			socket.write "hello\n"

			socket.close
		end
	end
end

server = Webserver.new 3000
server.start
