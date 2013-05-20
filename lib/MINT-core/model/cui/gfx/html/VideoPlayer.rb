module MINT
  class VideoPlayer < HTMLWidget
    property :video_url, String
    property :video_type, String
    property :poster_url, String

    def getJS
      "video"
    end

    def getSCXML
      "#{File.dirname(__FILE__)}/videoplayer.scxml"
    end
  end

  class WebCam < CIO

  end

end