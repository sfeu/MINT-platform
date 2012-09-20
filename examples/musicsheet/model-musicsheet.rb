
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

    # IRM Model Interactors
    ########################
    mouse = Mouse.create(:name=>"mouse")

    # for browser refresh handling
    BrowserScreen.create(:name =>"screen")

    # AIM Model Interactors
    ########################

    root = AIContainer.create(:name =>"html_header",:states=>[:organized])


    nav_start= AIContainer.create(:name=>"interactive_sheet", :children => "horizontal_level|vertical_level|sheets|option")
    AIOUTContinuous.create(:name=>"horizontal_level",  :data =>0,:parent=>"interactive_sheet")

    AIOUTContinuous.create(:name=>"vertical_level", :data =>0,:parent=>"interactive_sheet")

    AISinglePresence.create(:name=>"sheets",:parent => "interactive_sheet",:children =>"page1|page2|page3|page4|page5|page6|page7|page8")
    AIOUT.create(:name =>"page1",:parent => "sheets")
    AIOUT.create(:name =>"page2",:parent => "sheets")
    AIOUT.create(:name =>"page3",:parent => "sheets")
    AIOUT.create(:name =>"page4",:parent => "sheets")
    AIOUT.create(:name =>"page5",:parent => "sheets")
    AIOUT.create(:name =>"page6",:parent => "sheets")
    AIOUT.create(:name =>"page7",:parent => "sheets")
    AIOUT.create(:name =>"page8",:parent => "sheets")


    AISingleChoice.create(:name=>"option", :children => "nodding|tilting|turning",:parent => "interactive_sheet")
    AISingleChoiceElement.create(:name=>"nodding",:label=>"Nodding",:parent => "option")
    AISingleChoiceElement.create(:name=>"tilting",:label=>"Tilting",:parent => "option")
    AISingleChoiceElement.create(:name=>"turning",:label=>"Turning",:parent => "option")

    AUIControl.organize(nav_start)
    root.save

    # CIM HTML GfX Model Interactors
    ###################################

    HTMLHead.create(:name =>"html_header",:css=>"/musicsheet/musicsheet.css",:js=>"/musicsheet/jquery.carouFredSel-5.6.2.js",:states=>[:positioned])
    MinimalOutputSlider.create(:name=>"horizontal_level",:height =>8, :width => 1280, :x=>20, :y => 5, :states=>[:positioned], :highlightable =>false)
    MinimalVerticalOutputSlider.create(:name=>"vertical_level",:height =>1000, :width => 8, :x=>10, :y => 20, :states=>[:positioned], :highlightable =>false)

    CIC.create(:name =>"interactive_sheet",:x=>15, :y=>15, :width =>1280, :height => 1000,:layer=>0, :rows=>2, :cols=>1,:states=>[:positioned])
    CarouFredSel.create( :name => "sheets", :depends => "html_header", :x=>0, :y=>0,:width=>1198,:layer=>1,  :height => 840,:states=>[:positioned], :highlightable => true)
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

    # Connect IRMs and present app
    ###################################

    mouse.process_event :connect


    root.process_event :present
    nav_start.process_event :present

  }.resume nil
}
# Tasks

#InteractionTask.create(:name =>"9", :states=>[:running])
# InteractionTask.create(:name =>"9", :states=>[:running])

#PTS.create(:name =>"ets_state",:states=>[:finished])
