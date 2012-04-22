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

    attr_reader :options, :host, :port
    
    def initialize(host,port)
      @host = host
      @port = port
    end
    
    def puts message
      begin
        Logger.debug [:connector,:puts,[host,port].join(":"),message]
        socket.puts message
      rescue Errno::EPIPE
        @socket = nil
      retry
      end
    end
    
    def inspect
      "#{self.class} #{@host}:#{@port}"
    end
    
    protected
    
    def socket
      if @socket.nil? || @socket.closed?
        @socket = ::TCPSocket.new(host,port)
      end
      @socket
    end
     
  end
end
