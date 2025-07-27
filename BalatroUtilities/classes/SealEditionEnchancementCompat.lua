--[[
local lastCardInit = Card.init
--Card
function Card:init(X,Y,W,H,card,center,params)
    lastCardInit(self, X, Y, W, H, card, center, params)
    self.editions = {
        
    }
    self.max_same_edition = 1
    self.edition_value = {}
    self.temp = {}
    if self.edition then
        self.editions[self.edition_type] = 1
        self.edition = table.clone(self.edition)
    end
    self.seals = {
        self.seal,
    }
    self.multiple_compat = true
end

local last_set_edition = Card.set_edition
function Card:set_edition(edition, immediate, silent, ignore_multiple_compat)
    ignore_multiple_compat=ignore_multiple_compat or false
    local result = last_set_edition(self, edition, immediate, silent)
    if self.edition ~= nil then
    self.edition = table.clone(self.edition)
    end
    print("trying setting multiple editions!")
    if self.edition == nil then return result end
    if self.edition.types == nil then self.edition.types = {} end
    if self.multiple_compat == true and ignore_multiple_compat ~= true then
        if self.edition_value[self.edition.type] == nil then
            self.edition_value[self.edition.type] = table.clone(self.edition)
        end
        print("yep multiple compat is true lol!")
        if self.editions[self.edition.type] == nil then self.editions[self.edition.type] = 0 end
        if self.edition_values == nil then self.edition_values={} end
        table.clear(self.edition.types)
        table.clear(self.edition_values)
        self.edition_values = {}
        self.edition.types = {}
        if self.max_same_edition == "infinite" or self.editions[self.edition.type] < self.max_same_edition then
        self.editions[self.edition.type]=self.editions[self.edition.type]+1
        print("value after adding:",self.editions[self.edition.type])
        end
        for i,v in pairs(self.editions) do
            print(i..":"..v)
            local multiplier = v
            local this_type_amount=v
            print(this_type_amount)
            local c = self.edition_value[i]
            if self.edition.types[c.type] == nil then self.edition.types[c.type]=0 end
            self.edition.types[c.type]=self.edition.types[c.type]+1
            local banished_keys = {
                ["types"] = true,
                ["type"] = true,
                [c.type] = true,
                ["key"] = true,
            }
            for x,l in pairs(c) do
                if banished_keys[x] ~= true then
                print(x)
                --print(l)
                --[[if self.edition_values[x] ~= nil then
                    if type(self.edition_values[x]) == "number" then
                        self.edition_values[x]=self.edition_values[x]+(l*v)
                    end
                    if type(self.edition_values[x]) == "table" then
                        self.edition_values[x]=table.merge(self.edition_values[x], l, "+")
                    end
                end]]
                --[[local total = c[x]*multiplier
                print("total:",total)
                self.edition_values[x]=total
                --[[if self.edition_values[x] == nil then
                    self.edition_values[x]=total
                else
                    self.edition_values[x]=self.edition_values[x]+total
                end
                print("edition values:",self.edition_values[x])]]
            --[[end
            end
        end
    else
        self.editions[edition.type] = 1
    end
    for i,v in pairs(self.edition.types) do
        self.edition[i] = true
        print("set:",i," to true")
    end
    if self.edition_values ~= nil then
        for i,v in pairs(self.edition_values) do
            print("setting:",i," to:",v)
            self.edition[i] = v
            if i == "chips" then
                self.edition.chip_mod=v
            end
            if i == "mult" then
                self.edition.mult_mod=v
            end
            if i == "x_mult" then
                self.edition.x_mult_mod=v
            end
        end
    end
    return result
end
local last_eval_card = eval_card
--[[eval_card = function(card,context)
    local ret,retf = last_eval_card(card, context)
    if not card:can_calculate(context.ignore_debuff) then return ret,retf end
    --apply multiple edition calculation
    local editions = {}
    if ret == nil then print("ret is nil?") end
    if retf == nil then print("retf is nil?") end
    if card.edition ~= nil then
    for i,v in pairs(card.edition.types) do
        print("found:",i)
        table.insert(editions, i)
    end
    end
    for i,v in pairs(editions) do
        print(i)
        print(v)
        local c = card.edition_value[i]
        if c ~= nil then
        local key = c.key
        local center = G.P_CENTERS[key]
        if center.calculate and type(center.calculate) == "function" then
            local ret2,retf2 = center:calculate(self,context)
            if ret2 ~= nil then
                ret=table.merge(ret,ret2,"+")
            end
            if retf2 ~= nil then
                retf2=table.merge(ret,ret2,"+")
            end
        end
    end
end
if ret ~= nil then print(unpack(ret)) end
return ret,retf
end]]

--print("loaded this?")

--Seal]]
