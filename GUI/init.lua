local gpu = require("component").gpu
local term = require("term")
local event = require("event")




local event = require("event")
local term  = require("term")

local App   = {
    pages = {},
    activePage = nil
}

function App:newPage(name)
    local page = {
        name = name,
        widgets = {}
    }

    self.pages[name] = page

    if not self.activePage then
        self.activePage = page
    end

    return page
end

function App:switch(name)
    self.activePage = self.pages[name]
    self:draw()
end

function App:add(widget, pageName, z)
    local page = self.pages[pageName] or self.activePage
    if page then
        widget.gui = self
        widget.page = page
        table.insert(page.widgets, z, widget)
    end
end

function App:draw()
    term.clear()
    local list = self.activePage.widgets
    for i = 1, #list do
        local w = list[i]
        if w.draw then w:draw() end
    end
end

function App:run()
    self:draw()
    while true do
        local e = { event.pull() }
        for i = #self.widgets, 1, -1 do
            local w = self.widgets[i]
            if w.handle and w:handle(e) then
                self:draw()
                break
            end
        end
    end
end

function App:raise(widget)
    local list = widget.page.widgets
    for i, w in ipairs(list) do
        if w == widget then
            table.remove(list, i)
            table.insert(list, widget)
            return
        end
    end
end

return {
    App = App,
    Widgets = { Button = require("widgets.Button"), Input = require("widgets.Input") }
}
