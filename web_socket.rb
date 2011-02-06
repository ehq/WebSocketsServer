require "socket"
require "uri"
require "digest/md5"

class WebSocket
  class InvalidRequestError < StandardError; end
  class MissingHeadersError < StandardError; end
  class HandshakeError      < StandardError; end

  attr_reader :server, :header, :path, :handshaken

  def initialize(socket, server)
    @server = server
    @socket = socket

    raise InvalidRequestError unless gets.chomp.match(/\AGET (\S+) HTTP\/1.1\z/n)
    parse_header

    @path = $1
    @key3 = read(8)
    @handshaken = false
  end

  def handshake(status = "101 Web Socket Protocol Handshake", header = {})
    return if handshaken

    header.merge!("Sec-WebSocket-Origin"   => origin,
                  "Sec-WebSocket-Location" => location)

    header_str = header.map { |k, v| "#{k}: #{v}\r\n" }.join

    # Note that Upgrade and Connection must appear in this order.
    digest = security_digest(@header["Sec-WebSocket-Key1"],
                             @header["Sec-WebSocket-Key2"],
                             @key3)

    write("HTTP/1.1 #{status}\r\nUpgrade: WebSocket\r\nConnection: Upgrade\r\n#{header_str}\r\n#{digest}")

    flush
    @handshaken = true
  end

  def send(message)
    raise HandshakeError unless handshaken

    write("\x00#{message}\xff")

    flush
  end

  def receive
    raise HandshakeError unless handshaken

    return unless packet = gets("\xff")

    raise ArgumentError unless packet =~ /\A\x00(.*)\xff\z/nm

    $1
  end

  def tcp_socket
    @socket
  end

  def host
    @host ||= header["Host"]
  end

  def origin
    @origin ||= header["Origin"]
  end

  def location
    @location ||= "ws://#{host}#{path}"
  end

  def close
    @socket.close
  end

private
  def parse_header
    @header = {}

    while line = gets.chomp
      break if line.empty?

      raise InvalidRequestError unless line =~ /\A(\S+): (.*)\z/n

      @header[$1] = $2
    end

    raise ArgumentError if @header["Upgrade"] != "WebSocket"
    raise ArgumentError if @header["Connection"] != "Upgrade"
    raise ArgumentError unless @header["Sec-WebSocket-Key1"] && @header["Sec-WebSocket-Key2"]
  end

  def gets(rs = $/)
    @socket.gets(rs)
  end

  def read(num_bytes)
    @socket.read(num_bytes)
  end

  def write(data)
    @socket.write(data)
  end

  def flush
    @socket.flush
  end

  def security_digest(key1, key2, key3)
    bytes1 = websocket_key_to_bytes(key1)
    bytes2 = websocket_key_to_bytes(key2)
    Digest::MD5.digest(bytes1 + bytes2 + key3)
  end

  def websocket_key_to_bytes(key)
    [key.gsub(/[^\d]/n, "").to_i / key.scan(/ /).size].pack("N")
  end
end
