local last_delete_run = Game.delete_run
local last_start_run = Game.start_run
local vanilla_backs = {}
function Game:delete_run(...)
local r = last_delete_run(self,...)
G.GAME.owned_backs = nil
return r
end
function Game:start_run(args)
local r = last_start_run(self, args)
G.GAME.owned_backs = {}
return r
end
function SMODS.Back:force_apply(back_id)
local back_center = G.P_CENTERS[back_id]
if back_center then
    if back_center.apply then
        local back_config = {
            center=back_center,
            text_UI = '',
            config = copy_table(back_center.config)
        }
        back_center:apply(back_config)
    else
        local back_config = {
            center=back_center,
            text_UI = '',
            config = copy_table(back_center.config),
        }
        vanilla_backs[back_id]:apply(back_config)
    end
end

end

local last_back_trigger_effect = Back.trigger_effect
function Back:trigger_effect(...)
    local r = last_back_trigger_effect(self,...)
    local to_merge = {}
    for i,v in ipairs(G.GAME.owned_backs) do
        local back_center = G.P_CENTERS[v.id]
        local config = v.config
        if back_center.calculate then
            local o = {back_center:calculate(self,...)}
            table.insert(to_merge, o)
        else
            local o = vanilla_backs[v.id]:calculate({self,...})
            table.insert(to_merge, o)
        end
    end
    for i,v in ipairs(to_merge) do
        r=table.merge(r, v, "+")
    end
    return r
end