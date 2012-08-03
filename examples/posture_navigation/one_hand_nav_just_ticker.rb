
module MINT

  class OneHandNavStaticTicker < OneHand

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
                  trans :start_p, :tick, :previous, :issued_prev
                end
                statemachine :Ticker do
                  superstate :Clock do
                    state :started do
                      on_entry :start_ticker
                      on_exit :stop_ticker
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
