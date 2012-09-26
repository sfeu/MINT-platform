
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

  DataMapper.setup(:default, { :adapter => "redis", :host =>"0.0.0.0",:port=>6379})
  include MINT
  DataMapper.finalize
  Fiber.new {

    AISingleChoiceElement.first(:name => "A").process_event :focus

    #pose = OneHandPoseNavigation.first(:name => "pose")
    #pose.process_event :connect
    #pose.process_event :one_hand
    #pose.process_event :next_pose
  }.resume nil

}
