local flowcontrol = require("Multiflow")
local sides = require("sides")

local cfg = flowcontrol.Config.new("Monazite")
cfg:addInput("dumm1", sides.north, 1, sides.south, 1, 1000)
