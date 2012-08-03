require 'rubygems'
require "bundler/setup"
require "MINT-core"

include MINT

class MouseMapperAgent < Agent
end

mouseAgent = MouseMapperAgent.new


click_select_mapping = Sequential.new(HWButton,"pressed",HWButton,"released",nil,0, 300, {{ Selectable  =>"highlighted"} =>:select})
mouseAgent.addMapping(click_select_mapping)

mouseAgent.run
