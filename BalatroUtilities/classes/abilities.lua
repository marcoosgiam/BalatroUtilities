local abilities = Object:extend()
local function update_ability_input(object)
    object.keybind = object.input
end

function abilities:BindInput(input)
    if type(input) == "table" and input.keys ~= nil then
        self.input = input
        update_ability_input(self)
    end
end

function abilities:init(abilities_table)
    self.name = abilities_table.name
    self.prefix = abilities_table.prefix
    self.center = {
        config = abilities_table.config,
        calculate = abilities_table.calculate,
    }
    if self.center.config.input ~= nil then
        self:BindInput(self.center.config.input)
    end
    if self.center.config.input_type == nil then
        self.center.config.input_type = "pressed"
    end
    self.input_type = self.center.config.input_type
    self.set = "BalatroUtilitiesAbility"
    local ability_name = "ability_"..self.prefix.."_"..self.name
    SMODS.abilities[ability_name] = self
end
SMODS.abilities = abilities
local abilitiesCardArea = {
    X = {
    scale=0,    
    },
    Y = {
    scale=0,
    },
    W = {
    scale=0,
    },
    H = {
    scale=0,
    },

}