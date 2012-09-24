class History
  FRAME = 3
  TOUCH = 2
  X = 0
  Y = 1

  def initialize

    @records = {}

    @threshold_similar_x=20
    @threshold_similar_y=20

    @buffer_size = 100

    @cur_frame = 1
    @finger_nr = 0
    @consider_frames = 20
  end

  def similar finger1, finger2
    if ((finger1[0]-finger2[0]).abs <= @threshold_similar_x and (finger1[1]-finger2[1]).abs <= @threshold_similar_y)
      xd = (finger1[0]-finger2[0]).abs
      yd = (finger1[1]-finger2[1]).abs
      r = ((xd*xd)+(yd*yd)).to_i

      Math.sqrt(r).to_i

    else
      nil
    end

  end

  def add_finger finger
    @finger_nr += 1
    @records[@finger_nr]= [finger]
    {@finger_nr=>finger.slice(0..2)}
  end

  def assign_fingers
    return {} if @new_record.nil?
    result = {}
    coordinates = @new_record

    distance = {}

    not_related  = Array.new coordinates.length # used to figure out which coordinates could not be related to existing fingers
    not_related.fill{|i|i}

    if not @records.blank?
      coordinates.each_with_index do |c,i|
        @records.keys.each do | k|
          e = @records[k].last
          if e[FRAME]>= @cur_frame - @consider_frames
            d = similar(c,e)
            if not d.nil?
              if (distance[i])
                distance[i] << Array[i,d,k]
              else
                distance[i] =  [Array[i,d,k]]
              end
            end
          else
            @records.delete k # outdated finger
          end
        end

        # sort for each new coordinate the closest finger from history
        distance[i].sort! { |x,y| x[1] <=> y[1] } if distance[i]
      end

      distance_keys = distance.keys

      # sort the closest match of all fingers to be the first
      distance_keys.sort! {|x,y| distance[x][0][1] <=> distance[y][0][1] }

      distance_keys.each do |v|

        # search in
        j = 0
        begin
          e = distance[v][j] # best match for finger

          r = @records[e[2]]

          # if r # finger has been tracked before
          if r.last[FRAME]<@cur_frame  # has not been saved fo this frame
            result[e[2]]=coordinates[distance[v][j][0]]
            r.push (coordinates[distance[v][j][0]].dup << @cur_frame)
                                                      # this changes coordinates array!!
            not_related.delete distance[v][j][0]
            break # we are done!
          else # go on
            j += 1
          end
          #end
        end while distance[v][j] # as long as there are matches
      end
    else
      @record ={}
    end

    # case: add all coordinates that are not in distance as new fingers
    not_related.each do |r|
      result.merge!(add_finger (coordinates[r] << @cur_frame))
    end
    result
  end

  def new_coordinate x,y,touched=0
    @new_record = Array.new if @new_record.nil?
    @new_record.push([x,y,touched])
  end


  def new_frame
    fingers = assign_fingers

    @new_record = Array.new
    @cur_frame += 1
    fingers
  end

  # retrieves all fingers
  def get_fingers
    r = @records.keys
    fingers = {}
    return fingers if r.nil?
    r.each do |k|
      fingers.merge! process_finger(k)
    end
    fingers
  end

  # processes one finger and returns a average coordinates of the 10 last appearances - but only if it appeared
  # at least every 4th frame otherwise it returns nil
  def process_finger nr
    missed = 0
    appeared = 0
    x =y = 0

    data = @records[nr]

    appeared = 0
    touched = 0
    data.each do |d|
      appeared +=1
       x = x + d[0]
       y = y + d[1]
       touched = d[2]
    end


    {nr=>[(x/appeared).to_i,(y/appeared).to_i,touched]}

  end

end