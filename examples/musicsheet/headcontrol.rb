
require 'rubygems'
require "bundler/setup"
require "MINT-core"
require "MINT-scxml"


class HeadControl

  class StatefulProtocol < EventMachine::Connection
    include EM::Protocols::LineText2
    attr_accessor :head
    # attr_accessor :speed

    def initialize
      super()
      @head_threshold=0.7
    end

    def update_pointer(x,y)
      x=x*@res_factor_x
      x= @screen_res_x -x # value mirrored

      y=y*@res_factor_y

      if ( ((@last_sent_hand_x-  x).abs>@threshold_hand_x) || ((@last_sent_hand_y-  y).abs>@threshold_hand_y))
        @last_sent_hand_x= x
        @last_sent_hand_y= y
        Juggernaut.publish("pointer", "POS-#{x.to_i},#{y}")
        p "Pointer: #{r}, #{x},#{y}"
        @mouse.cache_coordinates(x,y)
        @mouse.process_event("move")
      end
    end
    def receive_line(data)
      begin
        d = data.split('/')

        case d[0]
          when "Move", "HeadMove"
            @head.process_event :connect if @head.is_in? :disconnected

            if (@head.is_in? :tilting_mode)
              angle = d[4].gsub(',',".").to_f
              if (angle <= Math::PI and angle > (Math::PI/2+@head_threshold))

                if (not @head.is_in? :tilting_left)
                  @head.process_event(:tilt_left)
                  p "tilt left"
                end
                #"#{if not @head.is_in? :moving_left
                #" @head.process_event(:left)
                #  p "left"
                #end
              elsif (angle <= (Math::PI/2+@head_threshold) and angle > (Math::PI/2-@head_threshold))
                if not @head.is_in? :centered
                  @head.process_event(:center)
                  p "center"
                end
              else
                if (not @head.is_in? :tilting_right)
                  @head.process_event(:tilt_right)
                  p "tilt right"
                end
              end
            end
          when "FaceMove"

            x = d[1].gsub(',',".").to_f
            y = d[2].gsub(',',".").to_f
            #p "X:#{x},y:#{y}"
            if (0.5>y and y > -0.5)
              if not @head.is_in? :centered
                @head.process_event(:center)
                p "center"
              end
              #elsif (y>=0.5)
              #  if not @head.is_in? :look_up
              #    @head.process_event(:up)
              #  end
            elsif (@head.is_in? :nodding_mode and y<=0.2 and 0.5>x and x >-0.5)
              if not @head.is_in? :looking_down
                @head.process_event(:look_down)
                p "look down"
              end
            else
              if not @head.is_in? :looking_up
                @head.process_event(:look_up)
                p "look up"
              end
            end

            if (@head.is_in? :turning_mode and x>=0.8)
              if not @head.is_in? :looking_right
                @head.process_event(:turn_right)
                p "turn right"
              end
            else
              if not @head.is_in? :looking_left
                @head.process_event(:turn_left)
                p "turn left"
              end
            end
          when 'Leave'
            @head.process_event(:disconnect)
          when 'Enter'
            @head.process_event(:connect)
          else
            p "ERROR\r\nReceived Unknown data:#{data}\r\n "
        end
      end
    rescue Statemachine::TransitionMissingException => bang
      puts "ERROR\n#{bang}"
    end
  end

  def initialize

  end

  def start(head, host ="0.0.0.0", port=4242)
    EventMachine::start_server host, port, StatefulProtocol do |conn|
      conn.head=head

      puts "connection..."
    end
    puts "Started head control server on #{host}:#{port}"
  end
end



