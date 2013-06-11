$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

module MINTCore
  VERSION = '2.0.0'
end

require 'rubygems'
require "bundler/setup"
require 'statemachine'
require "cassowary"
#require 'RMagick'
require 'drb/drb'
require 'redis'
require 'dm-core'
require 'dm-serializer'
require 'dm-types'
require "MINT-scxml"
require "eventmachine"
require 'em-hiredis'
require 'multi_json'
require 'oj'
#MultiJson.engine = :oj

require "connector/redis_connector"
require "agent/agent"

require "model/interactor_helpers"
require "model/interactor"
require "model/task"
require "agent/auicontrol"
require "agent/aui"
require "agent/cuicontrol"
require "agent/cui-gfx"
require "model/aui/model"
require "model/cui/gfx/model"

require "model/ir/ir"
require "model/ir/irmode"
require "model/ir/irmedia"
require "model/ir/screen"
require "model/ir/browserscreen"
require "model/ir/pointer"

#require "model/device/button"
#require "model/device/wheel"
#require "model/device/joypad"
#require "model/device/mouse"
require "model/ir/mouse"

#require "model/body/gesture_button"
#require "model/body/handgesture"
require "model/ir/body/body"
require "model/ir/body/hand"
require "model/ir/body/fingertip"

require "model/ir/body/pose"
require "model/ir/body/OneHandPoseNavigation"
require "model/ir/body/head"
require "model/ir/body/StandardModeProtocol"
require "model/ir/body/libras_recognizer"


require "mapping/mapping"
require "mapping/sequential"
require "mapping/complementary_mapping"
require "mapping/sequential_mapping"
require "mapping/observation/observation"
require "mapping/observation/negation_observation"
require "mapping/action/action"
require "mapping/action/backend_action"
require "mapping/action/event_action"
require "mapping/action/bind_action"

require "manager/mapping_parser"
require "manager/mapping_manager"
require "manager/mapping_server"
require "manager/scxml_server"
require "manager/scxml_client"
require "manager/position_updater"


