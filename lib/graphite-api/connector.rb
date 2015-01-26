# -----------------------------------------------------
# TCP Socket connection
# -----------------------------------------------------
# Usage:
#    connector = GraphiteAPI::Connector.new("localhost",2003)
#    connector.puts("my.metric 1092 1232123231")
#
# Socket:
# => my.metric 1092 1232123231\n
# -----------------------------------------------------
require 'socket'

module GraphiteAPI
  class Connector
    class Group
      include Utils

      private_reader :options, :connectors

      def initialize options
        @options = options
        @connectors = options[:backends].map { |o| Connector.new(*o) }
      end

      def publish messages
        debug [:connector_group,:publish,messages.size, @connectors]
        Array(messages).each { |msg| connectors.map {|c| c.puts msg} }
      end

    end

    include Utils

    def initialize host, port
      @host = host
      @port = port
    end

    private_reader :host, :port

    def puts message
      begin
        debug [:connector,:puts,[host,port].join(":"),message]
        socket.puts message + "\n"
      rescue Errno::EPIPE, Errno::EINVAL
        @socket = nil
        retry
      rescue Errno::ETIMEDOUT
        socket = nil
      end
    end

    def inspect
      "#{self.class} #{@host}:#{@port}"
    end

    protected

    def socket
      if @socket.nil? || @socket.closed?
        debug [:connector,[host,port]]
        @socket = ::TCPSocket.new host, port
      end
      @socket
    end

  end
end
