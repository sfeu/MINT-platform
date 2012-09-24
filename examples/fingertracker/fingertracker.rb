$:.unshift File.expand_path(File.join(File.dirname( __FILE__), ".."))
require 'rubygems'
require "bundler/setup"
require "eventmachine"
require "fingertracker/history"
require "fingertracker/updater"
require "fingertracker/filter"
require "fingertracker/stateful_protocol"

EventMachine::run do

  require "MINT-core"
  @hands = [History.new,History.new]
  @updater = Updater.new @hands[0], @hands[1]
  @host = "0.0.0.0"
  @port = 5000
  @filter = Filter.new
  @filter.detection_frame=[0,0,800,600]
    @filter.projection_size=[800,600]
    @filter.shift=[0,0]
    @filter.mirror_y = false
    @filter.setup

  EventMachine::start_server @host, @port, StatefulProtocol do |conn|
    conn.hands = @hands
    conn.filter = @filter
    puts "connection..."
  end

  # set updater

  @hands.each do |hands| # set refresh rate for each hand to 200 ms
     EventMachine::add_periodic_timer( 0.2 ) { @updater.send_update}
  end

  puts "Started server on #{@host}:#{@port}"
end

