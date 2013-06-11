module MINT
  class Librasvideo
    include DataMapper::Resource
    property :id, Serial
    property :word, String
    property :path, String
    belongs_to :learningcycle
  end

  class Learningcycle < Interactor

    # Duration of each learning cycle in seconds
    property :duration, Integer,  :default => 5
    property :data, Integer,  :default => 0

    has n, :librasvideos

    def getSCXML
      "#{File.dirname(__FILE__)}/learningcycle.scxml"
    end

    def start_ticker
      @channel_name =  create_attribute_channel_name('data')
      @counter = 0.0
      @ticker = EM::PeriodicTimer.new(1) {
        if @counter <= duration
          @counter += 1
          data = ((@counter/duration)*100).to_i
          RedisConnector.redis.publish(@channel_name,MultiJson.encode({:name=>self.name,:data => data}))
        else
          sync_states
          process_event :end
          @ticker.cancel if @ticker
        end
      }
    end



  end
end