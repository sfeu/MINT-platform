
# -*- coding: utf-8 -*-
require 'rubygems'
require "bundler/setup"
require 'dm-core'
require 'redis'
require "eventmachine"
require 'hiredis'
require 'fiber'
# require "./music_sheet_backend"

EM.run {
  require "MINT-core"

  redis = Redis.connect
  redis.flushdb

  DataMapper.setup(:default, { :adapter => "redis", :host =>"0.0.0.0",:port=>6379})

  include MINT
  include CUIControl
  include AUIControl
  # include MusicSheet

  DataMapper.finalize

  m = MappingManager.new
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

      progress = AIOUTContinuous.create(:name=>"progress", :data =>0, :states=>[:organized])
      start = AICommand.create(:name=>"start", :text =>"Start", :states=>[:organized])

      logo = AIOUT.create(:name=>"logo", :states=>[:organized])

      root.save



      # CIM HTML GfX Model Interactors
      ###################################

      HEIGHT=680
      WIDTH=1280

      HTMLHead.create(:name =>"html_header",
                      :css=>["http://vjs.zencdn.net/4.0/video-js.css","/easylibras_example/application.css"],
                      :js=>["http://vjs.zencdn.net/4.0/video.js"],:states=>[:positioned])

      VideoPlayer.create(:name => 'libras_video',
                         :video_url => '/easylibras_example/A.mp4',
                         :video_type => "video/mp4",
                         :poster_url => "",
                         :x=>0,
                         :y=>120,
                         :width => 640,
                         :height => 480, :states=>[:positioned])

      WebCam.create(:name => "user_video",
                    :x=> 641,:y=>120,
                    :width=>640, :height => 480,
                    :states=>[:positioned])

      ProgressBar.create(:name=>"progress",
                         :height =>60, :width => 1200,
                         :x=>40, :y => 610,
                         :states=>[:positioned],
                         :highlightable =>false)

      Button.create(:name=>"start",:height =>60, :width => 200, :x=>560, :y => 670, :states=>[:positioned], :highlightable =>true)

      Image.create(:name=>"logo",:path => "/easylibras_example/logo.png",:highlightable =>false,:height =>108, :width => 381, :x=>450, :y => 10,:states=>[:positioned],:depends => "start")

      CUIControl.fill_active_cio_cache

      # Connect IRMs and present app
      ###################################

      mouse.process_event :connect
      root.process_event :present

      logo.process_event :present

      libras_video.process_event :present
      user_video.process_event :present
      progress.process_event :present
      start.process_event :present

    }.resume nil
  end
  m.load("./mim/mim_easylibras_example.xml")

}

