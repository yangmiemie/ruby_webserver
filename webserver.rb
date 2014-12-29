require 'socket'
require 'http/parser'

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
			@parser = Http::Parser.new self
		end

		def process
			until @socket.closed? || @socket.eof?
				data = @socket.readpartial(1024)
				@parser << data
			end
		end

		def on_message_complete
			puts "#{@parser.http_method} #{@parser.request_url}"
			# puts "#{@parser.http_method} #{@parser.request_path}"
			puts " #{@parser.headers}" 
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
