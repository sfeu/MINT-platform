module MINT2
   DataMapper::Model.raise_on_save_failure = true

  class AIO < MINT::Element
    property :label, String
    property :description, Text,   :lazy => false

    #has 1, :neighbour_parent, :child_key =>[:source_id]
    #has 1, :parent, 'MINT2::AIC', :through => :neighbour_parent, :via => :target

    belongs_to :parent, "MINT2::AIC",
                   :parent_key => [ :id ],
                   :child_key  => [ :aic_id ],
                   :required   => false



    has 1, :link, :child_key =>[:source_id]
    has 1, :previous, self, :through => :link, :via => :target

   # has 1, :neighbour_previous, :child_key =>[:source_id]
   # has 1, :previous, self, :through => :neighbour_previous, :via => :target


    def initialize_statemachine
      if @statemachine.nil?
        parser = StatemachineParser.new(self)
        @statemachine = parser.build_from_scxml "#{File.dirname(__FILE__)}/aio.scxml"

        @statemachine.reset

      end
    end
    # hook to inform parent about presenting state
    def inform_parent_presenting
      self.parent.child_to_presenting(self) if (self.parent)
      true
    end

    def sync_event(event)
      process_event(event, AIO_sync_callback.new)
    end

    # callbacks

    def exists_next
      self.next!=nil
    end

    def exists_prev
      self.previous!=nil
    end

    def sync_cio_to_displayed
      cio =  MINT::CIO.first(:name=>self.name)
      if (cio and not cio.is_in? :displayed)
        if (cio.is_in? :suspended or cio.is_in? :positioned)
          cio.sync_event(:display)
        else
          cio.sync_event(:unhighlight)
        end
        #cio.states=[:displayed]
      end
      true
    end

    def sync_cio_to_highlighted
      cio =  MINT::CIO.first(:name=>self.name)
      if (cio and not cio.is_in? :highlighted)
        cio.sync_event(:highlight)
        # cio.states=[:highlighted]
      end
      true
    end

     def sync_cio_to_hidden
      cio =  MINT::CIO.first(:name=>self.name)
      if (cio and not cio.is_in? :hidden)
        cio.sync_event(:hide)
        end
      true
     end

    def focus_previous
      if (self.previous)
        self.previous.process_event("focus")
      else
        return false # TODO not working, find abbruchbedingung!!!
      end
    end

    def focus_parent
      if (self.parent)
        self.parent.process_event("focus")
      else
        return false # TODO not working, find abbruchbedingung!!!
      end
    end

    def focus_next
      if (self.next)
        if self.next.process_event("focus")
          return true
        else
          puts "ERRROR #{self.next.name} could not execute focus event"
          return false
        end
      else
        puts "WARNING!! > no next element found!"
        return false
      end
    end

  end

  class AicAio
    include DataMapper::Resource

    property :id,   Serial

    belongs_to :AIC,'MINT2::AIC'
    belongs_to :AIO ,'MINT2::AIO'

  end
  class Link
    include DataMapper::Resource

    belongs_to :source, 'MINT2::AIO', :key => true
    belongs_to :target, 'MINT2::AIO', :key => true
  end
  class NeighbourPrevious
    include DataMapper::Resource

    belongs_to :source, 'AIO', :key => true
    belongs_to :target, 'AIO', :key => true
  end
end