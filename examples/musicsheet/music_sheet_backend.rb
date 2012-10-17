module MusicSheet
  attr_accessor :head

  def MusicSheet.change_mode(mode,h)

    #head = Head.first(:name=>h["name"])

    case mode['name']
      when "tilting"
        @head.process_event :tilt_mode
      when "nodding"
        @head.process_event :nodd_mode
      when "turning"
        @head.process_event :turn_mode
      else
        return false
    end
    return true
  end

  def MusicSheet.head_angle_transformation(angle)
    80-(angle / Math::PI * 100 * 80 / 100).abs.to_i
  end
end