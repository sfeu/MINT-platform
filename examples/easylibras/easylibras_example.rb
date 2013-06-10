
# -*- coding: utf-8 -*-
require 'rubygems'
require "bundler/setup"
require 'dm-core'
require 'redis'
require "eventmachine"
require 'hiredis'
require 'fiber'

EM.run {
  require "MINT-core"
  require "./easylibras_backend"

  redis = Redis.connect
  redis.flushdb

  DataMapper.setup(:default, { :adapter => "redis", :host =>"0.0.0.0",:port=>6379})

  include MINT
  include CUIControl
  include AUIControl
  # include MusicSheet

  DataMapper.finalize

  SCXMLClient.new("Interactor.Learningcycle","libras_recognizer").start #("10.10.0.2")

  m = MappingManager.new
  #MappingServer.new.start(m)

  lr = LibrasRecognizer.create(:name => 'libras_recognizer')
  lr.start #("0.0.0.0", 3004)

  m.started do
    Fiber.new {

      # IRM Model Interactors
      ########################
      mouse = Mouse.create(:name=>"mouse")

      # for browser refresh handling
      BrowserScreen.create(:name =>"screen")

      # AIM Model Interactors
      ########################

      root = AIContainer.create(:name =>"html_header",:states=>[:organized])

      libras_video = AIO.create(:name => "libras_video",:states=>[:organized])
      user_video = AIO.create(:name => "user_video",:states=>[:organized])

      progress = AIOUTContinuous.create(:name=>"progress", :data =>50, :states=>[:organized])
      start = AICommand.create(:name=>"start", :text =>"Start", :states=>[:organized])

      logo = AIOUT.create(:name=>"logo", :states=>[:organized])

      root.save



      # CIM HTML GfX Model Interactors
      ###################################

      HEIGHT=680
      WIDTH=1280

      HTMLHead.create(:name =>"html_header",
                      :css=>"http://vjs.zencdn.net/4.0/video-js.css|/easylibras_example/application.css",
                      :states=>[:positioned])

      lc = Learningcycle.create(:name =>'learner')
      lc.librasvideos << Librasvideo.new(:word => 'A',:path=>'/easylibras_example/A.mp4')
      lc.librasvideos << Librasvideo.new(:word => 'E',:path=>'/easylibras_example/E.mp4')
      lc.librasvideos << Librasvideo.new(:word => 'I',:path=>'/easylibras_example/I.mp4')
      lc.librasvideos << Librasvideo.new(:word => 'O',:path=>'/easylibras_example/O.mp4')
      lc.librasvideos << Librasvideo.new(:word => 'U',:path=>'/easylibras_example/U.mp4')
      lc.save

      vp = VideoPlayer.create(:name => 'libras_video',
                         #:video_url => '/easylibras_example/U.mp4',
                         :video_type => "video/mp4",
                         :poster_url => "",
                         :x=>0,
                         :y=>120,
                         :width => 640,
                         :height => 480, :states=>[:positioned], :depends => "html_header")

      WebCam.create(:name => "user_video",
                    :x=> 641,:y=>120,
                    :width=>640, :height => 480,
                    :states=>[:positioned])

      ProgressBar.create(:name=>"progress",
                         :height =>60, :width => 1200,
                         :x=>40, :y => 610,
                         :states=>[:positioned],
                         :highlightable =>false)

      ToggleButton.create(:name=>"start",:height =>60, :width => 200, :x=>560, :y => 670, :states=>[:positioned], :highlightable =>true)

      Image.create(:name=>"logo",:path => "/easylibras_example/logo.png",:highlightable =>false,:height =>108, :width => 381, :x=>450, :y => 10,:states=>[:positioned],:depends => "start")

      CUIControl.fill_active_cio_cache

      # Connect IRMs and present app
      ###################################

      EasyLibrasBackend.initialize

      mouse.process_event :connect
      root.process_event :present

      logo.process_event :present

      libras_video.process_event :present
      user_video.process_event :present
      progress.process_event :present
      start.process_event :present

      # dialogue state machine


    }.resume nil
  end
  m.load("./mim/mim_easylibras_example.xml")
}

