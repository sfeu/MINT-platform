module MINT

  # Implementation of the standard protocol to connect modes to MINT
  # using a basic TCPIP string based protocol

  module StandardModeProtocol

    attr_accessor :buffer
    # how often the process_data function can be called
    PROCESS_RESOLUTION = 0.1

    def start(host ="0.0.0.0", port=5000)
      EventMachine::start_server host, port, StatefulProtocol do |conn|
        @connection = conn

        conn.interactor = self
        puts "connection..."
        self.process_event :connect
      end
      puts "Started modality server for #{self.class} on #{host}:#{port}"

      EventMachine::add_periodic_timer( PROCESS_RESOLUTION ) {
        if buffer
          data = buffer.dup # real copy
          process_data(data) if is_new_data?(data)
        end
      }

    end

    def is_new_data?(data)
      return false if data == nil or data.eql? @old_data
      @old_data = data
      true
    end


    class StatefulProtocol < EventMachine::Connection
      include EM::Protocols::LineText2

      # the interactor that should implement the protocol
      # it has to offer
      # a buffer variable
      # react to disconnect and connect events
      # implement a process_data function that is called based on the process resolution

      attr_accessor :interactor

      def initialize
        super()

      end

      def receive_line(data)
        interactor.buffer = data
      end

      def unbind
        interactor.process_event :disconnect
      end

    end

  end
end