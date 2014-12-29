require 'socket'

class Webserver
	def initialize(port) 
		@server = TCPServer.new port
	end

	def start
		loop do
			socket = @server.accept
			connection = Connection.new socket
			connection.process
		end
	end

	class Connection 
		def initialize(socket)
			@socket = socket
		end

		def process
			data = @socket.readpartial(1024)
			puts data
			send_response
		end

		def send_response
			@socket.write "HTTP/1.1 200 OK\r\n"
			@socket.write "\r\n"
			@socket.write "hello\n"
		
			close
		end

		def close
			@socket.close
		end

	end

end

server = Webserver.new 3000
server.start
