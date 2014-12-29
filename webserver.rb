require 'socket'
require 'http/parser'

class Webserver
	def initialize(port, app) 
		@server = TCPServer.new port
		@app = app
	end

	def start
		loop do
			socket = @server.accept
			connection = Connection.new socket, @app
			connection.process
		end
	end

	class Connection 
		def initialize(socket, app)
			@socket = socket
			@parser = Http::Parser.new self
			@app = app
		end

		def process
			until @socket.closed? || @socket.eof?
				data = @socket.readpartial(1024)
				@parser << data
			end
		end

		def on_message_complete
			puts "#{@parser.http_method} #{@parser.request_url}"
			puts " #{@parser.headers}" 

			env = {}
			env['PATH_INFO'] = @parser.request_url
			env['REQUEST_METHOD'] = @parser.http_method

			@parser.headers.each_pair do |name, value|
				name = 'HTTP_' + name.upcase.tr('-', '_')
				env[name] = value
			end

			send_response env
		end

		REASONS = {
			200 => 'OK',
			404 => 'Not Found'
		}

		def send_response(env)
			status, header, body = @app.call env

			@socket.write "HTTP/1.1 #{status} #{REASONS[status]}\r\n"
			header.each_pair do |name, value|
				@socket.write "#{name}:#{value}\r\n"
			end
			@socket.write "\r\n"
			body.each do |message|
				@socket.write message
			end
		
			close
		end

		def close
			@socket.close
		end
	end

	class Builder
		attr_reader :app

		def run(app)
			@app = app
		end

		def self.process(file)
			content = File.read(file)
			builder = self.new
			builder.instance_eval content
			builder.app
		end
	end

end

app = Webserver::Builder.process('config.ru')
server = Webserver.new 3000, app
server.start