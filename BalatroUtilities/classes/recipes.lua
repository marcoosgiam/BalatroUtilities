local recipes = Object:extend()
local last_consumeable_use = Card.use_consumeable
local last_init = Card.init
G.FUNCS.craft = function(e)
    local card = e.config.ref_table
    card:craft()
end
G.FUNCS.can_craft = function(e)
    local card = e.config.ref_table
    if card:can_craft() then
        e.config.colour = G.C.CHIPS
        e.config.button = "craft"
    else
        e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
    end
end
function Card:craft()
local recipes = self.ability.recipes
if recipes ~= nil then
for i,v in ipairs(recipes) do
    print("recipe key:",v)
    local target_recipe = G.P_CENTER_POOLS["recipes"][v]
    print(target_recipe.key)
    target_recipe:use(self)
end

end

end
function Card:use_consumeable(area,copier)
last_consumeable_use(self,area,copier)
--[[local recipes = self.ability.recipes
if recipes ~= nil then
for i,v in ipairs(recipes) do
    print("recipe key:",v)
    local target_recipe = G.P_CENTER_POOLS["recipes"][v]
    print(target_recipe.key)
    target_recipe:use(self)
end

end]]

end

function Card:can_craft()
local recipes = self.ability.recipes
--print("checking if can craft?")
if recipes ~= nil then
for i,v in ipairs(recipes) do
    --print("recipe key:",v.key)
    local target_recipe = G.P_CENTER_POOLS["recipes"][v]
    if target_recipe:can_use(self) == true then
        return true
    end
end

end
return false
end

function Card:init(X,Y,W,H,card,center,params)
last_init(self,X,Y,W,H,card,center,params)
--[[if self.config.center.config.recipes ~= nil then
    print('ability recipes is not nil')
    if center.keep_on_use == nil and center.use == nil then
        --print('keep on use is nil')
        --print(self.ability.name)
        center.keep_on_use = function ()
            return true
        end
    elseif center.use ~= nil and center.keep_on_use == nil then
        center.keep_on_use = function ()
            return false
        end
    end
    if center.can_use == nil then
        center.can_use = function ()
            return true
        end
    end
    if center.use ~= nil and center.keep_on_use ~= nil then
        local this_keep_on_use = center.keep_on_use
        center.keep_on_use = function()
            return true
        end
        local this_use = center.use
        center.use = function(...)
            local args = {...}
            local recipe_used = false
            local card = args[2]
            local recipes = card.ability.recipes
            for i,v in ipairs(recipes) do
                local target_recipe = G.P_CENTER_POOLS["recipes"][v]
                local used_recipe = target_recipe:use(card)
                if used_recipe ~= false then
                    recipe_used=true
                end
            end
            if recipe_used == false then this_use(args) if this_keep_on_use(card) == false then card:start_dissolve() end end
        end
    end
end]]

end

local last_use_and_sell_buttons = G.UIDEF.use_and_sell_buttons
G.UIDEF.use_and_sell_buttons = function(card)
    local t = last_use_and_sell_buttons(card)
    local craft = nil
    craft = {n=G.UIT.C, config={align = "cr"}, nodes={
      {n=G.UIT.C, config={ref_table = card, align = "cr",maxw = 1.25, padding = 0.1, r=0.2, minw = 1.25, minh = (card.area and card.area.config.type == 'joker') and 0 or 1, hover = true, shadow = true, colour = G.C.CHIPS, one_press = false, button = 'craft',func="can_craft"}, nodes={
        {n=G.UIT.B, config = {w=0.05,h=0.3}},
        {n=G.UIT.T, config={text = localize("k_craft"),colour = G.C.UI.TEXT_LIGHT, scale = 0.55, shadow = true}}
      }}
    }}
    --[[if t.nodes[1].nodes[2].nodes[1] == nil then
        t.nodes[1].nodes[2].nodes[1] = {n=G.UIT.C, config={align = "cr"}, nodes={
      
      {n=G.UIT.C, config={ref_table = card, align = "cr",maxw = 1.25, padding = 0.1, r=0.2, minw = 1.25, minh = (card.area and card.area.config.type == 'joker') and 0 or 1, hover = true, shadow = true, colour = G.C.UI.BACKGROUND_INACTIVE, one_press = true, button = 'use_card'}, nodes={
        {n=G.UIT.B, config = {w=0.1,h=0.6}},
        {n=G.UIT.T, config={text = localize('b_use'),colour = G.C.UI.TEXT_LIGHT, scale = 0.55, shadow = true}}
      }}
    }}
    end]]
    --t.nodes[1].nodes[2].nodes[1] = craft
    if card.area ~= G.pack_cards then
    table.insert(t.nodes[1].nodes, craft)
    local config = card.config.center.config
    if config.recipes then
    end
    end
    return t
end

function recipes:init(recipe_table)
self.name = recipe_table.name
self.key = recipe_table.prefix.."_"..recipe_table.key
self.input = recipe_table.input
self.result = recipe_table.result
self.sound = recipe_table.sound
self.recipe_value = recipe_table.recipe_value
self.recipe_value_required = recipe_table.recipe_value_required
self.recipe_type = recipe_table.recipe_type or {}
self.order = recipe_table.order or 0
self.discovered = recipe_table.discovered or self:is_discovered()
self.unlocked = recipe_table.unlocked or self:can_unlock()
if recipe_table.calculate ~= nil then self.calculate = recipe_table.calculate end
if G.P_CENTER_POOLS["recipes"] == nil then G.P_CENTER_POOLS["recipes"] = {} end
G.P_CENTER_POOLS["recipes"][self.key] = self
end

function recipes:can_unlock()
return true
end

function recipes:is_discovered()
    return true
end

function recipes:can_use(cons)
local recipe_value = 0
local items = {}
local cards = {}
for i = 1, #G.jokers.highlighted do
    local this_joker = G.jokers.highlighted[i]
    cards[#cards+1] = this_joker
    --print(this_joker.config.center.key)
    if items[this_joker.config.center.key] == nil then items[this_joker.config.center.key] = 0 end
    items[this_joker.config.center.key]=items[this_joker.config.center.key]+1
end
for i = 1,#G.consumeables.highlighted do
    local this_consum = G.consumeables.highlighted[i]
    --print("highlighted has:",this_consum.config.center.key)
    cards[#cards+1] = this_consum
    if items[this_consum.config.center.key] == nil then items[this_consum.config.center.key] = 0 end
    items[this_consum.config.center.key]=items[this_consum.config.center.key]+1
end

for i,v in pairs(self.input) do
    local key = v.key
    local val = v.value
    local val_given = v.recipe_value
    local check_op = v.check_op or ">="
    local function check(key)
        local this_val = val
        --print("cons key:",cons.config.center.key)
        --print("key:",key)
        --if cons.ability.name == key then if items[key] ~= nil then items[key]=items[key]+1 else items[key]=1 end end
        --print("required val:",this_val," val gotten:",items[key])
        if check_op == ">=" then
            if items[key] ~= nil and items[key] >=this_val then return true end
        end
        if check_op == ">" then
            if items[key] ~= nil and items[key] >this_val then return true end
        end
        if check_op == "<" then
            if items[key] ~= nil and items[key] <this_val then return true end
        end
        if check_op == "<=" then
            if items[key] ~= nil and items[key] <=this_val then return true end
        end
        if check_op == "==" then
            if items[key] ~= nil and items[key] == this_val then return true end
        end
        return false
    end
    if type(key) == "function" then key = key(i,self,items,cards) end
    if type(val) == "function" then val = val(i,self,items,cards) end
    if type(val_given) == "function" then val_given = val_given(i,self,items,cards) end
    --[[if items[key] ~= nil and items[key] >=val-1 then
        recipe_value=recipe_value+val_given
    end]]
    if check(key) then
        recipe_value=recipe_value+val_given
    end
end
local recipe_value_required = self.recipe_value_required
if type(recipe_value_required) == "function" then recipe_value_required = recipe_value_required(self,items,cards) end
if recipe_value >=recipe_value_required then
return true,items,cards,recipe_value,recipe_value_required
end
return false
end

function recipes:use(cons)
local can_use,items,cards,recipe_value,recipe_value_required = self:can_use(cons)
local function handle_destroying(cons,card,items,cards,recipe_value,recipe_value_required)
    local this_recipe_value = 0
    local cards_to_destroy = {}
    local cards_destroyed = {}
    local this_cards = {}
    for i = 1,#G.jokers.cards do
        local this_joker = G.jokers.cards[i]
        table.insert(this_cards, this_joker)
    end
    for i = 1,#G.consumeables.cards do
        local this_cons = G.consumeables.cards[i]
        table.insert(this_cards, this_cons)
    end
    --print("going to handle?")
    for i,v in pairs(card.input) do
        --print('looping?')
        if this_recipe_value >=recipe_value_required then break end
        local key = v.key
        local val = v.value
        local destroy_val = v.destroy_value or val
        local val_given = v.recipe_value
        if items[key] ~= nil and items[key] >=val-1 then
            --print("is more?")
            recipe_value=recipe_value+val_given
            if cards_to_destroy[key] == nil then
            cards_to_destroy[key] = destroy_val
            else
                cards_to_destroy[key]=cards_to_destroy[key]+destroy_val
            end
        end

    end
    for i,v in pairs(cards_to_destroy) do
        local key = i
        local val = v
        print(key)
        for x,l in pairs(this_cards) do
            if l.config.center.key == key then
                if cards_destroyed[key] == nil then cards_destroyed[key] = 0 end
                if cards_destroyed[key] <val then
                    l:start_dissolve()
                    cards_destroyed[key]=cards_destroyed[key]+1
                else
                    break
                end
            end
        end
    end
end

local function handle_craft(card,items,cards,recipe_value,recipe_value_required)
local result = card.result
local created_cards = {}
if type(result) == "function" then result = result(card,items,cards,recipe_value,recipe_value_required) end
for i = 1,#result do
    local this_result = result[i]
    local value = this_result.value
    local key = this_result.key
    local set = this_result.set
    local edition = this_result.edition
    local area = this_result.area
    local unique = this_result.unique or false
    local set_values = this_result.set_values or {}
    if type(value) == "function" then value = value(card,result[i]) end
    if type(key) == "function" then key = key(card,result[i],value) end
    if type(set) == "function" then set = set(card,result[i],value,key) end
    if type(edition) == "function" then edition = edition(card,result[i],value,key,set) end
    if type(area) == "function" then area = area(card,result[i],value,key,set,edition) end
    if type(unique) == "function" then unique = unique(card,result[i],value,key,set,edition,area) end
    if type(set_values) == "function" then set_values = set_values(card,result[i],value,key,set,edition,area,unique,set_values) end
    for i = 1,value do
        local created_card = SMODS.create_card({set=set,key=key})
        if unique then
            SMODS.make_card_unique(created_card)
        end
        print("created!")
        created_card:add_to_deck()
        G[area]:emplace(created_card)
        for i,v in pairs(set_values) do
            if type(set_values[i]) ~= "function" then
            created_card[i] = set_values[i]
            else
                created_card[i] = set_values[i](created_card, set_values, i)
            end
        end
        if edition ~= nil then created_card:set_edition(edition, true) end
        table.insert(created_cards, created_card)
    end
end
return created_cards
end
if can_use ~= true then return can_use end
if can_use == true then 
local use_result = self:calculate(items,cards,recipe_value,recipe_value_required)
print('used?')
if use_result ~= nil and type(use_result) == "table" then
    local this_context = {
        consumeable = cons,
        made_recipe = self,
        recipe_use_result = use_result,
        recipe_process = {
            items = items,
            cards = cards,
            recipe_value = recipe_value,
            recipe_value_required = recipe_value_required,
        }
    }
    SMODS.calculate_context(this_context)
    if use_result.handle_craft then
        local created_cards = handle_craft(self,items,cards,recipe_value,recipe_value_required)
        local this_context = {
            consumeable = cons,
            made_recipe = self,
            recipe_use_result = use_result,
            crafted_cards = true,
            recipe_process = {
                created_cards = created_cards,
                items = items,
                cards = cards,
                recipe_value=recipe_value,
                recipe_value_required=recipe_value_required,
            },
        }
        SMODS.calculate_context(this_context)
        local sound = self.sound
        local sound_volume = self.sound_volume or 1
        local sound_pitch = self.sound_pitch or 1
        if type(sound) == "function" then sound = sound(self) end
        if sound ~= nil then
            print("playing sound!")
            play_sound(sound, sound_pitch, sound_volume)
        end
    end
    if use_result.handle_destroying then
        print("handling destroying!")
        handle_destroying(cons,self, items, cards, recipe_value, recipe_value_required)
    end
    return use_result
end

end
end

function recipes:calculate(items,cards,recipe_value,recipe_value_required)
    return {handle_craft = true,handle_destroying=true,}
end
SMODS.recipes = recipes