local card_meta = getmetatable(Card)
local has_last = {
    __add = nil,
    __sub = nil,
    __mul = nil,
    __div = nil,
    __mod = nil,
    __pow = nil,
    __idiv = nil,
}
local o_pairs = pairs
local o_ipairs = ipairs
local o_is_number = is_number
local o_number_format = number_format
local o_lenient_bignum = lenient_bignum
local o_to_big = to_big
local o_math_floor = math.floor
local o_to_number = to_number
local o_math_abs = math.abs

local function transform_operations(val)
    if type(val) == "table" and val.__type == "number" then
        val = val.value
    end

    return val
end
local function transform_num_to_scaling_num(num)
    if type(num) == "number" then
        num = create_number(num)
    end
    return num
end
number_format = function(num,e_switch_point)
    if type(num) == "table" and num.__type == "number" then
        local result = transform_operations(num)
        return result
    end
    return o_number_format(num,e_switch_point)
end
lenient_bignum = function(x)
     if type(x) == "table" and x.__type == "number" then
        --x=transform_operations(x)
        print("transformed:",x)
        return x
    end
    local result = o_lenient_bignum(x)
    return result
end
to_big = function(x,y)
    if type(x) == "table" and x.__type == "number" then
    --x=transform_operations(x)
    print('transformed x:',x)
    return x
    end
    y=transform_operations(y)
    return o_to_big(x,y)
end
function math.floor(x)
    if type(x) == "table" and x.__type == "number" then
        x = transform_operations(x)
    end
    return o_math_floor(x)
end
function to_number(x)
if type(x) == "table" and x.__type == "number" then
    return transform_operations(x)
end
return o_to_number(x)
end
math.abs = function(x)
    if type(x) == "table" and x.__type == "number" then
        x = transform_operations(x.value)
    end
    return o_math_abs(x)
end
--[[local math_funcs = {}
for i,v in pairs(math) do
    local last_math = v
    math[i] = function(...)
        local args = {...}
        for i,v in ipairs(args) do
            args[i]=transform_operations(v)
        end
        return last_math(args)
    end
    math_funcs[i] = math[i]
end]]

is_number = function(x)
    local result = o_is_number(x)
    if result == false and type(x) == "table" and x.__type == "number" then return true end
    return result
end
pairs = function(t)
    if t then
        local mt = getmetatable(t)
        if mt and mt.__pairs then
            return mt.__pairs(t)
        end
    end
    return o_pairs(t)
end
ipairs = function(t)
    if t then
        local mt = getmetatable(t)
        if mt and mt.__ipairs then
            return mt.__ipairs(t)
        end
    end
    return o_ipairs(t)
end
local parents = {}
local function store_parents(v, parent)
    --print('storing parent:',parent)
    parents[v] = parent
end
local function unwrap(val)
    if type(val) == "table" and val.__type == "number" then
        return val.value
    else
        return val
    end
end
has_last["__eq"] = function(t,val)
    val=transform_operations(val)
    return t.value==val
end
has_last["__le"] = function(t,val)
    return unwrap(t)<=unwrap(val)
end
has_last["__lt"] = function(t,val)
    return unwrap(t)<unwrap(val)
end
has_last["__add"] = function(t, val)
    val=transform_operations(val)
    --print(t)
    --print(val)
    return t+val
end
has_last["__sub"] = function(t, val)
    val=transform_operations(val)
    return t-val
end
has_last["__mul"] = function (t,val)
    val=transform_operations(val)
    return t*val
end
has_last["__div"] = function (t,val)
    val=transform_operations(val)
    return t/val
end
has_last["__mod"] = function (t,val)
    val=transform_operations(val)
    return t%val
end
has_last["__pow"] = function (t,val)
    val=transform_operations(val)
    return t^val
end
local overrides = {
    __add = function(t, val)
        --print("add called???")
        --print('type:',type(t))
        --print('type val:',type(val))
        if type(val) == "table" and type(t) == "number" then
            local l_t = t
            t = val
            val = l_t
            --print("reversed???")
        end
        local new_val = nil
        if type(t) == "number" then t = {value = t} end
        if has_last["__add"] then
            --print("has last called??")
            new_val = has_last["__add"](t.value,val)
        end
        local meta = val or {}
        local parent = parents[meta]
        --print("my parent:",parent)
        local this_val = transform_operations(t)
        local new_val = SMODS.calculate_scaling_mod(this_val, new_val, "+", parent)
        --print('got this val?')
        new_val = create_number(new_val, parent)
        --print("created val:",new_val)
        return new_val
    end,
    __sub = function(t, val)
        local new_val = nil
        if type(t) == "number" then t = {value = t} end
        if has_last["__sub"] then
            new_val = has_last["__sub"](t.value,val)
        end
        local meta = val or {}
        local parent = parents[meta]
        local this_val = transform_operations(t)
        local new_val = SMODS.calculate_scaling_mod(this_val, new_val, "-", parent)
        new_val = create_number(new_val, parent)
        return new_val
    end,
    __mul = function(t, val)
        local new_val = nil
        if type(t) == "number" then t = {value = t} end
        if has_last["__mul"] then
            new_val = has_last["__mul"](t.value,val)
        end
        local meta = t or {}
        local parent = parents[meta]
        local new_val = SMODS.calculate_scaling_mod(t.value, new_val, "*", parent)
        new_val = create_number(new_val, parent)
        return new_val
    end,
    __div = function(t, val)
        local new_val = nil
        if type(t) == "number" then t = {value = t} end
        if has_last["__div"] then
            new_val = has_last["__div"](t.value,val)
        end
        local meta = t or {}
        local parent = parents[meta]
        local new_val = SMODS.calculate_scaling_mod(t.value, new_val, "/", parent)
        return new_val
    end,
    __mod = function(t, val)
        local new_val = nil
        if type(t) == "number" then t = {value = t} end
        if has_last["__mod"] then
            new_val = has_last["__mod"](t.value,val)
        end
        local meta = t or {}
        local parent = parents[meta]
        local new_val = SMODS.calculate_scaling_mod(t.value, new_val, "%", parent)
        new_val = create_number(new_val, parent)
        return new_val
    end,
    __pow = function(t, val)
        local new_val = nil
        if type(t) == "number" then t = {value = t} end
        if has_last["__pow"] then
            new_val = has_last["__pow"](t.value,val)
        end
        local meta = t or {}
        local parent = parents[meta]
        local new_val = SMODS.calculate_scaling_mod(t.value, new_val, "^", parent)
        new_val = create_number(new_val, parent)
        return new_val
    end,
    __idiv = function(t, val)
        local new_val = nil
        if type(t) == "number" then t = {value = t} end
        if has_last["__idiv"] then
            new_val = has_last["__idiv"](t.value,val)
        end
        local meta = t or {}
        local parent = parents[meta]
        local new_val = SMODS.calculate_scaling_mod(t.value, new_val, "//", parent)
        new_val = create_number(new_val, parent)
    end,
    __tostring = function(t)
        return tostring(t.value)
    end,
}
overrides.__lt = function(a,b)
    a=transform_operations(a)
    b=transform_operations(b)
    --print('less than called')
    return false
end
overrides.__gt = function(a,b)
   a=unwrap(a)
   b=unwrap(b)
   --print('greater than called')
   return a>b
end
overrides.__gte = function(a,b)
    a=unwrap(a)
    b=unwrap(b)
    --print("greater or equal to called")
    return a>=b
end
overrides.__lte= function(a,b)
    a=unwrap(a)
    b=unwrap(b)
    --print('less than or equal to called')
    return a<=b
end
overrides.__eq= function(a,b)
    a=unwrap(a)
    b=unwrap(b)
    return a<=b
end

local last_add_to_deck = Card.add_to_deck

function deep_replace_numbers(t, p)
    for i,v in pairs(t) do
        if type(v) == "number" then
            t[i] = create_number(v, p)
            print("replaced number:",v," index:",i)
        end
        if o_is_number(t) then
            print("talisman number found")
            t[i] = create_number(number_format(v), p)
        end
        if type(v) == "table" and not o_is_number(t) then
            deep_replace_numbers(v, p)
        end
        
    end
end

function replace_numbers(t, p)
for i,v in pairs(t) do
    if type(v) == "number" then
        t[i] = create_number(v, p)        
    end
end
end

function create_table_reference()
    local reference = {}
    return reference
end

function create_number_table(t)
    local reference = create_table_reference()
    for i,v in pairs(t) do
        reference[i] = t[i]
        t[i] = nil
    end
    local meta = {
        __newindex = function(t, k, v)
            ----print('tried to set new index at number table?')
            if type(v) == "table" and v.__type == "number" then
                rawset(reference, k, v)
            elseif type(v) == "table" and v.__type ~= "number" and not o_is_number(v) then
                create_number_table(v)
                rawset(reference, k, v)
            elseif type(v) ~= "table" then
                rawset(reference, k, v)
            end
        end,
        __index = function (t, k)
            local value = reference[k]
            ----print("trying to get reference:",k)
            if type(value) == "table" and value.__type == "number" then
                --print("k is custom number")
                return value
            elseif type(value) == "table" and value.__type ~= "number" then
                return value
            elseif type(value) ~= "table" then
                return value
            end
        end,
    }
    meta.__pairs = function(t)
        --print("pairs called")
        return next,reference,nil
    end
    meta.__ipairs = function(t)
        local function iter(t, i)
            i=i or 0
            i=i+1
            local v = t[i]
            if v ~= nil then
                return i,v
            end
        end
        return iter,reference,nil
    end
    setmetatable(t, meta)
    ----print("created number table:",t)
end

function deep_create_number_table(t)
    create_number_table(t)
    for i,v in pairs(t) do
        ----print('looping??')
        if type(v) == "table" and v.__type ~= "number" then
            deep_create_number_table(v)
        end
    end
end

function create_number(num, parent)
    local this_num = {
        value = num,
        __type = "number",
    }
    setmetatable(this_num, overrides)
    if parent ~= nil then
    store_parents(this_num, parent)
    end
    return this_num
end

local last_eval_status_text = card_eval_status_text
local last_calculate = SMODS.calculate_individual_effect
--[[local original_calculate_hand = calculate_hand
calculate_hand = function(cards, hand, mult, base_mult, base_scoring, scoring_hand)
    --print("calculating hand!")
end]]
local last_modify_hand = Blind.modify_hand
function Blind:modify_hand(cards, poker_hands, text, mult, hand_chips, scoring_hand)
    return last_modify_hand(self, cards, poker_hands, text, mult,hand_chips,scoring_hand)
end

local o_mod_chips = mod_chips
local o_mod_mult = mod_mult

function mod_chips(_chips)
    return o_mod_chips(_chips)
end

function mod_mult(_mult)
  return o_mod_mult(_mult)
end

G.eval_status = {
    mult={},
    chips={},
}
local function fix_number(eval, ignore, deep)
deep=deep or true
----print("eval:",eval)
ignore = ignore or {}
for i,v in pairs(eval) do
    if type(v) == "table" and v.__type == "number" then
        eval[i] = transform_operations(v)
        ----print("fixed:",i)
    end
    if type(v) == "table" and v.__type ~= "number" and ignore[i] ~= true and ignore[v] ~= true and deep == false then
        fix_number(v, ignore)
    end
end
end

local l_calculate_joker = Card.calculate_joker
function Card:calculate_joker(context)
    fix_number(self.ability, nil, false)
    local result = l_calculate_joker(self,context)
    if result ~= nil then
    print('result:',result)
    end
    if result ~= nil then fix_number(result, {card = true,[self]=true,}) print("fixed result:",result) end
    local transform_index = {
        "chips","mult","xmult","emult","xchips","echips",
    }
    if result ~= nil then
    --result.mult = transform_operations(result.mult)
        --[[for i,v in ipairs(transform_index) do
        result[i] = to_big(result[i])
    end]]
    end
    replace_numbers(self.ability, self)
    return result
end

--[[SMODS.calculate_individual_effect = function(effect, scored_card, key, amount, from_edition)
    last_calculate(effect,scored_card,key,amount,from_edition)
end]]
--[[function card_eval_status_text(card, eval_type, amt, percent, dir, extra)
    if type(amt) == "table" and amt.__type == "number" then
        amt =amt.value
    end
    return last_eval_status_text(card, eval_type, amt, percent, dir, extra)
end]]

function Card:add_to_deck(...)
    if self.config.center.set ~= "Default" then
    local last_meta = getmetatable(self.ability)
    if last_meta then
        print('for some reason has a metatable')
    end
    setmetatable(self.ability, nil)
    
    ----print('before pairs in ability')
    ----print("ability:",self.ability)
    for i,v in pairs(self.ability) do
        if type(v) == "table" and v.__type == "number" then
            local num = v
            self.ability[i] = nil
            self.ability[i] = transform_operations(num)
            print("should have replaced ",i,":",num)
        end
    end
    self.ability = table.clone(self.ability)
    last_add_to_deck(self,...)
    print("added card to deck lol!!!")
    --deep_create_number_table(self.ability)
    deep_replace_numbers(self.ability, self)
    deep_create_number_table(self.ability)
    end
end

local last_set_ability = Card.set_ability
function Card:set_ability(center, initial, delay_sprite)
    --print('before set ability')
    last_set_ability(self, center, initial, delay_sprite)
    --print('tried setting ability')
end
local last_copy_card = copy_card
local function transform_table(t, keep_meta)
    keep_meta=keep_meta or false
    local transformed = {}
    for i,v in pairs(t) do
        if type(v) == "table" and v.__type == "number" then
            transformed[i] = transform_operations(v) or 0
        elseif type(v) == "table" and v.__type ~= "number" then
            transformed[i] = transform_table(v)
            if keep_meta and getmetatable(v) ~= nil then
                setmetatable(transformed[i], getmetatable(v))
            end
        elseif type(v) ~= "table" then
            transformed[i] = v
        end
    end
    if keep_meta and getmetatable(t) ~= nil then
        setmetatable(transformed, getmetatable(t))
    end
    return transformed
end
copy_card = function(other, new_card, card_scale,playing_card)
    local o_other = other
    other = {

    }
    local ability = {}
    ability = transform_table(o_other.ability)
    other.ability = ability
    for i,v in pairs(o_other) do
        if i ~= "ability" then other[i]=v end
    end
    local copied_card = last_copy_card(other, new_card, card_scale, playing_card)
    return copied_card
end
local last_copy_table = copy_table
copy_table = function(O)
    if type(O) == "table" and getmetatable(O) == Card then
        return copy_card(O)
    end
    return last_copy_table(O)
end

local last_remove_from_deck = Card.remove_from_deck
function Card:remove_from_deck(from_debuff)
    for i,v in pairs(self.ability) do
        if type(v) == "table" and v.__type == "number" then
            self.ability[i] = transform_operations(v)
        end
    end
    return last_remove_from_deck(self,from_debuff)
end
local last_save = Card.save
local function retransform_table(t)
    for i,v in pairs(t) do
        if type(v) == "table" and v.__type == "number" then
            t[i] = transform_operations(v)
        elseif type(v) == "table" and v.__type ~= "number" then
            retransform_table(v)
        end
    end
end
--[[function Card:save(...)
    print("save called?")
    local all_args = {self,...}
    retransform_table(self.ability)
    return last_save(unpack(all_args))
end]]
local last_load = Card.load
function Card:load(cardTable,other_card)
if cardTable.ability then
retransform_table(cardTable.ability)
end
local r = last_load(self,cardTable,other_card)
print("set:",self.config.center.set)
if self.ability and self.config.center.set ~= "Default" then
    deep_replace_numbers(self.ability, self)
    deep_create_number_table(self.ability)
end
return r

end

local last_back_apply_to_run = Back.apply_to_run

function Back:apply_to_run()
local r = last_back_apply_to_run(self)
print("back effect:",self.effect.config)
deep_replace_numbers(self.effect.config, self)
deep_create_number_table(self.effect.config)
return r
end
local last_back_load = Back.load
function Back:load(backTable)
    retransform_table(backTable.effect.config)
    local r = last_back_load(self, backTable)
    deep_replace_numbers(self.effect.config, self)
    deep_create_number_table(self.effect.config)
    return r
end
local last_back_trigger_effects = Back.trigger_effect
function Back:trigger_effect(args)
local r = last_back_trigger_effects(self, args)
if r ~= nil then
fix_number(r, {card = true,[self]=true,})
end
return r
end

local last_can_use_consumeable = Card.can_use_consumeable
--[[function Card:can_use_consumeable(any_state, skip_check)
    fix_number(self.ability, nil, false)
    local r = last_can_use_consumeable(self, any_state, skip_check)
    replace_numbers(self.ability, self)
    return r
end]]

--[[local gfep = G.FUNCS.evaluate_play
G.FUNCS.evaluate_play = function(e)
    local ret = gfep(e)
    --print(ret)
end]]