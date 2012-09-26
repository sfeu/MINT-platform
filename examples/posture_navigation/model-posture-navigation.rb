
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
  @solver = Cassowary::ClSimplexSolver.new
  include MINT
  DataMapper.finalize
  Fiber.new {

    # IRM Model Interactors
    ########################
    #mouse = Mouse.create(:name=>"mouse")

    pose = OneHandPoseNavigation.create(:name => "pose")

    # for browser refresh handling
    BrowserScreen.create(:name =>"screen")

    # AIM Model Interactors
    ########################

    header = AIContainer.create(:name =>"html_header",:states=>[:organized])


    root = AISingleChoice.create(:name=>"9",:children =>"A|B|C|D|E|F|G|H|I|J|K|L|M|N|O|P|Q|R|S|T|U|V|W|X|Y")

    first = AISingleChoiceElement.create(:name => "A", :text =>"A - Abelinha", :parent => "9")
    AISingleChoiceElement.create(:name => "B",:text =>"B - Bolo", :parent => "9")
    AISingleChoiceElement.create(:name => "C",:text =>"C -Caracol", :parent => "9")
    AISingleChoiceElement.create(:name => "D",:text =>"D- Dado", :parent => "9")
    AISingleChoiceElement.create(:name => "E", :text =>"E - Elefante", :parent => "9")
    AISingleChoiceElement.create(:name => "F",:text =>"F - Faca", :parent => "9")
    AISingleChoiceElement.create(:name => "G",:text =>"G - Gato", :parent => "9")
    AISingleChoiceElement.create(:name => "H",:text =>"H - Homen", :parent => "9")
    AISingleChoiceElement.create(:name => "I",:text =>"I - Indio", :parent => "9")
    AISingleChoiceElement.create(:name => "J",:text =>"J - Jarra", :parent => "9")
    AISingleChoiceElement.create(:name => "K",:text =>"K - Kiwi", :parent => "9")
    AISingleChoiceElement.create(:name => "L", :text =>"L - Lapis", :parent => "9")
    AISingleChoiceElement.create(:name => "M",:text =>"M - Mala", :parent => "9")
    AISingleChoiceElement.create(:name => "N",:text =>"N - Navio", :parent => "9")
    AISingleChoiceElement.create(:name => "O",:text =>"O - Olho", :parent => "9")
    AISingleChoiceElement.create(:name => "P",:text =>"P - Pato", :parent => "9")
    AISingleChoiceElement.create(:name => "Q",:text =>"Q - Queijo", :parent => "9")
    AISingleChoiceElement.create(:name => "R",:text =>"R - Rato", :parent => "9")
    AISingleChoiceElement.create(:name => "S",:text =>"S - Sapo", :parent => "9")
    AISingleChoiceElement.create(:name => "T",:text =>"T - Tambor", :parent => "9")
    AISingleChoiceElement.create(:name => "U",:text =>"U - Urso", :parent => "9")
    AISingleChoiceElement.create(:name => "V",:text =>"V - Vaca", :parent => "9")
    AISingleChoiceElement.create(:name => "W",:text =>"W - Windsurf", :parent => "9")
    AISingleChoiceElement.create(:name => "X",:text =>"X - Xicara", :parent => "9")
    AISingleChoiceElement.create(:name => "Y",:text =>"Y - Yolanda", :parent => "9")

    AUIControl.organize(root)
    root.save

# CIM HTML GfX Model Interactors
###################################


    HTMLHead.create(:name =>"html_header",:css=>"",:js=>"",:states=>[:positioned])

    root_cio = CIC.create( :name => "9", :x=>15, :y=>15, :width =>1280, :height => 1000,:layer=>0, :rows => 5, :cols=> 5, :highlightable =>false)

    MarkableRadioButton.create(:name => "A", :highlightable => true)
    MarkableRadioButton.create(:name => "B", :highlightable => true)
    MarkableRadioButton.create(:name => "C", :highlightable => true)
    MarkableRadioButton.create(:name => "D", :highlightable => true)
    MarkableRadioButton.create(:name => "E", :highlightable => true)
    MarkableRadioButton.create(:name => "F", :highlightable => true)
    MarkableRadioButton.create(:name => "G", :highlightable => true)
    MarkableRadioButton.create(:name => "H", :highlightable => true)
    MarkableRadioButton.create(:name => "I", :highlightable => true)
    MarkableRadioButton.create(:name => "J", :highlightable => true)
    MarkableRadioButton.create(:name => "K", :highlightable => true)
    MarkableRadioButton.create(:name => "L", :highlightable => true)
    MarkableRadioButton.create(:name => "M", :highlightable => true)
    MarkableRadioButton.create(:name => "N", :highlightable => true)
    MarkableRadioButton.create(:name => "O", :highlightable => true)
    MarkableRadioButton.create(:name => "P", :highlightable => true)
    MarkableRadioButton.create(:name => "Q", :highlightable => true)
    MarkableRadioButton.create(:name => "R", :highlightable => true)
    MarkableRadioButton.create(:name => "S", :highlightable => true)
    MarkableRadioButton.create(:name => "T", :highlightable => true)
    MarkableRadioButton.create(:name => "U", :highlightable => true)
    MarkableRadioButton.create(:name => "V", :highlightable => true)
    MarkableRadioButton.create(:name => "W", :highlightable => true)
    MarkableRadioButton.create(:name => "X", :highlightable => true)
    MarkableRadioButton.create(:name => "Y", :highlightable => true)

    root_cio.calculate_container(@solver,20)

    # Connect IRMs and present app
    ###################################

    #mouse.process_event :connect

    header.process_event :present
    root.process_event :present

    AISingleChoiceElement.first(:name => "A").process_event :focus
  }.resume nil

}
