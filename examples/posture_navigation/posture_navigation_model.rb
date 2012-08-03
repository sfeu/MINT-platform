require 'rubygems'
require "bundler/setup"
require 'dm-core'
require 'redis'
require "eventmachine"
require 'hiredis'

EM.run {
  require "MINT-core"

  redis = Redis.connect
  redis.flushdb

  DataMapper.setup(:default, { :adapter => "redis", :host =>"0.0.0.0",:port=>6379})

  include MINT
  DataMapper.finalize

  m = Mouse.create(:name=>"mouse")
  m.process_event :connect

  header= AIOUT.create(:name =>"html_header",:states=>[:organized],:parent=>"mint-header")
  HTMLHead.create(:name =>"html_header",:css=>"",:js=>"",:states=>[:positioned])
  header.process_event :present

  root = AISingleChoice.create(:name=>"9", :label =>"9 - Nove",:children =>"A|B|C|D|E|F|G|H|I|J|K|L|M|N|O|P|Q|R|S|T|U|V|W|X|Y")

  AISingleChoiceElement.create(:name => "A", :label =>"A - Abelinha", :parent => "9")
  AISingleChoiceElement.create(:name => "B",:label =>"B - Bolo", :parent => "9")
  AISingleChoiceElement.create(:name => "C",:label =>"C -Caracol", :parent => "9")
  AISingleChoiceElement.create(:name => "D",:label =>"D- Dado", :parent => "9")
  AISingleChoiceElement.create(:name => "E", :label =>"E - Elefante", :parent => "9")
  AISingleChoiceElement.create(:name => "F",:label =>"F - Faca", :parent => "9")
  AISingleChoiceElement.create(:name => "G",:label =>"G - Gato", :parent => "9")
  AISingleChoiceElement.create(:name => "H",:label =>"H - Homen", :parent => "9")
  AISingleChoiceElement.create(:name => "I",:label =>"I - Índio", :parent => "9")
  AISingleChoiceElement.create(:name => "J",:label =>"J - Jarra", :parent => "9")
  AISingleChoiceElement.create(:name => "K",:label =>"K - Kiwi", :parent => "9")
  AISingleChoiceElement.create(:name => "L", :label =>"L - Lápis", :parent => "9")
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

# CUI - Gfx

  CIC.create( :name => "9", :x=>15, :y=>15, :width =>1280, :height => 1000,:layer=>0, :rows => 5, :cols=> 5)

  MarkableRadioButton.create(:name => "A")
  MarkableRadioButton.create(:name => "B")
  MarkableRadioButton.create(:name => "C")
  MarkableRadioButton.create(:name => "D")
  MarkableRadioButton.create(:name => "E")
  MarkableRadioButton.create(:name => "F")
  MarkableRadioButton.create(:name => "G")
  MarkableRadioButton.create(:name => "H")
  MarkableRadioButton.create(:name => "I")
  MarkableRadioButton.create(:name => "J")
  MarkableRadioButton.create(:name => "K")
  MarkableRadioButton.create(:name => "L")
  MarkableRadioButton.create(:name => "M")
  MarkableRadioButton.create(:name => "N")
  MarkableRadioButton.create(:name => "O")
  MarkableRadioButton.create(:name => "P")
  MarkableRadioButton.create(:name => "Q")
  MarkableRadioButton.create(:name => "R")
  MarkableRadioButton.create(:name => "S")
  MarkableRadioButton.create(:name => "T")
  MarkableRadioButton.create(:name => "U")
  MarkableRadioButton.create(:name => "V")
  MarkableRadioButton.create(:name => "W")
  MarkableRadioButton.create(:name => "X")
  MarkableRadioButton.create(:name => "Y")


  root.process_event :present

}