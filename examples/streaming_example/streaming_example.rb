# -*- coding: utf-8 -*-
require 'rubygems'
require "bundler/setup"
require 'dm-core'
require 'redis'
require "eventmachine"
require 'hiredis'
require 'fiber'
require "./example_app_backend"
EM.run {
  require "MINT-core"

  Redis.connect.flushdb

  DataMapper.setup(:default, { :adapter => "redis", :host =>"0.0.0.0",:port=>6379})

  include MINT
  include AUIControl

  DataMapper.finalize
  CUIControl.fill_active_cio_cache

  # Start server to connect mapping tool
  SCXMLClient.new("Interactor.AIO.AIOUT.AIOUTContinuous*",nil).start

  m = MappingManager.new
  MappingServer.new.start(m)
  m.started do
    Fiber.new {
      # Clean old
      #AUIControl.suspend_all

      # IRM Model Interactors
      ########################
      mouse = Mouse.create(:name=>"mouse")

      # for browser refresh handling
      BrowserScreen.create(:name =>"screen")

      # AIM Model Interactors
      ########################
      header = AIContainer.create(:name =>"html_header",:states=>[:organized],:children => "")

      app = AIContainer.create(:name=>"streaming_example", :states=>[:organized], :children => "reset|volume|volume_ref|slider|slider_ref")
      AICommand.create(:name=>"reset", :text =>"Reset",:parent=>"streaming_example", :states=>[:organized])

      AIOUTContinuous.create(:name=>"volume", :data =>0,:parent=>"streaming_example", :states=>[:organized])
      AIReference.create(:name=>"volume_ref", :text=>"Volume", :refers =>"volume",:parent=>"streaming_example", :states=>[:organized])

      AIINContinuous.create(:name=>"slider", :data =>0,:parent=>"streaming_example", :states=>[:organized])
      AIReference.create(:name=>"slider_ref", :text=>"Slider", :refers =>"slider",:parent=>"streaming_example", :states=>[:organized])

      # CIM HTML GfX Model Interactors
      ###################################
      HTMLHead.create(:name =>"html_header",:css=>"/streaming_example/streaming_example.css",:js=>"",:states=>[:positioned])

      CIC.create(:name =>"streaming_example",:x=>15, :y=>15, :width =>580, :height => 300,:layer=>0, :rows=>3, :cols=>1,:states=>[:positioned])
      Button.create(:name=>"reset",:height =>60, :width => 200, :x=>200, :y => 230, :states=>[:positioned], :highlightable =>true)

      ProgressBar.create(:name=>"volume",:height =>80, :width => 500, :x=>40, :y => 130, :states=>[:positioned], :highlightable =>true)
      Label.create(:name=>"volume_ref",:highlightable =>false,:height =>80, :width => 500, :x=>40, :y => 90,:states=>[:positioned],:depends => "volume")

      Slider.create(:name=>"slider",:height =>60, :width => 500, :x=>40, :y => 50, :states=>[:positioned], :highlightable =>true)
      Label.create(:name=>"slider_ref",:highlightable =>false,:height =>80, :width => 500, :x=>40, :y => 10,:states=>[:positioned],:depends => "slider")

      # Connect IRMs and present app
      ###################################

      mouse.process_event :connect
      header.process_event :present
      app.process_event :present
    }.resume nil
  end
  #m.load("../../../MINT-core/lib/MINT-core/model/mim/mim_default.xml")
  m.load("./mim/mim_streaming_example.xml")



}

