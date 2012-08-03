
module MINT

  class OneHandNavFlexibleTicker < OneHand

     def initialize_statemachine
      if @statemachine.blank?
        @statemachine = Statemachine.build do
          trans :NoHands, :one_hand, :OneHand

          superstate :OneHand do
            event :no_hands, :NoHands
            superstate :Command do
              trans :wait_one, :select, :selected
              trans :selected, :confirm, :confirmed
              trans :confirmed, :tick, :wait_one # tick will be triggered in on_enter(confirmed)

              event :prev_gesture, :previous
              event :next_gesture, :next
            end

            superstate :Navigation do
              event :select, :selected
              parallel :p do
                statemachine :Neighbours do
                  trans :previous, :tick, :previous, :issued_prev
                  trans :previous, :next_gesture, :start_n
                  trans :start_n, :tick, :next, :issued_next
                  trans :next, :tick, :next, :issued_next
                  trans :next, :prev_gesture, :start_p
                  trans :start_p,:tick, :previous,:issued_prev
                end
                statemachine :Ticker do
                  superstate :Clock do
                    state :started do
                      on_entry :start_ticker
                      on_exit :stop_ticker
                    end
                  end
                end
                statemachine :Movement do
                  superstate :Speed do
                    trans :normal, :closer, :faster
                    trans :faster, :closer, :fastest
                    trans :fastest, :farer, :faster
                    trans :faster, :farer, :normal

                    state :normal do
                      on_entry [Proc.new { @command_timeout=1.2},:restart_ticker]
                    end
                    state :faster do
                      on_entry [Proc.new { @command_timeout=1},:restart_ticker]
                    end
                    state :fastest do
                      on_entry [Proc.new { @command_timeout=0.8},:restart_ticker]
                    end
                  end
                end
              end
            end
          end
        end
        @statemachine.activation= self.method(:activate)
      end
    end
  end
end
