module MINT
  class AISinglePresence < AIC
    def initialize_statemachine
      if @statemachine.blank?
        @statemachine = Statemachine.build do
          trans :initialized,:organized, :organized
          trans :organized, :present, :p
          trans :hidden,:present, :p
          state :hidden do
            on_entry :sync_cio_to_hidden
          end

          superstate :p_t do     # TODO artificial superstate required to get following event working!
            event :suspend, :hidden, :hide_children
            parallel :p do
              statemachine :s1 do
                superstate :presenting do
                  state :presented do
                    on_entry [:present_first_child, :sync_cio_to_displayed]
                  end
                  state :focused do
                    on_entry :sync_cio_to_highlighted
                  end
                  trans :presented,:focus,:focused
                  trans :focused,:defocus, :presented
                   trans :focused, :prev, :presented, :focus_previous, Proc.new { exists_prev}
                  trans :focused, :parent, :presented, :focus_parent

                end
              end
              statemachine :s2 do
                superstate :l do

                  trans :listing, :drop, :listing, :add_element
                end
              end
            end
          end
        end
      end
    end


    # hook that is called from a child if it enters presenting state
    def child_to_presenting(child)
      childs.all.each do |e|
        e.process_event(:suspend) if e.id != child.id and not e.is_in? :hidden
        end
    end

    def present_first_child
      childs[0].process_event :present
    end

    def add_element
      f = AISingleChoiceElement.first(:new_states=> /#{Regexp.quote("dragging")}/)
      self.childs << f
      self.childs.save
      f.process_event(:drop)
      f.destroy
    end
  end

end
