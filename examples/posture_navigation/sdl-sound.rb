#!/usr/bin/env ruby

# $LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')
require 'rubygems'
require 'MINT-core'
require 'MINT-sdl'
require "lib/models/one_hand_nav_final"
require "lib/models/one_hand_nav_flexible_ticker"
require "lib/models/one_hand_nav_just_ticker"

include MINT

s = SoundAgent.new

mapping_external_focus_click = ExecuteOnStateChange.new(AIO,"focused",s.method(:play_click))
s.addMapping(mapping_external_focus_click)
mapping_external_select = ExecuteOnStateChange.new(OneHand,"selected",s.method(:play_click2))
s.addMapping(mapping_external_select)
mapping_external_confirm = ExecuteOnStateChange.new(OneHand,"confirmed",s.method(:play_plop))
s.addMapping(mapping_external_confirm)


s.run
