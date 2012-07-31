# -*- coding: utf-8 -*-
require 'rubygems'
require "bundler/setup"
require 'dm-core'
require 'redis'
require "eventmachine"
require 'hiredis'
require "json"
require "MINT-core"

EM.run {
  require "MINT-core"

  redis = Redis.connect

  DataMapper.setup(:default, { :adapter => "redis", :host =>"0.0.0.0",:port=>6379})

  include MINT
  include CUIControl
  include AUIControl

  DataMapper.finalize

  CUIControl.fill_active_cio_cache

  m = MappingManager.new
    m.load("../../../MINT-core/lib/MINT-core/model/mim/mim_default.xml")
  m.load("./mim/mim_musicsheet_example.xml")

    # Start server to connect mapping tool
    MappingServer.new.start(m)



  # prevbuttonclick
  o8 = Observation.new(:element =>"Interactor.Pointer.Mouse",:name => "mouse", :states =>[:right_pressed], :result => "p")
  o9 = Observation.new(:element =>"Interactor.AIO.AIOUT.AIContainer.AISinglePresence",:name => "sheets", :continuous => true, :states =>[:entered], :result => "c")
  a5 = EventAction.new(:event => :prev,:target => "c")
  m5 = ComplementaryMapping.new(:name=>"right Click",:observations => [o8,o9],:actions =>[a5])
  #m5.start


  # next tilt-right
    o10 = Observation.new(:element =>"Interactor.Head",:name => "head", :states =>[:tilting_right], :result => "p")
    o11 = Observation.new(:element =>"Interactor.AIO.AIOUT.AIContainer.AISinglePresence",:name => "sheets", :continuous => true, :states =>[:entered], :result => "c")
    a6 = EventAction.new(:event => :next,:target => "c")
    m6 = ComplementaryMapping.new(:name=>"Next Tilt",:observations => [o10,o11],:actions =>[a6])
   # m6.start


  # prev tilt-left
      o12 = Observation.new(:element =>"Interactor.Head",:name => "head", :states =>[:tilting_left], :result => "p")
      o13 = Observation.new(:element =>"Interactor.AIO.AIOUT.AIContainer.AISinglePresence",:name => "sheets", :continuous => true, :states =>[:entered], :result => "c")
      a7 = EventAction.new(:event => :prev,:target => "c")
      m7 = ComplementaryMapping.new(:name=>"Prev Tilt",:observations => [o12,o13],:actions =>[a7])
    #  m7.start




}

