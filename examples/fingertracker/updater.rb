class Updater

  def initialize(left_hand, right_hand)
    @hands = [left_hand,right_hand]
    @finger_count = [0,0]
    @last_seen=[[],[]]
    @channel_name = "ss:event"
  end

  # @TODO a finger delete command is sent every time a nil is found, even ths finger already has been deleted!
  def send_update
    log =""

    @hands.each_with_index do |hand,i|
      fingers = hand.get_fingers
      new_max_nr = @finger_count[i]

      numbers = fingers.keys
      numbers.each do |k|
        if k>@finger_count[i]
          log << add_finger(fingers[k],k)
          new_max_nr = k if k>=new_max_nr
        else
          log << update_finger(fingers[k],k)
        end
      end

      @finger_count[i] = new_max_nr

      # delete fingers
      (@last_seen[i] - numbers).each do |k|
        log << delete_finger(k)
      end
      @last_seen[i] = numbers
    end
    p log if log.length>0
  end

  def update_finger coordinate,nr
    RedisConnector.redis.publish @channel_name,create_data("POS",nr,coordinate[0],coordinate[1])
    #Juggernaut.publish("thumb", create_data("POS",nr,coordinate[0],coordinate[1]))
    "- U #{nr}/#{coordinate[0]}/#{coordinate[1]}"
  end

  def add_finger coordinate,nr
    RedisConnector.redis.publish @channel_name,create_data("NEW",nr,coordinate[0],coordinate[1])
    #Juggernaut.publish("thumb", create_data("NEW",nr,coordinate[0],coordinate[1]))
    "- A #{nr}/#{coordinate[0]}/#{coordinate[1]}"
  end

  def delete_finger nr
    RedisConnector.redis.publish @channel_name,create_data("DEL",nr)
    #Juggernaut.publish("thumb", create_data("DEL",nr))
    " - D #{nr}"
  end

  def create_data(cmd,identifier, x=1, y=1)
    #{:cmd=>cmd,:touch=>{:identifier=>"touch-#{identifier}",:pageX=>x,:pageY=>y}}.to_json
    {:t => "channel", :channels => ["user:testuser"],:e => "touch", :p => {:cmd=>cmd,:touch=>{:identifier=>"touch-#{identifier}",:pageX=>x,:pageY=>y}}}.to_json
  end
end