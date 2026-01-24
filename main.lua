local flow = require("Multiflow")



local manager = flow.Manager.loadRuntimesFromConfigs("./configs")


while true do
    -- TODO make ui for manager
    manager:tick()
end
