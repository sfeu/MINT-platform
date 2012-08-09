
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
  #redis.flushdb

  DataMapper.setup(:default, { :adapter => "redis", :host =>"0.0.0.0",:port=>6379})

  include MINT
  DataMapper.finalize
  Fiber.new {
    m = Mouse.create(:name=>"mouse")
    m.process_event :connect


    header= AIOUT.create(:name =>"html_header",:states=>[:organized],:parent=>"mint-header")
    HTMLHead.create(:name =>"html_header",:css=>"/musicsheet/musicsheet.css",:js=>"/musicsheet/jquery.carouFredSel-5.6.2.js",:states=>[:positioned])
    header.process_event :present

    MinimalOutputSlider.create(:name=>"horizontal_level",:height =>8, :width => 1280, :x=>20, :y => 5, :states=>[:positioned], :highlightable =>false)
    a = AIOUTContinuous.create(:name=>"horizontal_level", :label =>"Horizontal Level", :data =>0, :states=>[:organized])
    a.process_event :present

    MinimalVerticalOutputSlider.create(:name=>"vertical_level",:height =>1000, :width => 8, :x=>10, :y => 20, :states=>[:positioned], :highlightable =>false)
    a = AIOUTContinuous.create(:name=>"vertical_level", :label =>"Vertical Level", :data =>0, :states=>[:organized])
    a.process_event :present

    root = AIContainer.create(:name=>"interactive_sheet", :children => "sheets|option")
    sheets = AISinglePresence.create(:name=>"sheets",:parent => "interactive_sheet",:children =>"page1|page2|page3|page4|page5|page6|page7|page8")
    AIOUT.create(:name =>"page1",:parent => "sheets")
    AIOUT.create(:name =>"page2",:parent => "sheets")
    AIOUT.create(:name =>"page3",:parent => "sheets")
    AIOUT.create(:name =>"page4",:parent => "sheets")
    AIOUT.create(:name =>"page5",:parent => "sheets")
    AIOUT.create(:name =>"page6",:parent => "sheets")
    AIOUT.create(:name =>"page7",:parent => "sheets")
    AIOUT.create(:name =>"page8",:parent => "sheets")


    AISingleChoice.create(:name=>"option", :label=>"Options", :children => "nodding|tilting|turning",:parent => "interactive_sheet")
    AISingleChoiceElement.create(:name=>"nodding",:label=>"Nodding",:parent => "option")
    AISingleChoiceElement.create(:name=>"tilting",:label=>"Tilting",:parent => "option")
    AISingleChoiceElement.create(:name=>"turning",:label=>"Turning",:parent => "option")

    AUIControl.organize(root)
    root.save

    CIC.create(:name =>"interactive_sheet",:x=>15, :y=>15, :width =>1280, :height => 1000,:layer=>0, :rows=>2, :cols=>1,:states=>[:positioned], :width=>1180, :height => 820)
    CarouFredSel.create( :name => "sheets", :depends => "html_header", :x=>0, :y=>0,:width=>1198, :height => 840,:states=>[:positioned], :highlightable => true)
    CarouFredSelImage.create(:name=>"page1",:path=>"/musicsheet/sheets/page1.png",:x=>15, :y=>15, :width =>1180, :height => 820,:states=>[:positioned])
    CarouFredSelImage.create(:name=>"page2",:path=>"/musicsheet/sheets/page2.png",:x=>15, :y=>15, :width =>1180, :height => 820,:states=>[:positioned])
    CarouFredSelImage.create(:name=>"page3",:path=>"/musicsheet/sheets/page3.png",:x=>15, :y=>15, :width =>1180, :height => 820,:states=>[:positioned])
    CarouFredSelImage.create(:name=>"page4",:path=>"/musicsheet/sheets/page4.png",:x=>15, :y=>15, :width =>1180, :height => 820,:states=>[:positioned])
    CarouFredSelImage.create(:name=>"page5",:path=>"/musicsheet/sheets/page5.png",:x=>15, :y=>15, :width =>1180, :height => 820,:states=>[:positioned])
    CarouFredSelImage.create(:name=>"page6",:path=>"/musicsheet/sheets/page6.png",:x=>15, :y=>15, :width =>1180, :height => 820,:states=>[:positioned])
    CarouFredSelImage.create(:name=>"page7",:path=>"/musicsheet/sheets/page7.png",:x=>15, :y=>15, :width =>1180, :height => 820,:states=>[:positioned])
    CarouFredSelImage.create(:name=>"page8",:path=>"/musicsheet/sheets/page8.png",:x=>15, :y=>15, :width =>1180, :height => 820,:states=>[:positioned])

    RadioButtonGroup.create(:name =>"option", :x=>30,:y=>840, :width=>1200, :height => 100,:rows=>1,:cols=>3,:states=>[:positioned])
    RadioButton.create(:name => "nodding",:x=>40, :y=>850, :width=>200, :height => 80,:states=>[:positioned],:depends => "option", :highlightable => true)
    RadioButton.create(:name => "tilting",:x=>440, :y=>850,:width=>200, :height => 80,:states=>[:positioned],:depends => "option", :highlightable => true)
    RadioButton.create(:name => "turning",:x=>840, :y=>850,:width=>200, :height => 80,:states=>[:positioned],:depends => "option", :highlightable => true)

    sheets = AISinglePresence.first(:name=>"sheets")
    sheets.process_event :present

    options = AISingleChoice.first(:name=>"option")
    options.process_event :present


  }.resume nil
}
# Tasks

#InteractionTask.create(:name =>"9", :states=>[:running])
# InteractionTask.create(:name =>"9", :states=>[:running])

#PTS.create(:name =>"ets_state",:states=>[:finished])
