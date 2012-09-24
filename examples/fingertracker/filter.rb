require "rubygems"
require "bundler/setup"
require "activesupport"

class Filter

  attr_accessor_with_default :detection_frame,[50,130,400,280]
  attr_accessor_with_default :projection_size,[848,480]
  attr_accessor_with_default :shift,[-50,-130]
  attr_accessor_with_default :mirror_x,false
  attr_accessor_with_default :mirror_y,true

  def initialize
    setup
  end

  def setup
    frame_width = detection_frame[2]-detection_frame[0]
    frame_height = detection_frame[3]-detection_frame[1]

    @scale_x = (projection_size[0] / frame_width).to_i
    @scale_y = (projection_size[1] / frame_height).to_i
  end

  def inside_detection_frame?(x,y)
    x>=detection_frame[0] and x<=detection_frame[2] and y>=detection_frame[1] and y<=detection_frame[3]
  end

  #mirrors just y and scales both to projection size
  def convert(x,y)
    x = x + shift[0]
    y = y + shift[1]

    r_x = @scale_x*x
    r_y = y*@scale_y

    if mirror_y
       r_y = projection_size[1]-r_y
       end
    if mirror_x
       r_y = projection_size[0]-r_x
    end
    [r_x, r_y]
  end
end