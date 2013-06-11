module MINT
  class LibrasRecognizer < Interactor
    include StandardModeProtocol
    property :recognized, String

    LEFT_HAND_POSE = 0
    RIGHT_HAND_POSE = 5

    def initialize(attributes = nil)
         super(attributes)
        @recognize = false
        @retrieved_recognitions = {}
       end

    def getSCXML
      "#{File.dirname(__FILE__)}/librasrecognizer.scxml"
    end

    def process_data(data)
      return if not @recognize

      d = data.split(';')
      if ( @retrieved_recognitions[d[RIGHT_HAND_POSE]])
        @retrieved_recognitions[d[RIGHT_HAND_POSE]] += 1
      else
        @retrieved_recognitions[d[RIGHT_HAND_POSE]] = 1
        end
      p d

    end

    def start_recognition
      @retrieved_recognitions = {}
      @recognize = true
    end

    def stop_recognition
      @recognize = false
    end

    def evaluate_result
      max_value = @retrieved_recognitions.values.max
      r = @retrieved_recognitions.select {|k,v| v == max_value}
      recognized = r.key if r
    end

  end
end