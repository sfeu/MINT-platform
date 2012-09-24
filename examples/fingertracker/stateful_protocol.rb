require "eventmachine"

class StatefulProtocol < EventMachine::Connection
  include EM::Protocols::LineText2
  attr_accessor :hands, :filter

  def initialize
    super
  end

  def receive_line(data)
    return if /RESOLUTION/.match(data)

    received_hands  = data.split '|'

    received_hands.each_with_index do |hand,i|
      if hand.eql? "MISSING"
        @hands[i].new_frame
      else
        process_hand @hands[i], hand
      end
    end
  end

  def process_hand hand, new_hand
    fingers = new_hand.split(';')
    for i in 1..fingers[0].to_i
      touched, x, y = fingers[i].split(',').map &:to_i
      next if not @filter.inside_detection_frame? x,y

      x,y = @filter.convert(x,y)
      hand.new_coordinate x,y,touched
    end
    hand.new_frame
  end

end
