require 'rubygems'
require "bundler/setup"
require "eventmachine"

class FingerTracker
  attr_accessor :buffer

  PROCESS_RESOLUTION = 0.1
  def initialize(fingertip)
    @fingertip = fingertip
    @buffer = ""
    start
  end

  def start(host ="0.0.0.0", port=5000)
    EventMachine::start_server host, port, StatefulProtocol do |conn|
      @connection = conn
      @fingertip.process_event :connect
      conn.pose = self
      conn.fingertip =@fingertip
      puts "connection..."

    end
    puts "Started finger tracker on #{host}:#{port}"

    EventMachine::add_periodic_timer( PROCESS_RESOLUTION ) { process_data }

  end

  def process_data
    data = @buffer.dup # real copy
    @buffer = ""
    return if data.nil? or data.length<1
    return if /RESOLUTION/.match(data)
    return if /MISSING\|MISSING/.match(data)

    # p data
    d = data.split('|')

    return if d[1].nil?
    d = d[1].split(';')

    touch_array = []
    if d and d[0].to_i>=1
      d.shift # remove length
      d.each do |tip|
        c = tip.split(',')
        touch_array << [c[0]]+ CalibrationApp.transform(c[1],c[2])
      end
      RedisConnector.redis.publish "ss:event",create_data_new("touches",touch_array)
    end
  end

  def create_data_new(cmd,array)
       #{:cmd=>cmd,:touch=>{:identifier=>"touch-#{identifier}",:pageX=>x,:pageY=>y}}.to_json
       {:t => "channel", :channels => ["user:testuser"],:e => cmd, :p => [array]}.to_json
   end

  def create_data(cmd,identifier, x=1, y=1)
      #{:cmd=>cmd,:touch=>{:identifier=>"touch-#{identifier}",:pageX=>x,:pageY=>y}}.to_json
      {:t => "channel", :channels => ["user:testuser"],:e => "touch", :p => {:cmd=>cmd,:touch=>{:identifier=>"touch-#{identifier}",:pageX=>x,:pageY=>y}}}.to_json
  end

  class StatefulProtocol < EventMachine::Connection
    include EM::Protocols::LineText2
    attr_accessor :pose
    attr_accessor :fingertip
    def initialize
      super()

    end

    def receive_line(data)
     # p "received #{data}"
      pose.buffer = data
    end

    def unbind
      @fingertip.process_event :disconnect
    end

  end
end
