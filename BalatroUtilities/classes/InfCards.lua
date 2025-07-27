local InfCards = Object:extend()

local function get_zeros(num)
return #tostring(num)-1
end

local function get_inf_card_prefix(inf_card_amount, inf_card_prefix)
local max_prefix = inf_card_prefix["max_prefix"]
local max_prefix_prefix = inf_card_prefix["max_prefix_prefix"]
local this_inf_card_amount = inf_card_amount
local prefixes_change = 1
local this_index = {
    "_prefix",
}
local last_index_string = "max"
local prefixes = "max"
for i,v in pairs(inf_card_prefix) do
    if type(i) == "string" and i:gsub("max", "") ~= i then
        prefixes=prefixes.."_prefix"
        print('yep')
    end
end
local max_amount = inf_card_prefix[prefixes]
if inf_card_amount >inf_card_prefix[prefixes] then
    inf_card_amount=max_amount
    this_inf_card_amount=max_amount
end
local needed_to_add_custom_one = 2


while true do
    local index_string = "max"..table.concat(this_index)
    print(index_string)
    if inf_card_prefix[index_string] == nil then break end
    if inf_card_prefix[index_string] ~= nil then
      if this_inf_card_amount <inf_card_prefix[index_string] then
        break
      end
      if this_inf_card_amount >=inf_card_prefix[index_string]then
         table.insert(this_index, "_prefix")
         print(inf_card_prefix[index_string])
         if inf_card_prefix[index_string] == 10 then
            needed_to_add_custom_one=needed_to_add_custom_one+1
         end
         print("before divide:",this_inf_card_amount)
         local this_inf_card_amount_before_divide = this_inf_card_amount
         this_inf_card_amount=this_inf_card_amount/inf_card_prefix[index_string]
         --this_inf_card_amount=this_inf_card_amount-inf_card_prefix[index_string]
         prefixes_change=prefixes_change+1
         if math.ceil(this_inf_card_amount) ~= this_inf_card_amount then
            local prefixes_changes_to_add = math.ceil(this_inf_card_amount*inf_card_prefix[index_string])-(inf_card_prefix[index_string])
            --prefixes_changes_to_add=math.ceil(prefixes_changes_to_add*inf_card_prefix[index_string])
            if prefixes_changes_to_add >1 then
                local this_prefixes_change_to_add = prefixes_changes_to_add
                --[[local subtraction = this_inf_card_amount_before_divide-this_prefixes_change_to_add
                subtraction=subtraction]]
                local t_e = math.clamp(#this_index, -1, 1)
                local this_index_num = "max"
                for i = 1,t_e do
                    this_index_num=this_index_num..this_index[t_e]
                end
                this_index_num=inf_card_prefix[this_index_num]
                print('this_index_num:',this_index_num)
                local sub_e = 10^get_zeros(this_inf_card_amount_before_divide)
                print(sub_e)
                print(math.ceil((this_inf_card_amount_before_divide/sub_e)-1))
                local subtraction = math.ceil(this_inf_card_amount_before_divide/sub_e)
                subtraction=subtraction-1
                if subtraction == 1 and this_inf_card_amount_before_divide<this_index_num then subtraction = 0 end
                subtraction=subtraction*(10^get_zeros(this_inf_card_amount_before_divide+1))
                print("sub:",subtraction)
                print("more than one:",prefixes_changes_to_add)
                local last_val = this_index[#this_index]
                print('last val:',last_val)
                this_index[#this_index] = this_inf_card_amount_before_divide-subtraction
                this_index[#this_index+1] = last_val
                prefixes_changes_to_add=1
            end
            prefixes_change=prefixes_change+prefixes_changes_to_add
            print("added:",prefixes_changes_to_add)
            print(type(prefixes_change))
            print(prefixes_change)
            local last_value = this_index[#this_index]
            this_index[#this_index] = prefixes_changes_to_add
            this_index[#this_index+1] = last_value
            this_inf_card_amount=math.floor(this_inf_card_amount)
         end
         last_index_string = index_string
       end
    else
        if this_inf_card_amount >inf_card_prefix[last_index_string] then
            this_inf_card_amount=inf_card_prefix[last_index_string]-1
        end
        break
    end
end
local new_inf_card_prefix = ""
local this_index_string = "max"
--print(prefixes_change)
local custom_one = inf_card_prefix.custom_one or ""
for i = 1,prefixes_change do
    --[[print(i)
    print("value:",this_index[i-1])
    print(this_index_string)]]
    if this_index[i-1] ~= nil and type(this_index[i-1]) ~= "number" then
    this_index_string=this_index_string..this_index[i-1]
    end
    local current_inf_card_amount = this_inf_card_amount
    if inf_card_prefix[this_index_string] ~= nil then
        current_inf_card_amount=current_inf_card_amount*inf_card_prefix[this_index_string]
        --current_inf_card_amount=current_inf_card_amount+inf_card_prefix[this_index_string]
        print("inf card amount before ceil:")
        print(current_inf_card_amount)
        current_inf_card_amount=math.ceil(current_inf_card_amount)
        if this_index[i-1] ~= nil and type(this_index[i-1]) == "number" then
          --print('setting number?')
          current_inf_card_amount = this_index[i-1]
        end
        if current_inf_card_amount > inf_card_prefix["max_prefix"] then
            current_inf_card_amount = inf_card_prefix["max_prefix"]
        end
        print("current inf card amount:",current_inf_card_amount)
        if inf_card_prefix[current_inf_card_amount] ~= nil then
            local this_prefix = inf_card_prefix[current_inf_card_amount]
            this_prefix=this_prefix:gsub("tomic","")
            new_inf_card_prefix=new_inf_card_prefix:gsub("(%u)", string.lower, 1)
            new_inf_card_prefix=this_prefix..new_inf_card_prefix
        end
        if current_inf_card_amount == 1 then
            new_inf_card_prefix=new_inf_card_prefix:gsub("(%u)", string.lower, 1)
            new_inf_card_prefix=custom_one..new_inf_card_prefix
        end
    end
end
local this_prefix = inf_card_prefix[this_inf_card_amount]
print(this_inf_card_amount)
print(this_prefix)

if this_prefix ~= nil then new_inf_card_prefix=new_inf_card_prefix:gsub("(%u)", string.lower, 1) new_inf_card_prefix=this_prefix..new_inf_card_prefix end
if this_inf_card_amount == 1 and prefixes_change >needed_to_add_custom_one then new_inf_card_prefix=new_inf_card_prefix:gsub("(%u)", string.lower, 1) new_inf_card_prefix=custom_one..new_inf_card_prefix end
if prefixes_change == 2 and inf_card_prefix[inf_card_amount] ~= nil then return inf_card_prefix[inf_card_amount] end
print(new_inf_card_prefix)
return new_inf_card_prefix
end

local function create_inf_card(params,inf_card_prefix,amount)
    for i = 1,amount do
        local this_params = {}
        local prefix = get_inf_card_prefix(i,inf_card_prefix)
        for x,v in pairs(params) do
            local val = params[x]
            if type(val) == "function" then
                this_params[x] = val({gen = i,prefix=prefix,prefix_table=inf_card_prefix,ref=params.ref})
            else
                this_params[x] = val
            end
        end
        local object_type = this_params.object_type
        local generated_inf_card = SMODS[object_type](this_params)
        if SMODS.GeneratedInfCards[object_type] == nil then SMODS.GeneratedInfCards[object_type] = {} end
        print("this params key:",this_params.key)
        print("generated card key:",generated_inf_card.key)
        table.insert(SMODS.GeneratedInfCards[object_type], generated_inf_card)

    end
end

function InfCards:init(inf_card_table)
local amount = inf_card_table.amount
local inf_card_prefix = inf_card_table.inf_prefix
create_inf_card(inf_card_table.params, inf_card_prefix, amount)
end
SMODS.InfCards = InfCards
SMODS.GeneratedInfCards = {}
SMODS.GetInfCardPrefix = get_inf_card_prefix