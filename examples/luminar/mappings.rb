# -*- coding: utf-8 -*-
require 'rubygems'
require "bundler/setup"
require 'dm-core'
require 'redis'
require "eventmachine"
require 'hiredis'
require "json"
require "MINT-core"
require "./calibration_app"

require "./fingertracker2"
require "./sound"


EM.run {
  require "MINT-core"
  require './polaroid'

  redis = Redis.connect

  DataMapper.setup(:default, { :adapter => "redis", :host =>"0.0.0.0",:port=>6379})

  include MINT
  include CUIControl
  include Sound

  DataMapper.finalize
  include CalibrationApp

  Sound.init
  f = Fingertip.create(:name => "fingertip")
  FingerTracker.new(f)

  CUIControl.fill_active_cio_cache

  m = MappingManager.new
  #m.load("../../../MINT-core/lib/MINT-core/model/mim/mim_default.xml")
  m.load("./mim/mim_streaming_example.xml")

  # Start server to connect mapping tool
  #MappingServer.new.start(m)

  # start position updater to know about widgets positions in browser
  #PositionUpdater.new.start
}

