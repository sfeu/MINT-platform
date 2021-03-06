
# -*- coding: utf-8 -*-
require 'rubygems'
require "bundler/setup"
require 'dm-core'
require 'redis'
require "eventmachine"
require 'hiredis'
require 'fiber'
require "./music_sheet_backend"

EM.run {
  require "MINT-core"

  redis = Redis.connect
  redis.flushdb

  DataMapper.setup(:default, { :adapter => "redis", :host =>"0.0.0.0",:port=>6379})

  include MINT
  include CUIControl
  include AUIControl
  include MusicSheet

  DataMapper.finalize

  h = Head.create(:name => 'head')
  h.start #("0.0.0.0", 3004)
  MusicSheet.head=h

  SCXMLClient.new("Interactor.IR.IRMode.Body.Head*","head").start #("10.10.0.2")

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
      AISingleChoiceElement.create(:name=>"nodding",:text=>"Nodding",:parent => "option")
      AISingleChoiceElement.create(:name=>"tilting",:text=>"Tilting",:parent => "option")
      AISingleChoiceElement.create(:name=>"turning",:text=>"Turning",:parent => "option")

      AUIControl.organize(nav_start)
      root.save

      # CIM HTML GfX Model Interactors
      ###################################

      HEIGHT=680
      WIDTH=1280

      HTMLHead.create(:name =>"html_header",:css=>"/musicsheet/musicsheet.css",:js=>"/musicsheet/jquery.carouFredSel-5.6.2.js",:states=>[:positioned])
      MinimalOutputSlider.create(:name=>"horizontal_level",:height =>8, :width => WIDTH-40, :x=>20, :y => 5, :states=>[:positioned], :highlightable =>false)
      MinimalVerticalOutputSlider.create(:name=>"vertical_level",:height =>HEIGHT-20, :width => 8, :x=>10, :y => 20, :states=>[:positioned], :highlightable =>false)

      CIC.create(:name =>"interactive_sheet",:x=>15, :y=>15, :width =>WIDTH-60, :height => HEIGHT-30,:layer=>0, :rows=>2, :cols=>1,:states=>[:positioned])
      CarouFredSel.create( :name => "sheets", :depends => "html_header", :x=>20, :y=>25,:width=>WIDTH-80,:layer=>1, :items => (HEIGHT-100/100).to_i ,:height => HEIGHT-120,:states=>[:positioned], :highlightable => true)
      CarouFredSelImage.create(:name=>"page1",:path=>"/musicsheet/sheets/page1.png",:x=>15, :y=>15, :width =>WIDTH-200, :height => HEIGHT-100,:states=>[:positioned])
      CarouFredSelImage.create(:name=>"page2",:path=>"/musicsheet/sheets/page2.png",:x=>15, :y=>15, :width =>WIDTH-200, :height => HEIGHT-100,:states=>[:positioned])
      CarouFredSelImage.create(:name=>"page3",:path=>"/musicsheet/sheets/page3.png",:x=>15, :y=>15, :width =>WIDTH-200, :height => HEIGHT-100,:states=>[:positioned])
      CarouFredSelImage.create(:name=>"page4",:path=>"/musicsheet/sheets/page4.png",:x=>15, :y=>15, :width =>WIDTH-200, :height => HEIGHT-100,:states=>[:positioned])
      CarouFredSelImage.create(:name=>"page5",:path=>"/musicsheet/sheets/page5.png",:x=>15, :y=>15, :width =>WIDTH-200, :height => HEIGHT-100,:states=>[:positioned])
      CarouFredSelImage.create(:name=>"page6",:path=>"/musicsheet/sheets/page6.png",:x=>15, :y=>15, :width =>WIDTH-200, :height => HEIGHT-100,:states=>[:positioned])
      CarouFredSelImage.create(:name=>"page7",:path=>"/musicsheet/sheets/page7.png",:x=>15, :y=>15, :width =>WIDTH-200, :height => HEIGHT-100,:states=>[:positioned])
      CarouFredSelImage.create(:name=>"page8",:path=>"/musicsheet/sheets/page8.png",:x=>15, :y=>15, :width =>WIDTH-200, :height => HEIGHT-100,:states=>[:positioned])

      r = RadioButtonGroup.create(:name =>"option", :x=>30,:y=>HEIGHT-90, :width=>WIDTH-250, :height => 80,:layer=>0,:rows=>1,:cols=>3)
      RadioButton.create(:name => "nodding",:layer=>1,:depends => "option", :highlightable => true)   #:x=>20, :y=>HEIGHT-90, :width=>(WIDTH-100)/3, :height => 36,
      RadioButton.create(:name => "tilting",:layer=>1,:depends => "option", :highlightable => true)                              #:x=>WIDTH/3, :y=>HEIGHT-90,:width=>(WIDTH-100)/3, :height => 36,
      RadioButton.create(:name => "turning",:layer=>1,:depends => "option", :highlightable => true) #:x=>WIDTH/3*2, :y=>HEIGHT-90,:width=>(WIDTH-100)/3, :height => 36,

      solver = Cassowary::ClSimplexSolver.new
      r.calculate_container(solver,20)

      CUIControl.fill_active_cio_cache

      # Connect IRMs and present app
      ###################################

      mouse.process_event :connect


      root.process_event :present
      nav_start.process_event :present

    }.resume nil
  end
  m.load("./mim/mim_musicsheet_example.xml")

}

