
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
    mouse = Mouse.create(:name=>"mouse")

    # for browser refresh handling
    BrowserScreen.create(:name =>"screen")

    # AIM Model Interactors
    ########################

    header = AIContainer.create(:name =>"html_header",:states=>[:organized])


    root = AISingleChoice.create(:name=>"9", :label =>"9 - Nove",:children =>"A|B|C|D|E|F|G|H|I|J|K|L|M|N|O|P|Q|R|S|T|U|V|W|X|Y")

    AISingleChoiceElement.create(:name => "A", :label =>"A - Abelinha", :parent => "9")
    AISingleChoiceElement.create(:name => "B",:label =>"B - Bolo", :parent => "9")
    AISingleChoiceElement.create(:name => "C",:label =>"C -Caracol", :parent => "9")
    AISingleChoiceElement.create(:name => "D",:label =>"D- Dado", :parent => "9")
    AISingleChoiceElement.create(:name => "E", :label =>"E - Elefante", :parent => "9")
    AISingleChoiceElement.create(:name => "F",:label =>"F - Faca", :parent => "9")
    AISingleChoiceElement.create(:name => "G",:label =>"G - Gato", :parent => "9")
    AISingleChoiceElement.create(:name => "H",:label =>"H - Homen", :parent => "9")
    AISingleChoiceElement.create(:name => "I",:label =>"I - Indio", :parent => "9")
    AISingleChoiceElement.create(:name => "J",:label =>"J - Jarra", :parent => "9")
    AISingleChoiceElement.create(:name => "K",:label =>"K - Kiwi", :parent => "9")
    AISingleChoiceElement.create(:name => "L", :label =>"L - Lapis", :parent => "9")
    AISingleChoiceElement.create(:name => "M",:label =>"M - Mala", :parent => "9")
    AISingleChoiceElement.create(:name => "N",:label =>"N - Navio", :parent => "9")
    AISingleChoiceElement.create(:name => "O",:label =>"O - Olho", :parent => "9")
    AISingleChoiceElement.create(:name => "P",:label =>"P - Pato", :parent => "9")
    AISingleChoiceElement.create(:name => "Q",:label =>"Q - Queijo", :parent => "9")
    AISingleChoiceElement.create(:name => "R",:label =>"R - Rato", :parent => "9")
    AISingleChoiceElement.create(:name => "S",:label =>"S - Sapo", :parent => "9")
    AISingleChoiceElement.create(:name => "T",:label =>"T - Tambor", :parent => "9")
    AISingleChoiceElement.create(:name => "U",:label =>"U - Urso", :parent => "9")
    AISingleChoiceElement.create(:name => "V",:label =>"V - Vaca", :parent => "9")
    AISingleChoiceElement.create(:name => "W",:label =>"W - Windsurf", :parent => "9")
    AISingleChoiceElement.create(:name => "X",:label =>"X - Xicara", :parent => "9")
    AISingleChoiceElement.create(:name => "Y",:label =>"Y - Yolanda", :parent => "9")

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

    mouse.process_event :connect

    header.process_event :present
    root.process_event :present

  }.resume nil

}
