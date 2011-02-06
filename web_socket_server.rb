class WebSocketServer
  attr_reader   :tcp_server, :port
  attr_accessor :connections

  def initialize(options)
    @port = options[:port] || 8080
    @tcp_server = TCPServer.open(@port)
    @connections = {}
  end

  def run(&block)
    while true
      Thread.start(@tcp_server.accept) do |client|
        begin
          yield(ws = web_socket(client))
        rescue => ex
          $stderr.puts "Message: #{ex.message}"
        ensure
          ws.close if ws
        end
      end
    end
  end

  def web_socket(socket)
    WebSocket.new(socket, self)
  end
end
