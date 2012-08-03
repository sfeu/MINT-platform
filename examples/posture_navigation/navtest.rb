require 'rubygems'
require "MINT-core"
require "fastercsv"

include MINT

class NavTestAgent < Agent

  def initialize(argv)
    super({ :adapter => "rinda", :host =>"localhost",:port=>4000})
    @csv = FasterCSV.open(argv[0],"w")
    @csv << ["Destination","Selected","Minimal Distance", "Time required", "Next Steps", "Previous Steps", "Next Prefered?","Total Steps","Time p Step"]
    @csv.flush
    data = ["F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y"]
    @data_set = data.shuffle
    @index = 0

    @next_step_counter = 0
    @prev_step_counter = 0

    @start_time = nil
    @end_time = nil

    MarkableRadioButton.all(:new_states=>"marked").each do |m|
      m.process_event(:unmark)
    end

    fix_navigation

    first_list_element = AISingleChoice.first(:name=>"9").childs.first
    first_list_element.process_event("focus")
    mark
  end

  def fix_navigation
    first_list_element = AISingleChoice.first(:name=>"9").childs.first
    last_list_element = AISingleChoice.first(:name=>"9").childs.last
    first_list_element.previous = last_list_element
    last_list_element.next= first_list_element
    p "save" <<first_list_element.save.to_s
    p "save" << last_list_element.save.to_s
  end

  def reset_navigation(result)
    
    @end_time = Time.now

    if @start_time # only measure if its not the inital call
      puts "selected: #{result.name} / Goal: #{@data_set[@index-1]} / MS: #{(@end_time-@start_time)*1000} ms / Next: #{@next_step_counter} / Prev: #{@next_step_counter}"
      next_prefered = false
      next_prefered = true if (@next_step_counter>@prev_step_counter)
      total_steps_done = @next_step_counter+@prev_step_counter
      expected_min_distance_next = @data_set[@index-1][0]-"A"[0]
      expected_min_distance_prev= "Y"[0]-@data_set[@index-1][0]+1
      if expected_min_distance_next < expected_min_distance_prev
        min_dist = expected_min_distance_next
      else
        min_dist = expected_min_distance_prev
      end
      seconds_p_steps = ((@end_time-@start_time)*1000)/total_steps_done
      @csv << [@data_set[@index-1],result.name,min_dist,(@end_time-@start_time)*1000,@next_step_counter,@prev_step_counter,next_prefered,total_steps_done,seconds_p_steps] if @csv
      @csv.flush
      @start_time = nil
      @next_step_counter = 0
      @prev_step_counter = 0
    else
        p "no start time"
    end


    if result
      p "resetnavigation for #{result.name}"
#    result.process_event!("unchoose")
      result.process_event("defocus")
    else
      p "no result!!!"
    end

    first_list_element = AISingleChoice.first(:name=>"9").childs.first
    first_list_element.process_event("focus")

    mark
  end

  def mark
    p "unmark: #{@marked.name}" if @marked
    @marked.process_event(:unmark) if @marked
    return if @index>=@data_set.length

    p "set mark for #{@data_set[@index]}"

    to_mark = MarkableRadioButton.first(:name=>@data_set[@index])
    to_mark.process_event(:mark)

    @marked = to_mark
    @index += 1
  end

  def count_next(r)
    p "count next"
    check_first_step

    @next_step_counter += 1
  end

  def count_prev(r)
    check_first_step
    @prev_step_counter += 1
  end

  def check_first_step
    return  if (@next_step_counter > 0 or @prev_step_counter > 0)
    @start_time = Time.now
  end
end

s = NavTestAgent.new(ARGV)

mapping_click = ExecuteOnStateChange.new(AIINChoose,"chosen",s.method(:reset_navigation),s.method(:reset_navigation))
s.addMapping(mapping_click)


gesture_next= ExecuteOnStateChange.new(HandGesture,"next",s.method(:count_next))
s.addMapping(gesture_next)

gesture_previous= ExecuteOnStateChange.new(HandGesture,"previous",s.method(:count_prev))
s.addMapping(gesture_previous)


s.run



