local gpu = require("component").gpu
local term = require("term")
local event = require("event")
local utils = require("GUI.utils")

local App = {}
App.__index = App

function App.new()
    local self = setmetatable({}, App)
    self.pages = {}
    self.activePage = nil
    self.running = false
    return self
end

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
    local page = self.pages[name]
    assert(page, "GUI.App:switch(): page '" .. tostring(name) .. "' does not exist")
    self.activePage = page
end

---@param widget table
---@param pageName string
---@param z? number
function App:add(widget, pageName, z)
    local page = self.pages[pageName] or self.activePage
    if page then
        widget.appref = self
        widget.page = page

        if z and z <= #page.widgets then
            table.insert(page.widgets, z, widget)
        else
            table.insert(page.widgets, widget)
        end
    end
end

function App:draw()
    term.clear()
    local list = self.activePage.widgets
    for i = 1, #list do
        local w = list[i]
        if w.draw then w:draw() end
        gpu.setBackground(utils.config().BACKGROUND_COLOR)
        gpu.setForeground(utils.config().FOREGROUND_COLOR)
    end
end

function App:run()
    assert(self.activePage, "GUI.App: no active page set")
    self.running = true
    self:draw()
    while self.running do
        local page = self.activePage
        assert(page and page.widgets, "Active page invalid")
        local e = { event.pull() }
        if e[1] == "interrupted" then self.running = false end
        for i = #self.activePage.widgets, 1, -1 do
            local w = self.activePage.widgets[i]
            local widg_hand = w.handle and w:handle(e)
            if widg_hand.draw then
                self:draw()
                if widg_hand.consume then
                    break
                end
            end
        end
    end

    term.clear()
end

---@param widget widget
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

local Button = require("GUI.widgets.Button")
local Input = require("GUI.widgets.Input")

return {
    App = App,
    Widgets = { Button = Button, Input = Input }
}
