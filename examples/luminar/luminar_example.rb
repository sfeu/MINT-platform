# -*- coding: utf-8 -*-
require 'rubygems'
require "bundler/setup"
require 'dm-core'
require 'redis'
require "eventmachine"
require 'hiredis'
require 'fiber'
require './polaroid'
require "./calibration_app"
require "./fingertracker2"
require "./sound"


EM.run {
  require "MINT-core"

  redis = Redis.connect
  redis.flushdb
  DataMapper.setup(:default, { :adapter => "redis", :host =>"0.0.0.0",:port=>6379})

  include MINT
  include AUIControl
  include CUIControl
  include Sound
  include CalibrationApp

  DataMapper.finalize

  Sound.init

  f = Fingertip.create(:name => "fingertip")
  FingerTracker.new(f)

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
      header = AIContainer.create(:name =>"html_header",:states=>[:organized],:children => "")

      app = AIContainer.create(:name=>"calibration", :states=>[:organized], :children => "1|2|3|4")
      AICommand.create(:name=>"1", :text =>"1", :parent=>"calibration", :states=>[:organized])
      AICommand.create(:name=>"2", :text =>"2", :parent=>"calibration",:states=>[:organized])
      AICommand.create(:name=>"3", :text =>"3", :parent=>"calibration",:states=>[:organized])
      AICommand.create(:name=>"4", :text =>"4", :parent=>"calibration",:states=>[:organized])

      # CIM HTML GfX Model Interactors
      ###################################
      HTMLHead.create(:name =>"html_header",:css=>"/luminar/photo_app.css",:js=>"",:states=>[:positioned])
      CIC.create(:name =>"calibration",:x=>0, :y=>0, :width =>640, :height => 480,:layer=>0, :rows=>3, :cols=>1,:states=>[:positioned])
      Button.create(:name=>"1",:height =>239, :width => 319, :x=>0, :y => 0, :states=>[:positioned], :highlightable =>true)
      Button.create(:name=>"2",:height =>239, :width => 319, :x=>320, :y => 0, :states=>[:positioned], :highlightable =>true)
      Button.create(:name=>"3",:height =>239, :width => 319, :x=>0, :y => 240, :states=>[:positioned], :highlightable =>true)
      Button.create(:name=>"4",:height =>239, :width => 319, :x=>320, :y => 240, :states=>[:positioned], :highlightable =>true)

      # Second Screen: Photo Application

      photo_app = AIContainer.create(:name=>"photo_app", :states=>[:organized], :children => "joao|thais|arthur")

      AIOUT.create(:name =>"joao",:parent => "photo_app",:states=>[:organized])
      AIOUT.create(:name =>"thais",:parent => "photo_app",:states=>[:organized])
      AIOUT.create(:name =>"arthur",:parent => "photo_app",:states=>[:organized])

      Polaroid.create(:name=>"joao", :label=> "João",:path=>"/luminar/photos/joao.jpg",:x=>0, :y=>45, :width =>130, :height => 140,:states=>[:positioned])
      Polaroid.create(:name=>"thais",:label => "Thais",:path=>"/luminar/photos/thais.jpg",:x=>160, :y=>45, :width =>130, :height => 140,:states=>[:positioned])
      Polaroid.create(:name=>"arthur",:label=> "Arthur",:path=>"/luminar/photos/arthur.jpg",:x=>320, :y=>45, :width =>130, :height => 140,:states=>[:positioned])
      CIC.create(:name =>"photo_app",:x=>0, :y=>0, :width =>640, :height => 480,:layer=>0, :rows=>3, :cols=>1,:states=>[:positioned])

      CUIControl.fill_active_cio_cache

      # Connect IRMs and present app
      ###################################
      mouse.process_event :connect

      header.process_event :present
      app.process_event :present
      #photo_app.process_event :present
    }.resume nil
  end
  m.load("./mim/mim_streaming_example.xml")
}

