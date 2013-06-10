module EasyLibrasBackend

  def EasyLibrasBackend.initialize
    @current_video = 0
  end

  def EasyLibrasBackend.setVideo(command)
    p "called start"

    vp = VideoPlayer.first(:name => 'libras_video')
    videos = Learningcycle.first.librasvideos

    path = nil
    if videos.length <= @current_video
      @current_video = 0
    end
    vp.video_url = videos[@current_video].path
    vp.save

    @current_video += 1
  end

  def EasyLibrasBackend.video_ended(command)
    # start recognition
    @learner.process_event :start
    # start recognition_ticker


  end

  def EasyLibrasBackend.ticker_ended(command)

  end
end