local function apply_starting_effects()
if not G.GAME.effects then G.GAME.effects = {} end
local current_deck= G.GAME.selected_back
print('applying starting effects')
    local starting_effects = current_deck.effect.config.starting_effects or {}
    for i,v in pairs(starting_effects) do
        local math_operation = v.operation
        local value = v.value
        print(math_operation)
        if math_operation == "R" then
            G.GAME.effects[i] = value
            print("replaced with:",value)
        elseif math_operation == "+" then
            G.GAME.effects[i]=G.GAME.effects[i]+value
        elseif math_operation == "-" then
            G.GAME.effects[i]=G.GAME.effects[i]-value
        elseif math_operation == "*" then
            G.GAME.effects[i]=G.GAME.effects[i]*value
        elseif math.operation == "/" then
            G.GAME.effects[i]=G.GAME.effects[i]/value
        elseif math.operation == "^" then
            G.GAME.effects[i]=G.GAME.effects[i]^value
        elseif math.operation == "rad" then
            G.GAME.effects[i]=math.rad(value)
        end
    end
end
local CustomEffects = Object:extend()
local registered_effects = {}
function CustomEffects:init(effect_table)
self.key=effect_table.key
self.value=effect_table.value
self.set="CustomEffect"
if effect_table.calculate ~= nil and type(effect_table.calculate) == "function" then self.calculate=effect_table.calculate end
registered_effects[effect_table.key] = self
return self
end

local function calculate_registered_effects(calculator,card,context)
if calculator == nil or context == nil then return false end
if not G.GAME.effects then apply_starting_effects() end
for i,v in pairs(registered_effects) do
if v.calculate ~= nil and type(v.calculate) == "function" then
--print("calculating effect:",i)
v:calculate(calculator,card,context)    
end
end

end

SMODS.CustomEffects = CustomEffects
SMODS.Extender:Extend(Game, "start_run", function(self, args)
print("game initted!")
G.GAME.effects = {}
for i,v in pairs(registered_effects) do
    print("registering effect:",i)
    print(v.key)
    G.GAME.effects[i] = v.value
end
apply_starting_effects()

end, false)
SMODS.Extender:Extend(Game, "delete_run", function(self)
if G.GAME.effects then
    for i,v in pairs(G.GAME.effects) do
    G.GAME.effects[i] = nil
end
G.GAME.effects = {}
end
end, false)
SMODS.Extender:Extend(SMODS.Back, "calculate", function(self, card, context)
calculate_registered_effects(self,card,context)
end, false)
SMODS.Extender:Extend(Back, "trigger_effect", function(self, args)
calculate_registered_effects(self,args.card,args.context)
end, false)
SMODS.Extender:Extend(Back, "calculate", function(self, card, context)
calculate_registered_effects(self,card,context)    
end, false)
SMODS.Extender:Extend(SMODS.Back, "trigger_effect", function(self, args)
    calculate_registered_effects(self,args.card,args.context)
end, false)
--[[SMODS.Extender:Extend(Card, "calculate_joker", function(self, context)
    calculate_registered_effects(self,self,context)
end, false)]]