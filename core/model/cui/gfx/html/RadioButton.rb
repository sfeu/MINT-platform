module MINT

  class RadioButton < HTMLWidget
    def getSCXML
         "#{File.dirname(__FILE__)}/radiobutton.scxml"
       end
  end
end