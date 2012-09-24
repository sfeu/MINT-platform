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




  #redis = Redis.connect
  #redis.flushdb

  DataMapper.setup(:default, { :adapter => "redis", :host =>"0.0.0.0",:port=>6379})

  include MINT
  include AUIControl

  DataMapper.finalize
  Fiber.new {
    # Clean old
    AUIControl.suspend_all

     # IRM Model Interactors
    ########################
    mouse = Mouse.create(:name=>"mouse")

    # for browser refresh handling
    BrowserScreen.create(:name =>"screen")

    # AIM Model Interactors
    ########################
    header = AIContainer.create(:name =>"html_header",:states=>[:organized],:children => "")

    app = AIContainer.create(:name=>"streaming_example", :states=>[:organized], :children => "reset|volume|slider")
    AICommand.create(:name=>"reset", :label =>"Reset",:parent=>"streaming_example", :states=>[:organized])
    AIOUTContinuous.create(:name=>"volume", :data =>0,:parent=>"streaming_example", :states=>[:organized])
    AIINContinuous.create(:name=>"slider", :label =>"Slider", :data =>0,:parent=>"streaming_example", :states=>[:organized])

    # CIM HTML GfX Model Interactors
    ###################################
    HTMLHead.create(:name =>"html_header",:css=>"",:js=>"",:states=>[:positioned])

    CIC.create(:name =>"streaming_example",:x=>15, :y=>15, :width =>580, :height => 300,:layer=>0, :rows=>3, :cols=>1,:states=>[:positioned])
    Button.create(:name=>"reset",:height =>60, :width => 200, :x=>380, :y => 170, :states=>[:positioned], :highlightable =>true)
    ProgressBar.create(:name=>"volume",:height =>80, :width => 300, :x=>40, :y => 120, :states=>[:positioned], :highlightable =>true)
    Slider.create(:name=>"slider",:height =>60, :width => 300, :x=>40, :y => 20, :states=>[:positioned], :highlightable =>true)

    # Connect IRMs and present app
    ###################################

    mouse.process_event :connect
    header.process_event :present
    app.process_event :present
  }.resume nil
}

