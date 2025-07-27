local contexts = Object:extend()

function contexts:init(contexts_table)
local hooks = contexts_table.hooks
self.hooks = hooks
self.name = contexts_table.name
self.key = contexts_table.key
self.set="contexts"
for i = 1,#hooks do
    local hook_target = hooks[i].target
    local hook_target_func = hooks[i].hook_target_func
    local hook = hooks[i].hook
    local pre = hooks[i].pre or false
    SMODS.Extender:Extend(hook_target, hook_target_func, hook, pre)
    print("applied context hook!")
end

return self
end
local l_highlight = Card.highlight
function Card:highlight(...)
local r = l_highlight(self,...)
--Used to add highlighted context.
if G.deck then
SMODS.calculate_context{
    card = self,
    card_highlighted = true,
}
end
return r
end
--Used to add clicked context.
local l_click = Card.click
function Card:click(...)
local c = l_click(self,...)

if G.deck then
SMODS.calculate_context{
    card = self,
    card_clicked = true,
    area = self.area,
}
end
return c
end
--Used to add released context.
local l_release = Card.release
function Card:release(...)
local r = l_release(self,...)
if G.deck then
SMODS.calculate_context{
    card = self,
    card_dragged = true,
    area = self.area,
}
end
return r
end
local l_hover = Card.hover
--Used to add hover context
function Card:hover(...)
local r = l_hover(self,...)
if G.deck then
SMODS.calculate_context{
    card = self,
    card_hovered = true,
    area = self.area,
}
end
return r
end
local l_update = Card.update
--Used to add timers
function Card:update(...)
local dt = {...}
dt = dt[1]
local r = l_update(self, ...)
if self.config.center and self.config.center.extra and not G.SETTINGS.paused then
local extra = self.config.center.config.extra
if extra == nil then extra = self.config.center.config end
if type(extra) == "number" then extra = nil end
extra = extra or {}
local card_timers = extra.bl_util_card_timers
if card_timers and G.deck then
for i,v in pairs(card_timers) do
    local reset_on=v.reset_on
    local id = v.id or i
    if type(reset_on) == "function" then reset_on = v:reset_on(self) end
    if v.initted ~= true then
        v.initted = true
        v.current = 0
    end
    local this_dt_return = {}
    local this_dt = dt
    SMODS.calculate_context({card = self, card_timer_tick = true,dt=dt,timer_id=id,},this_dt_return)
    for i,v in ipairs(this_dt_return) do
        if this_dt_return.dt then
            this_dt=dt+this_dt_return.dt
        end
        if this_dt_return.x_dt then
            this_dt=dt*this_dt_return.x_dt
        end
        if this_dt_return.e_dt then
            this_dt=dt^this_dt_return.e_dt
        end
    end
    v.current=v.current+this_dt
    if v.current >=v.reset_on then
        SMODS.calculate_context({
            card = self,
            card_timer_reset = true,
            dt = dt,
            card_total_time = v.current,
            timer_id = id,
        })
        local eval = {}
        if v.on_reset then eval=v:on_reset(self) end
        if eval.current then
            v.current = eval.current
        else
            v.current = 0
        end
        if eval.destroy_timer then
            table.remove(card_timers, i)
            card_timers[i] = nil
            v = nil
        end
    end
end
end
end
return r
end

SMODS.contexts = contexts