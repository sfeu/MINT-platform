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

  redis = Redis.connect
  redis.flushdb

  DataMapper.setup(:default, { :adapter => "redis", :host =>"0.0.0.0",:port=>6379})

  include MINT
  DataMapper.finalize
  Fiber.new {

  #p= Pointer.create(:name=>"pointer")
  #p.process_event :connect
  m = Mouse.create(:name=>"mouse")
  m.process_event :connect

    Button.create(:name=>"reset",:height =>60, :width => 200, :x=>380, :y => 170, :states=>[:positioned], :highlightable =>true)
    a = AICommand.create(:name=>"reset", :label =>"Reset", :states=>[:organized])
    a.process_event :present

    ProgressBar.create(:name=>"volume",:height =>80, :width => 300, :x=>40, :y => 120, :states=>[:positioned], :highlightable =>true)
    a = AIOUTContinuous.create(:name=>"volume", :label =>"Volume", :data =>0, :states=>[:organized])
    a.process_event :present

    #a= AIReference.create(:name=>"volume-ref",:refers=>"volume",:states =>[:organized])
    #a.process_event :present


    Slider.create(:name=>"slider",:height =>60, :width => 300, :x=>40, :y => 20, :states=>[:positioned], :highlightable =>true)
    a = AIINContinuous.create(:name=>"slider", :label =>"Slider", :data =>0, :states=>[:organized])
    a.process_event :present
    #a.process_event :focus


  }.resume nil
}
# Tasks

#InteractionTask.create(:name =>"9", :states=>[:running])
# InteractionTask.create(:name =>"9", :states=>[:running])

#PTS.create(:name =>"ets_state",:states=>[:finished])
