module MINT
  # An {Interactor} is the basic abstract element of the complete MINT markup language. Nearly all  other
  # classes are derived  from {MINT::Interactor} since early everything can be activated by {#state} and has
  # a {#name}. 
  #
  class Interactor
    include DataMapper::Resource
    include MINT::InteractorHelpers
    def self.getModel
      "core"
    end


    class << self
      alias get_dm get
    end

    def self.get(*name)
      if name.length == 1
        get_dm(getModel,name[0])
      else
        get_dm(*name)
      end
    end

    private


    property :classtype, Discriminator
    property :mint_model, String, :default => lambda { |r,p| r.class.getModel}, :key=>true

    # Each abstract  {Interactor} needs to have a name that we will use as the primary key for each model.
    property :name, String, :key => true
    #property :id, Serial

    # States of the {Interactor} Reflects the actual atomic states of the interactors state machine.
    property :states, String

    # reflects all active states including abstract superstates of an interactor as a |-seperated state id list
    property :abstract_states, String

    #always contains the new atomic states that have been entered by the event that has been processed - especially useful for parallel states
    property :new_states, String

    # contains the channel name of the interactor, which is composed by all merging all parent class names
    # and used as a communication channel for the interactors to exchange realtime information
    property :channel, String,  :default => lambda { |r,p| r.class.create_channel_name}

    protected
    before :save, :save_statemachine
    after :create, :init_statemachine

    public

    def init_statemachine
      initialize_statemachine true
    end


    PUBLISH_ATTRIBUTES = [:name,:states,:abstract_states,:new_states,:classtype, :mint_model]

    def self.create_channel_name
      a = [self]
      a.unshift a.first.superclass while (a.first!=MINT::Interactor)
      a.map!{|x| x.to_s.split('::').last}
      a.join(".")
    end

    def create_attribute_channel_name(attribute)
      "#{attribute}:"+self.class.create_channel_name+".#{self.name}"
    end

    def out_channel_w_name
      "out_channel:"+ create_channel_w_name
    end

    def new_states_channel_w_name
      "new_states:"+ create_channel_w_name
    end


    def create_channel_w_name
      self.class.create_channel_name+".#{self.name}"
    end


    def self.class_from_channel_name(channel)
      Object.const_get("MINT").const_get channel.split('.').last
    end

    def publish_update(states,abstract_states, atomic_states)


      as_copy = attribute_get(:abstract_states)
      new_copy = attribute_get(:new_states)
      states_copy = attribute_get(:states)

      attribute_set(:abstract_states, abstract_states.join('|'))
      attribute_set(:new_states, states.join('|'))
      attribute_set(:states, atomic_states.join('|'))

      RedisConnector.redis.publish self.create_channel_w_name, self.to_json(:only => self.class::PUBLISH_ATTRIBUTES)

      publish_new_states abstract_states.join('|'), atomic_states.join('|'), states.join('|')

      attribute_set(:abstract_states, as_copy)
      attribute_set(:new_states, new_copy)
      attribute_set(:states, states_copy)

    end

    def sync_states()
      values = RedisConnector.sync_redis.hmget "mint_interactors:#{self.class.getModel}#{name}","states","new_states","abstract_states"

      attribute_set(:abstract_states, values[2])
      attribute_set(:new_states, values[1])
      attribute_set(:states, values[0])
      save! # TODO Bugfix - in some situations states does not get updated for upcoming new states - this save seems to fix it.
      recover_statemachine

    end

    def self.notify(action,query,callback,time = nil)
      RedisConnector.sub.subscribe("#{self.create_channel_name}")

      RedisConnector.sub.on(:message) { |channel, message|
        found=MultiJson.decode message
        puts query.inspect
        query.keys.each do |k|
          if found[k.to_s]
            a = found[k.to_s]
            query[k].each do |e|
              puts "found #{e} a:#{a.inspect}"
              if a.include? e
                callback.call found
                break
              end
            end
          end
        end
      }
    end


    def self.wait(action,query,callback,time = nil)
      # q = scoped_query(query)
      # q.repository.notify(action,query,callback,self,q, time)
    end

    def to_dot(filename)
      if not @statemachine
        initialize_statemachine
      end
      @statemachine.to_dot(:output => filename)
    end
    def states
      if not @statemachine
        initialize_statemachine
        recover_statemachine
      end
      @statemachine.states_id
    end

    def new_states
      if attribute_get(:new_states)
        return attribute_get(:new_states).split("|").map &:to_sym if attribute_get(:new_states).class!=Array
        return attribute_get(:new_states)
      else return []
      end
    end

    def states= states
      if not @statemachine # if called on element creation using the states hash!
        initialize_statemachine
      end
      @statemachine.states=states
      save_statemachine
    end

    # def initialize(attributes = nil)
    #   super(attributes)

    #    recover_statemachine
    # end

    # The sync event method is overwritten in the derived classes to prevent synchronization cycles by setting an empty callback
    def sync_event(event)
      process_event(event)
    end

    #allows to set variables that will be passed as parameters to the actions
    def process_event_vars(event, *vars)
      process_event(event,nil,vars)
    end

    def process_event(event, callback=nil, vars = nil)

      states = process_event!(event,callback,vars)
      if states
        save_statemachine
        return states
      else
        return false
      end
    end

    def process_event!(event, callback=nil,vars=nil)
      if not @statemachine
        initialize_statemachine
        recover_statemachine
      end
      if callback
        @statemachine.context = callback
      else
        @statemachine.context = self
      end
      begin
        old_states = @statemachine.states_id
        old_abstract_states = @statemachine.abstract_states
        @statemachine.process_event(event,*vars)
        calc_new_states = @statemachine.states_id-old_states
        calc_new_states = calc_new_states + (@statemachine.abstract_states - old_abstract_states)
        calc_new_states = @statemachine.states_id  if calc_new_states.length==0
        attribute_set(:new_states, calc_new_states.join('|'))
      rescue Statemachine::TransitionMissingException
        p "#{self.name} is in state #{self.states} and could not handle #{event}"
        return false
      end
      return @statemachine.states_id
    end

    def is_in?(state)
      if not @statemachine

        #return true if (attribute_get(:states).split('|').map &:intern).include? state.intern
        #return true if (attribute_get(:abstract_states).split('|').map &:intern).include? state.intern
        #return false
        initialize_statemachine
        recover_statemachine
      end
      @statemachine.In(state)
    end


    def getSCXML
      "#{File.dirname(__FILE__)}/interactor.scxml"
    end

    protected

    def initialize_statemachine(publish_initialize = false)
      if @statemachine.nil?
        parser = StatemachineParser.new(self)
        @statemachine = parser.build_from_scxml getSCXML

        @statemachine.activation=self.method(:publish_update)

        @statemachine.reset(nil,publish_initialize)

      end
    end

    private

    def save_statemachine
      if not @statemachine
        initialize_statemachine true
        recover_statemachine
      end
      attribute_set(:states, @statemachine.states_id.join('|'))
      attribute_set(:abstract_states, @statemachine.abstract_states.join('|'))
      # attribute_set(:new_states,new_states) if new_states and new_states.length>0 # second condition to
      save!
      # publish_update
    end


    # @TODO check this for parallel states!
    def recover_statemachine
      if (@statemachine.nil?)
        initialize_statemachine
      end
      if attribute_get(:states)
        if attribute_get(:states).is_a? Array # @TODO this should not occur!!
          @statemachine.states=attribute_get(:states)
        else
          @statemachine.states=attribute_get(:states).split('|').map &:intern
        end

      else
        attribute_set(:states, @statemachine.states_id.join('|'))
        attribute_set(:abstract_states, @statemachine.abstract_states.concat(@statemachine.states_id).join('|'))
      end
      if not attribute_get(:new_states)
        attribute_set(:new_states, @statemachine.states_id.join('|'))
      end
    end

    def is_set(attribute)
      self.attribute_get(attribute)!=nil
    end


    def start_publishing_state

      @publish_new_states = true

    end

    def stop_publishing_state
      @publish_new_states = false
    end

    def publish_new_states abstract_states, states, new_states
      return if not @publish_new_states
      if @in_state_filter
        if not (found['abstract_states'] =~ /in_state_filter/) or not (found['states'] =~ /in_state_filter/)
          return
        end

      end

      RedisConnector.redis.publish(new_states_channel_w_name,{:new_states => new_states})
    end

    def start_consume_client_state_changes
      redis = RedisConnector.redis
      sub_channel = "in_channel:"+channel+"."+name+":*"
      p "subscribe for "+ sub_channel
      redis.pubsub.psubscribe(sub_channel) { |channel,message|
        p "#{name} received state change from client to #{message}"
        sync_states
        process_event message

      }
    end

    def  stop_consume_client_state_changes
      RedisConnector.sub.unsubscribe "in_channel:"+channel+":*"
    end
  end



end
