
local MainScene = class("MainScene", cc.load("mvc").ViewBase)

function MainScene:onCreate()
    -- add background image
    display.newSprite("HelloWorld.png")
        :move(display.center)
        :addTo(self)

    -- add HelloWorld label
    local cpv = _G.Native:getCPPVer()
    cc.Label:createWithSystemFont("Hello World " .. cpv, "Arial", 40)
        :move(display.cx, display.cy + 200)
        :addTo(self)

    local dt = cc.DelayTime:create(3)
    local cb = cc.CallFunc:create(function()
        _G.Native:pickPhoto()
        print("haha nailed")
    end)
    local seq = cc.Sequence:create({dt,cb})
    self:runAction(seq)
end

return MainScene
