module MINT

  module JavaScript
    def getJS
      nil
    end


    def js
      p = super
      result = nil
      if p
        result=[]
        return p.split("|")

      else
        []
      end
    end

    def js= children
      if children.is_a? Array
        super(children.join("|"))
      else
        super(children)
      end
    end

  end

  module CSS
    def getCSS
      nil
    end

    def css
      p = super
      result = nil
      if p
        result=[]
        return p.split("|")
      else
        []
      end
    end

    def css= children
      if children.is_a? Array
        super(children.join("|"))
      else
        super(children)
      end
    end
  end

  class HTMLWidget < CIO
    include MINT::JavaScript
    include MINT::CSS

    property :css, String, :default => lambda { |r,p| r.getCSS}
    property :js, String, :default => lambda { |r,p| r.getJS}


  end

  class HTMLContainer < CIC
    include MINT::JavaScript
    include MINT::CSS
    property :css, String, :default => lambda { |r,p| r.class.getCSS}
    property :js, String, :default => lambda { |r,p| r.class.getJS}
  end



  class Slider < HTMLWidget

  end

  class MinimalOutputSlider < HTMLWidget

  end

  class MinimalVerticalOutputSlider < HTMLWidget

  end

  class ProgressBar < HTMLWidget

  end


  class HTMLHead < HTMLWidget




  end

  #
  #class FurnitureItem < Selectable
  #  property :title, String
  #  property :price, String
  #  property :image, String
  #  property :description, String
  #end

  class SingleHighlight < HTMLContainer
  end


  class ARFrame <  HTMLWidget

  end

  #class CheckBox < Selectable
  #end

  class CheckBoxGroup < HTMLContainer
  end

  require "MINT-core/model/cui/gfx/html/RadioButton"
  require "MINT-core/model/cui/gfx/html/RadioButtonGroup"
  require "MINT-core/model/cui/gfx/html/MarkableRadioButton"

  class BasicText < HTMLWidget
  end

  class Label <HTMLWidget
  end

end