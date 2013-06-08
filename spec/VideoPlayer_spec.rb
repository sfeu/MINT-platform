require "spec_helper"

require "em-spec/rspec"

describe 'CUI' do
  include EventMachine::SpecHelper

  before :all do
    connection_options = { :adapter => "redis"}
    DataMapper.setup(:default, connection_options)


    connect do |redis|
      require "MINT-core"
      class Logging
        def self.log(mapping,data)
          p "log: #{mapping} #{data}"
        end
      end
      DataMapper.finalize
      DataMapper::Model.raise_on_save_failure = true
    end
  end

  describe 'VideoPlayer' do

    it 'should make transition to ended' do
      connect do |redis|
        require "MINT-core"

        DataMapper.finalize

        #test_state_flow redis,"Interactor.CIO" ,%w(initialized positioning)

        MINT::VideoPlayer.create(:name => "vp")
        @c = MINT::VideoPlayer.first

        @c.process_event :position
        @c.process_event :calculated
        @c.process_event :display
        s = MINT::VideoPlayer.first
        @c.process_event :play

        s.states.should ==[:displayed, :paused]
        s.sync_states
        s.states.should ==[:displayed, :playing]

        s.new_states.should ==[:playing]

        p s.process_event :ended
        s.states.should ==[:displayed, :paused]

        @c = MINT::VideoPlayer.first
        @c.new_states.should ==[:paused]
        @c.states.should ==[:displayed, :paused]


      end
    end

  end
end
