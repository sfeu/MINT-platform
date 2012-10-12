require "MINT-core"

module MINT


  class Polaroid < Image

    property :label,            String,  :default => ""
    property :rotation,         Integer,  :default => 0
    property :scale,         Integer,  :default => 100

  end
end
