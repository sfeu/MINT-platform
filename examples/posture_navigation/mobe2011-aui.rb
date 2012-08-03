require "rubygems"
require "MINT-core"
require "lib/models/one_hand_nav_final"
require "lib/models/one_hand_nav_flexible_ticker"
require "lib/models/one_hand_nav_just_ticker"

include MINT

a = AUIAgent.new


mapping_external_pts_update = ExecuteOnStateChange.new(PTS,"finished",a.method(:initial_calculation),a.method(:initial_calculation))
a.addMapping(mapping_external_pts_update)

gesture_next= ComplementarySendEvent.new(HandGesture,"next",{ AIO  =>"focused"},:next)
a.addMapping(gesture_next)

gesture_previous= ComplementarySendEvent.new(HandGesture,"previous",{ AIO  =>"focused"},:prev)
a.addMapping(gesture_previous)

gesture_confirmed= ComplementarySendEvent.new(HandGesture,"confirmed",{ AIINChoose  =>"focused"},:choose)
a.addMapping(gesture_confirmed)

mouse_confirmed= ComplementarySendEvent.new(Pointer,"selected",{ AIINChoose  =>"focused"},:choose)
a.addMapping(mouse_confirmed)

a.run
