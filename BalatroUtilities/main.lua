local calc_joker = Card["calculate_joker"]
local function shouldCloneMeta(meta)
    for k, v in pairs(meta) do
        if type(v) == "table" then
            return true
        end
    end
    return false
end

table.clone = function(tablToClone, depth, seen)
    depth = depth or 0
    seen = seen or {}

    if type(tablToClone) ~= "table" then
        error("type of #1 arg is not a table")
    end

    if seen[tablToClone] then
        return seen[tablToClone]
    end

    local new = {}
    seen[tablToClone] = new

    -- Clone keys and values
    for k, v in pairs(tablToClone) do
        local newKey = (type(k) == "table") and table.clone(k, depth + 1, seen) or k
        local newVal = (type(v) == "table") and table.clone(v, depth + 1, seen) or v
        new[newKey] = newVal
    end

    -- Clone metatable
    local meta = getmetatable(tablToClone)
    if meta then
        if seen[meta] then
            setmetatable(new, seen[meta])
        else
            local newMeta = {}
            seen[meta] = newMeta
            for k, v in pairs(meta) do
                local newKey = (type(k) == "table") and table.clone(k, depth + 1, seen) or k
                local newVal = (type(v) == "table") and table.clone(v, depth + 1, seen) or v
                newMeta[newKey] = newVal
            end
            setmetatable(new, newMeta)

            -- 🔁 Recursively clone metatable of the metatable
            local metaMeta = getmetatable(meta)
            if metaMeta then
                local clonedMetaMeta = table.clone(metaMeta, depth + 1, seen)
                setmetatable(newMeta, clonedMetaMeta)
            end
        end
    end
    return new
end
table.clear = function(tablToClear)--Clears targeted table.
    for i,v in pairs(tablToClear) do
        tablToClear[i] = nil
    end
    tablToClear={}
end
table.merge = function(tabl1, tabl2, merging_type)--Merges two tables together given a merging_type.
    local new = {}
    local function place_value(i,v,merging_type)
        local new_value = nil
        if new[i] ~= nil then
            if merging_type == "+" then
                if type(v) == "number" and type(new[i]) == "number" then new_value=new[i]+v end
                if type(v) == "string" and type(new[i]) == "string" then new_value=new[i]..v end
                if type(v) == "function" and type(new[i]) == "function" then new_value=SMODS.Extender:Extend(new, i, v, false) end
                if type(v) == "table" and type(new[i]) == "table" then 
                local meta = getmetatable(new[i])
                if meta == nil then meta = getmetatable(v) end
                new_value=table.merge(v, new[i], merging_type)
                if meta ~= nil then setmetatable(new_value, meta) end
                end            end
            if merging_type == "-" then
                if type(v) == "number" and type(new[i]) == "number" then new_value=new[i]-v end
                if type(v) == "string" and type(new[i]) == "string" then new_value=string.gsub(new[i], v, "") end
                if type(v) == "function" and type(new[i]) == "function" then new_value=v end
                if type(v) == "table" and type(new[i]) == "table" then 
                local meta = getmetatable(new[i])
                if meta == nil then meta = getmetatable(v) end
                new_value=table.merge(v, new[i], merging_type)
                if meta ~= nil then setmetatable(new_value, meta) end
                end            end
            if merging_type == "*" then
                if type(v) == "string" and type(new[i]) == "string" then new_value=new[i] end
                if type(v) == "number" and type(new[i]) == "number" then new_value=v*new[i] end
                if type(v) == "function" and type(new[i]) == "function" then new_value=new[i] end
                if type(v) == "table" and type(new[i]) == "table" then 
                local meta = getmetatable(new[i])
                if meta == nil then meta = getmetatable(v) end
                new_value=table.merge(v, new[i], merging_type)
                if meta ~= nil then setmetatable(new_value, meta) end
                end            end
            if merging_type == "/" then
                if type(v) == "string" and type(new[i]) == "string" then new_value=new[i] end
                if type(v) == "number" and type(new[i]) == "number" then new_value=v/new[i] end
                if type(v) == "function" and type(new[i]) == "function" then new_value=new[i] end
                if type(v) == "table" and type(new[i]) == "table" then 
                local meta = getmetatable(new[i])
                if meta == nil then meta = getmetatable(v) end
                new_value=table.merge(v, new[i], merging_type)
                if meta ~= nil then setmetatable(new_value, meta) end
                end
                
            end
        end
        if new[i] == nil then
            new_value=v
        end
        new[i] = new_value
    end
    for i,v in pairs(tabl1) do
    place_value(i, v, merging_type)
    end
    for i,v in pairs(tabl2) do
    place_value(i, v, merging_type)
    end
    return new
end
string.escape_g_sub_pattern = function(s)
    return (s:gsub("([^%w])", "%%%1"))
end
local mod_path = "" .. SMODS.current_mod.path
local function load_classes()
local classes_directory = NFS.getDirectoryItems(mod_path .. "classes")
for i,file in ipairs(classes_directory) do
local f, err = SMODS.load_file("classes/"..file)
if err then
error(err)
end
f()
end
end
math.clamp = function(n, min, max)
    if n<min then return min end
    if n>max then return max end
    return n
end
local BalatroBlind = SMODS.Blind
local smods_abilities = {

}
local smods_blind = {

}
SMODS.copy_card = function(other, new_card, card_scale, playing_card, strip_edition)
    local c = copy_card(other, new_card, card_scale, playing_card, strip_edition)
    if type(c.ability.extra) == "table" and c.ability.extra.copy_trigger then
        c.ability.extra.copy_trigger = false
        G.E_MANAGER:add_event(Event({
            func = function ()
                c.ability.extra.copy_trigger = true
                return true
            end,
            delay = 0.1,
            trigger = "after",
        }))
    end
    return c
end

--Adds Custom Buttons
G.FUNCS.custom_button = function(e)
    local this_card = e.config.ref_table.this_card
    local button_id = e.config.ref_table.id
    SMODS.calculate_context{
        card = this_card,
        custom_button_pressed = true,
        button_id = button_id,
    }
end

local last_use_and_sell_buttons = G.UIDEF.use_and_sell_buttons
G.UIDEF.use_and_sell_buttons = function(card)
    local t = last_use_and_sell_buttons(card)
    local custom_buttons = card.config.center.config.custom_buttons or {}
    local function create_custom_button(b_t)
      local button_text = b_t.text
      local width = b_t.w or 0.05
      local h = b_t.h or 0.3
      if localize(button_text) ~= "ERROR" then button_text=localize(b_t.text) end
      local custom_button = {n=G.UIT.C, config={align = "cr"}, nodes={
      {n=G.UIT.C, config={ref_table = {this_card=card,id=b_t.id,}, align = "cr",maxw = 1.25, padding = 0.1, r=0.2, minw = 1.25, minh = (card.area and card.area.config.type == 'joker') and 0 or 1, hover = true, shadow = true, colour = b_t.colour or G.C.WHITE, one_press = false, button = 'custom_button'}, nodes={
        {n=G.UIT.B, config = {w=width,h=h}},
        {n=G.UIT.T, config={text = button_text,colour = b_t.text_colour or G.C.BLACK, scale = b_t.text_scale or 0.55, shadow = true}}
      }}
    }}
    return custom_button
    end
    for i,v in ipairs(custom_buttons) do
        local this_button = create_custom_button(v)
        table.insert(t.nodes[1].nodes, this_button)
    end
    return t
end
function SMODS.calculate_scaling_mod(t, new_val, operation, card, card_doing_scale)
    local operation_value = t
    local jokers = G.jokers or {}
    local jokers = jokers.cards or {}
    local consumeables = G.consumeables or {}
    local consumeables = consumeables.cards or {}
    local cards = {}
    for i,v in ipairs(jokers) do
        table.insert(cards, v)
    end
    for i,v in ipairs(consumeables) do
        table.insert(cards, v)    
    end
    if G.GAME.selected_back ~= nil then
    table.insert(cards, G.GAME.selected_back)
    end
    for i,v in ipairs(cards) do 
        local config = v.config or v.effect
        local center = config.center
        local this_card = v
        print(this_card.ability)
        print("found center:",center)
        print('new val:',new_val)
        print("t:",t)
        if center.scale_mod ~= nil then 
            local returned_val=center:scale_mod(this_card,new_val,operation_value,operation,card,card_doing_scale) or new_val
            new_val=returned_val
        end
    end
    return new_val
end
--[[
scale_mod function example:
scale_mod = function(card, val,operation_value, operation, card_being_scaled,card_doing_scale)
if card_being_scaled.config.center.key ~= card.key then
    if operation == "+" then
        return val+card.ability.extra.plus_increase
     end
     if operation == "*" then
        return val*card.ability.extra.multi_increase
     end
end

end
]]

local last_joker_inject = SMODS.Joker.inject
SMODS.Joker.inject = function(self)
    last_joker_inject(self)
    print("hooking joker inject!")
    --print(self)
    --print("meta:",getmetatable(self))
    --print(SMODS.read_function_as_string(self.calculate))
    
end
SMODS.temp_variables = {
    ["Playing Sounds"] = {},
}
SMODS.Extender = {

}
function SMODS.Joker:add_badge(joker, badge)
if joker.config.center ~= nil then
    local joker_config = joker.config.center.config
    local joker_badges = joker_config.badges
    if joker_badges == nil then joker.config.badges = {} joker_badges = joker.config.badges end
    table.insert(joker.config.badges, badge)
end

end
local last_create_mod_badges = SMODS.create_mod_badges
function SMODS.create_mod_badges(obj, badges)
    last_create_mod_badges(obj,badges)
    if obj then
    local obj_badges
    if obj.config and obj.config.badges then
        obj_badges = obj.config.badges
    elseif obj.config and obj.config.center and obj.config.center.config and obj.config.center.config.badges then
        obj_badges = obj.config.center.config.badges
    else
        obj_badges = {}
    end
    for i,badge in pairs(obj_badges) do
        local badge_display_name = badge.display_name
        local badge_colour = badge.colour
        local badge_text_colour = badge.text_colour
        local badge_offset_y = badge.offset_y or -0.05
        local badge_offset_x = badge.offset_x or nil
        local badge_w = badge.w or 2
        local badge_h = badge.h or 0.36
        local size = badge.text_size or 0.9
        local spacing = badge.spacing or 1
        local scale = badge.scale or 0.33
        local font = G.LANG.font
        local max_text_width = 2 - 2*0.05 - 4*0.03*size - 2*0.03
        local calced_text_width = 0
            -- Math reproduced from DynaText:update_text
        for _, c in utf8.chars(badge_display_name) do
            local tx = font.FONT:getWidth(c)*(0.33*size)*G.TILESCALE*font.FONTSCALE + 2.7*1*G.TILESCALE*font.FONTSCALE
            calced_text_width = calced_text_width + tx/(G.TILESIZE*G.TILESCALE)
        end
            local scale_fac =
                calced_text_width > max_text_width and max_text_width/calced_text_width
                or 1
        badges[#badges + 1] = {n=G.UIT.R, config={align = "cm"}, nodes={
                {n=G.UIT.R, config={align = "cm", colour = badge_colour or G.C.GREEN, r = 0.1, minw = badge_w, minh = badge_h, emboss = 0.05, padding = 0.03*size}, nodes={
                  {n=G.UIT.B, config={h=0.1,w=0.03}},
                  {n=G.UIT.O, config={object = DynaText({string = badge_display_name or 'ERROR', colours = badge_text_colour or {G.C.WHITE},float = true, shadow = true, offset_y = badge_offset_y,offset_x=badge_offset_x, silent = true, spacing = spacing*scale_fac, scale = scale*size*scale_fac})}},
                  {n=G.UIT.B, config={h=0.1,w=0.03}},
                }}
              }}
      end
   end
end

SMODS.read_function_as_string = function(f)--reads target function as a string being able to modify it and load it again later on.
    if type(f) == "table" and f:is(SMODS.SourcedFunction) then
        return f.source_code
    end
    local func_source = SMODS.SourcedFunction:get_func_source(f)
    if func_source ~= nil then
        local func_variables = SMODS.SourcedFunction:get_func_variables(f)
        return func_source,func_variables
    end
    local working_dir = love.filesystem.getWorkingDirectory()
    local mods_dir = working_dir.."/Mods"
    print("working directory:",working_dir)
    local function_source,line_defined,last_line_defined = debug.getinfo(f).source,debug.getinfo(f).linedefined,debug.getinfo(f).lastlinedefined
    
    print("function line defined:",line_defined)
    function_source=function_source:gsub("SMODS", "")
    function_source=function_source:gsub("%[", "")
    function_source=function_source:gsub("%]", "")
    function_source=function_source:gsub("=","")
    function_source=function_source:gsub(" ", "/")
    function_source=function_source:gsub('"', "")
    function_source=function_source:gsub("'", "")
    print(function_source)
    local is_vanilla = false
    if function_source:gsub("@", "") ~= function_source then
        function_source=function_source:gsub("@", "/")
        function_source = "/lovely/dump"..function_source
        print("changed to vanilla!")
        print(love.filesystem.getSource())
    end
    if function_source:gsub("_/", "") ~= function_source then
        print("SMODS version:",SMODS.version)
        local smods_version = SMODS.version
        smods_version=smods_version:gsub("~","-")
        smods_version=smods_version:lower()
        local smods_folder = "smods-"..smods_version
        print('smods folder:',smods_folder)
        function_source=function_source:gsub("_/", smods_folder.."/")
    end
    local script_path = mods_dir..function_source
    print(script_path)
    local script_code, read_error=love.filesystem.read("/Mods"..function_source)
    --print(read_error)
    if type(read_error) == "number" then
        print("successfully gotten script code!")
    end
    local lines = {}
    local current_line
    current_line=""
    for i = 1,#script_code do
        local string_char = string.char(script_code:byte(i))
        if string_char == "\n" then
        --print(current_line)
        table.insert(lines, current_line)
        current_line=""
        else
            current_line=current_line..string_char
        end
    end
    local func_code = {}
    local func_variables = {}
    local func_object = nil
    local found_function_definition = false
    for i,line in ipairs(lines) do
        if i >=line_defined then
        local can_insert = true
        local func_sub = line:gsub("function","")
        if func_sub ~= line then
            print("yep function definition found??")
            print(line)
            if found_function_definition == false then
                found_function_definition = true
                can_insert=false
                local args = line:match("%s*%((.-)%)")
                if line:match("function%s+[%w_]+:") then
                    if args == "" then
                        args = "self"
                    else
                        args = "self,"..args
                    end
                end
                local this_object = line:match("function%s+([%w_]+):[%w_]+%s*%(")
                if this_object ~= "" then
                    local success,err = pcall(function()
                        loadstring("return "..this_object)()
                    end)
                    if success then
                        func_object=loadstring("return "..this_object)
                    end
                end
                for variable in args:gmatch("[^,%s]+") do
                    print("variable index:",variable)
                    table.insert(func_variables, variable)
                end
            end

        end
        if can_insert then
        table.insert(func_code, line)
        end

        end
        if i+1 >=last_line_defined then break end
    end
    func_code = table.concat(func_code, "\n")
    --print("function code:",func_code)
    return func_code,func_variables,func_object
end
--[[SMODS.read_function_by_name = function(script_path, func_name)
    local file = io.open(script_path, "r")
    if not file then error("Cannot open file: " .. script_path) end
    local script_code = file:read("*a")
    file:close()

    local lines = {}
    for line in script_code:gmatch("([^\r\n]*\n?)") do
        table.insert(lines, line)
    end

    local func_code = {}
    local func_variables = {}
    local found_function = false
    local capturing = false
    local block_stack = {}
    local start_line_number = nil
    local end_line_number = nil

    local function push_block(t)
        table.insert(block_stack, t)
    end

    local function pop_block(expected)
        if #block_stack == 0 then
            error("Block stack empty when expecting '" .. expected .. "'")
        end
        local top = block_stack[#block_stack]
        if top ~= expected then
            error("Block mismatch: expected '" .. expected .. "', got '" .. top .. "'")
        end
        table.remove(block_stack)
    end

    local function trim_comments_and_lower(line)
        return line:gsub("%-%-.*", ""):lower()
    end

    local function is_block_start(line)
        local l = trim_comments_and_lower(line)
        if l:match("^%s*function%s") then return "function" end
        if l:match("^%s*if%s") and l:match("then") then return "if" end
        if l:match("^%s*for%s") and l:match("do") then return "for" end
        if l:match("^%s*while%s") and l:match("do") then return "while" end
        if l:match("^%s*do%s*$") then return "do" end
        if l:match("^%s*repeat%s*$") then return "repeat" end
        return nil
    end

    local function is_block_end(line)
        local l = trim_comments_and_lower(line)
        if l:match("^%s*end%s*$") then return "end" end
        if l:match("^%s*until%s") then return "until" end
        return nil
    end

    for i, line in ipairs(lines) do
        if not found_function then
            local pattern
            if func_name:find(":") then
                local class, method = func_name:match("([%w_]+):([%w_]+)")
                pattern = "function%s+" .. class .. ":" .. method .. "%s*%((.-)%)"
            else
                pattern = "function%s+" .. func_name .. "%s*%((.-)%)"
            end

            local args = line:match(pattern)
            if args then
                found_function = true
                capturing = true
                start_line_number = i
                print("Function '" .. func_name .. "' found at line:", start_line_number)
                push_block("function")

                if func_name:find(":") then
                    if args == "" then
                        args = "self"
                    else
                        args = "self," .. args
                    end
                end

                for var in args:gmatch("[^,%s]+") do
                    table.insert(func_variables, var)
                end
            end
        elseif capturing then
            local start_block = is_block_start(line)
            if start_block then
                push_block(start_block)
            end

            local end_block = is_block_end(line)
            if end_block then
                if end_block == "end" then
                    local popped = false
                    for _, b in ipairs({"function","if","for","while","do"}) do
                        if #block_stack > 0 and block_stack[#block_stack] == b then
                            pop_block(b)
                            popped = true
                            break
                        end
                    end
                    if not popped then
                        error("Unexpected 'end' at line " .. i .. " without matching block")
                    end

                    if #block_stack == 0 then
                        capturing = false
                        end_line_number = i
                        print("Function '" .. func_name .. "' ends at line:", end_line_number)
                        break
                    end
                elseif end_block == "until" then
                    if #block_stack == 0 or block_stack[#block_stack] ~= "repeat" then
                        error("Unexpected 'until' at line " .. i .. " without matching 'repeat'")
                    end
                    pop_block("repeat")
                end
            end

            table.insert(func_code, line)
        end
    end

    if capturing then
        error("Function '" .. func_name .. "' did not terminate properly. Blocks left: " .. table.concat(block_stack, ", "))
    end

    local code_str = table.concat(func_code, "")
    print("Extracted function code:\n" .. code_str)

    return code_str, func_variables, nil
end]]

SMODS.current_mod.custom_collection_tabs = function()
    local unlocked_recipes = 0
    local recipes = 0
    if G.P_CENTER_POOLS["recipes"] == nil then
        G.P_CENTER_POOLS["recipes"] = {}
    end
    for i,v in pairs(G.P_CENTER_POOLS["recipes"]) do
        recipes=recipes+1
        if v:can_unlock() then
            unlocked_recipes=unlocked_recipes+1
        end
    end
    t = {UIBox_button {
        count = {tally = unlocked_recipes, of = recipes},
        button = 'your_collection_recipe_books', label = {"Recipe Books"}, minw = 5, id = 'your_collection_recipe_books'
    }}
    print(t[1].nodes[1].config.colour)
    t[1].nodes[1].config.colour = G.C.BLACK
    return t
end

local last_collection_pool = SMODS.collection_pool

SMODS.increase_object_value = function(object, operation, val, include, exclude)
    include = include or {}
    exclude = exclude or {}
    local function can_pass(i)
        if exclude["all"] and include[i] then
            return true
        end
        if exclude[i] then
            return false
        end
        return true
    end
    local extra = object.ability.extra
    local allowed = {}
    local extra_is_nil = false
    if extra == nil or type(extra) == "number" then
        extra_is_nil = true
        local key = object.config.center_key
        local center = G.P_CENTERS[key]
        if center.config.extra and type(center.config.extra) == "table" then
            for i,v in pairs(center.config.extra) do
                allowed[i] = true
            end
        else
            for i,v in pairs(center.config) do
                allowed[i] = true
            end
        end
    end
    local function multiply(i)
    extra[i]=extra[i]*val
    end
    local function sub(i)
    extra[i]=extra[i]-val
    end
    local function add(i)
    extra[i]=extra[i]+val
    end
    local function pow(i)
    extra[i]=extra[i]^val
    end
    local function rad(i)
    extra[i]=math.rad(val)
    end
    local function div(i)
        extra[i]=extra[i]/val
    end
    if extra_is_nil then extra = object.ability end
    for i,v in pairs(extra) do
        if type(v) == "number" or is_number(v) then
            if extra_is_nil == true and allowed[i] == true or not extra_is_nil then
            if can_pass(i) then
            if operation == "*" then multiply(i) end
            if operation == "-" then sub(i) end
            if operation == "+" then add(i) end
            if operation == "^" then pow(i) end
            if operation == "rad" then rad(i) end
            if operation == "div" then div(i) end

                end
            end
        end
    end
end


SMODS.get_color_from_string = function(str, loc_vars)
    local strings = {}
    local colors = {}
    local background_colours = {}
    local full_string = ""

    local current_color = nil
    local current_bg = nil
    local pos = 1

    -- Step 1: Replace #n# with values from loc_vars.vars
    if loc_vars and loc_vars.vars then
        str = str:gsub("#(%d+)#", function(n)
            local val = loc_vars.vars[tonumber(n)]
            return val and tostring(val) or ""
        end)
    end

    -- Step 2: Parse tags
    while pos <= #str do
        local start_tag, end_tag, tag_content = str:find("{([^}]+)}", pos)

        if start_tag then
            -- Text before the tag
            if start_tag > pos then
                local text = str:sub(pos, start_tag - 1)
                table.insert(strings, text)
                table.insert(colors, current_color)
                table.insert(background_colours, current_bg)
                full_string = full_string .. text
            end

            -- Process tag content (e.g., "X:white,V:2")
            for entry in tag_content:gmatch("[^,%s]+") do
                local prefix, value = entry:match("([CVX]):(%w+)")
                if prefix == "C" then
                    current_color = G.C[value:upper()]
                elseif prefix == "V" and loc_vars and loc_vars.vars and loc_vars.vars.colours then
                    current_color = loc_vars.vars.colours[tonumber(value)]
                elseif prefix == "X" then
                    current_bg = G.C[value:upper()]
                end
            end

            pos = end_tag + 1
        else
            -- Remaining text
            local text = str:sub(pos)
            table.insert(strings, text)
            table.insert(colors, current_color)
            table.insert(background_colours, current_bg)
            full_string = full_string .. text
            break
        end
    end

    return strings, colors, background_colours, full_string
end

function SMODS.copy_to_clipboard(text)
    love.system.setClipboardText(text)
end

function SMODS.get_clipboard()
return love.system.getClipboardText()
end

G.FUNCS.your_collection_recipe_books = function()
    G.SETTINGS.paused = true
    G.FUNCS.overlay_menu{
        definition = SMODS.card_collection_UIBox(G.P_CENTER_POOLS["recipes"], {5,5}, {
        snap_back = true,
        hide_single_page = true,
        collapse_single_page = true,
        center = 'c_base',
        h_mod = 1.03,
        back_func = 'your_collection_other_gameobjects',
        modify_card = function(card, center)
            card.ignore_pinned = true
            print(center.key)
            card.set = "Default"
            card.ability = {}
            card.discovered = center.discovered
            card.config.center = table.clone(center)
            card.config.center.set = "Default"
            local ingredient_text = {
                
            }
            local result_text = {

            }
            local card_input = card.config.center.input
            local card_result = card.config.center.result
            if type(card_input) == "function" then card_input=card_input(card, card.config.center) end
            if type(card_result) == "function" then card_result=card_result(card, card.config.center) end
            local function insert_recipe_text(t, t_to_insert)
                local key = t.key
                local this_input = nil
                print(key)
                local target_obj = G.P_CENTERS[key]
                if target_obj == nil then return end
                print(target_obj)
                local name = target_obj.name
                local names_colour = {}
                local loc_vars = target_obj.loc_vars
                local this_center = {
                    ability = {
                        extra = target_obj.config
                    }
                }
                print("obj config:",target_obj)
                if loc_vars ~= nil then loc_vars=loc_vars(target_obj.config.center, {}, this_center) end
                if target_obj.loc_txt then
                    if target_obj.loc_txt["default"].name then
                        name = target_obj.loc_txt["default"].name
                    end
                end
                if localize(name, "other") ~= "ERROR" then name=localize(name,"other") end
                local names,names_colour,background_colours,full_name=SMODS.get_color_from_string(name,loc_vars)
                this_input=name
                --[[print("obj names:",names)
                for i = 1,#names do
                    local this_input = names[i]
                    local this_colour = names_colour[i]
                    table.insert(ingredient_text, {
                        text = this_input,
                        colour= this_colour,
                        scale = 0.32,
                    })
                end]]
                if #names_colour >1 then
                    print("full name:",full_name)
                    table.insert(t_to_insert, {
                        text=names,
                        colour=names_colour,
                        scale = 0.32,
                        dyna_text = true,
                    })
                else
                    table.insert(t_to_insert, {
                        text=full_name,
                        colour=names_colour[1] or G.C.BLACK,
                        scale = 0.32,
                    })
                end
            end
            for i,v in pairs(card_input) do--gets ingredients names
                insert_recipe_text(v, ingredient_text)
            end
            local found_atlas = nil
            for i,v in pairs(card_result) do--gets results
                if found_atlas == nil and card.discovered == true then
                    local key = v.key
                    local target_obj = G.P_CENTERS[key] or {}
                    print("obj:",target_obj)
                    if target_obj.atlas then
                    print("found atlas!")
                    card.config.center.atlas = target_obj.atlas
                    card:set_sprites(target_obj)
                    found_atlas = true
                    end
                end
                insert_recipe_text(v, result_text)
            end
            local ingredients = {
                name = localize("k_bl_utilities_ingredients"),
                set_name=true,
                set_text = true,
                set_info_bg = true,
                info_bg = G.C.BLACK,
                text = ingredient_text,
            }
            local result = {
                name = localize("k_bl_utilities_result"),
                set_name = true,
                set_text = true,
                set_info_bg = true,
                info_bg = G.C.BLACK,
                text=result_text,
            }
            card.config.center.custom_info_queue = {
                ingredients,
                result,
            }
            local card_name = card.config.center.name
            if card.config.center.loc_txt then
                if card.config.center.loc_txt["default"] then
                    card_name = card.config.center.loc_txt["default"].name
                end
            end
            if type(card_name) == "function" then card_name=card_name(card, card.config.center) end
            if localize(card_name, "other") ~= "ERROR" then card_name=localize(card_name,"other") end
            card.config.center.custom_desc = {
                {
                desc=localize("k_recipe_name")..":"..card_name,
                colour=G.C.BLACK,
                scale=0.26,
                }
            }
            --[[function card:generate_UIBox_ability_table(vars_only)
                local hide_desc = false
                local main_start = nil
                local main_end = nil
                local card_type = self.set or "Default"
                local name = self.card_name or {
                    {
                    text = card.config.center.name,colour=card.config.center.colour,    
                    }
                }
                local desc = self.card_desc or {
                    {
                    text = {card.config.center.name},colour={G.C.RED},pop_in_rate = card.config.center.pop_in_rate or 999999999999999, silent = card.config.center.silent or true, random_element = card.config.center.random_element or false, pop_delay = card.config.center.pop_delay or 0.5, scale = card.config.center.scale or 0.32, min_cycle_time = card.config.center.min_cycle_time or 0,
                    },
                }
                local this_name = {
                    {n=G.UIT.T, config={text = '  +',colour = G.C.MULT, scale = 0.32}},
                }
                local this_name = {}
                local this_info = self.card_info or {
                    {
                    name = "Name:",
                    },
                    {
                    name = "Ingredients:",
                    },
                    {
                    name = "Results:",
                    },
                }
                local r_info = {}
                for i,v in ipairs(this_info) do
                    if i >1 then
                        table.insert(r_info, v)
                    end
                end
                main = {
                {n=G.UIT.T, config={text = '  +',colour = G.C.MULT, scale = 0.32}},
                {n=G.UIT.O, config={object = DynaText({string = {"t","d"}, colours = {G.C.RED},pop_in_rate = 9999999, silent = true, random_element = true, pop_delay = 0.5, scale = 0.32, min_cycle_time = 0})}}
                }
                main_start = {}
                local name_nodes = {}
                for i,v in pairs(name) do
                    local base_node = {
                    n=G.UIT.T,config={text=v.text or " error?",colour=v.colour or G.C.MULT,scale=v.scale or 0.32}
                    }
                    table.insert(name_nodes, base_node)
                end
                for x,l in pairs(name_nodes) do
                    print("adding name:",l)
                    table.insert(this_name, l)
                end
                local desc_nodes = {}
                for i,v in pairs(desc) do
                    local base_node = {
                        n=G.UIT.O,config={object = DynaText({string = v.text or {"error??"}, colours = v.colour or {G.C.RED},pop_in_rate=v.pop_in_rate or 999999999,silent=v.silent or false,random_element=v.random_element or false,pop_delay=v.pop_delay or 0.5,scale=v.scale or 0.32,min_cycle_time=v.min_cycle_time or 0}),}
                    }
                    table.insert(desc_nodes, base_node)
                end
                for x,l in pairs(desc_nodes) do
                    print("adding desc:",l)
                    table.insert(main_start, l)
                end
                print(this_name)
                local generated = generate_card_ui(self.config.center, {name = this_name,info=r_info,main={}}, {}, card_type, {}, hide_desc, main_start, main_end, self)
                generated.card_type = card_type
                generated.badges = self.badges or {}

                generated.box_colours = self.info_box_colours or {
                    G.C.RED
                }
                generated.main.background_colour = self.main_background_colour or G.C.BLACK
                local base_info = {n=G.UIT.C,config={text = "test??",colour=G.C.RED,scale=0.32,},}
                print("length:",#generated.info)
                print(generated.info[#generated.info][1][1].config.object)
                --generated.info[#generated.info][1][1].config.object = DynaText({string = {"a"}, colours = {G.C.RED},pop_in_rate = 99999999999, silent = false, random_element=false,pop_delay=0.5,scale=0.32,min_cycle_time=0,})
                print(generated.info[1][1])
                local desc_nodes = generated.info[1]
                
                generated.info[#generated.info].name = this_info[1].name
                --generated.main = generated.info[1]
                --generated.info[1] = nil
                --[[print("info:",generated.info[1][1][1].config.object.original_T)
                generated.info[1][1][1].config.object.original_T.w = 0
                --[[print("info:",generated.info)
                print(generated.info[1].config.text)
                
                for x,l in pairs(generated.info[1][1][1].config.object) do
                    print("key:",x," val:",l)
                end]]
                --[[local my_menu = UIBox({
                    definition = {
                        {n=G.UIT.R,config={text = " +",colour=G.C.RED,scale=0.32,identifier=2,},}
                    },
                    config = {
                        type = "cm",
                        colour = G.C.RED,
                        identifier = 0,
                    }
                })
                local generated = {
                    {n=G.UIT.O, config={object = my_menu,colour=G.C.BLUE,identifier=1,},},
                    card_type = "Default",
                    badges = {},
                    main = {},
                    info = {
                        colour = G.C.RED,
                    },
                }
                local prohibited = {

                }
                local last_draw_self = UIElement.draw_self
                function UIElement:draw_self()
                    print("element:",self)
                    print('identifier:',self.config.identifier)
                    print("colour:",self.config.colour)
                    last_draw_self(self)
                end
                generated = create_UIBox_game_over()
                generated.card_type = "Joker"
                generated.badges = {}
                generated.main = {}
                generated.info = {}
                return generated
            end]]
        end,
    })
    }
end

SMODS.create_custom_card = function(X,Y,W,H,center,params, extra)
    local custom_card = Card(X,Y,W,H,center,params)
    --[[example custom_info_queue:
            {
                {
                name = localize("k_bl_utilities_ingredients"),
                set_name=true,
                set_text = true,
                set_info_bg = true,
                info_bg = G.C.BLACK,
                text = ingredient_text,
                }
            }
    ]]
    --[[example custom_desc:
       {
          {
            desc=localize("k_recipe_name")..":"..card_name,
            colour=G.C.BLACK,
            scale=0.26,
          }
       }
    ]]
    local this_center = extra.center or {}
    if type(this_center) == "function" then this_center = this_center(custom_card) end
    if custom_card.config.center == nil then
        if extra.center and type(extra.center) == "table" then
            this_center = table.clone(this_center)
        end
        custom_card.config.center = this_center
    end
    custom_card.config.center.custom_desc = extra.custom_desc or {}
    custom_card.config.center.custom_info_queue = extra.custom_info_queue or {}
    
    return custom_card
end


SMODS.modify_function = function(f, ifstatement, pattern, replace, add_at_beginning)--Modifies target function by replacing code with a pattern and replace value.
    if type(pattern) ~= "table" and type(pattern) == "string" then pattern = {pattern} end
    if type(replace) ~= "table" and type(replace) == "string" then replace = {replace} end
    if type(pattern) ~= "table" then pattern = {} end
    if type(replace) ~= "table" then replace = {} end
    local default_functions = {
        ["checkPattern"] = function(function_source, pattern, replace, add_at_beginning)
            for i,v in ipairs(pattern) do
                local current_replace = replace[i]
                if current_replace == nil then break end
                print("pattern:",pattern[i])
                print("replace:",current_replace)
                local function_replace = function_source:gsub(pattern[i], current_replace)
                if function_replace ~= function_source then
                    print("replace made!")
                    return true
                end
            end
            return false
        end
    }
    if type(ifstatement) ~= "function" and type(ifstatement) == "string" then
        if default_functions[ifstatement] ~= nil then
            ifstatement = default_functions[ifstatement]
        end
    end
    if type(ifstatement) ~= "function" and type(ifstatement) == "table" and getmetatable(ifstatement) ~= nil and getmetatable(ifstatement.__call) ~= nil or type(ifstatement) ~= "function"  and type(ifstatement) == "table" and getmetatable(ifstatement) == nil or type(ifstatement) ~= "function" and type(ifstatement) == "table" and getmetatable(ifstatement) ~= nil and getmetatable(ifstatement).__call == nil then
        ifstatement = function(function_source, pattern, replace, add_at_beginning)
            return true
        end
    end
    local function_source,function_variables,func_object = SMODS.read_function_as_string(f)
    if ifstatement(function_source, pattern, replace, add_at_beginning) == true then
        if add_at_beginning ~= nil then
            for i,v in ipairs(add_at_beginning) do
                function_source = v.."\n"..function_source
            end
        end
        for i,v in ipairs(pattern) do
            local current_replace = replace[i]
            print("current replace:",current_replace," current pattern:",pattern[i])
            if current_replace == nil then break end
            function_source=function_source:gsub(pattern[i], current_replace)
        end
        return SMODS.SourcedFunction{
            source_code = function_source,
            variables = function_variables,
        }
    end
    return false
end

local last_copy_card = copy_card
copy_card = function(other, new_card, card_scale, playing_card, strip_edition)
    local copied_card = last_copy_card(other, new_card, card_scale, playing_card, strip_edition)
    if other.config.original_center ~= nil then
    copied_card.config.center = table.clone(other.config.original_center)
    copied_card.config.center.calculate = other.config.calculate
    end
    return copied_card
end
local calculate_joker_mod = "local obj=self.config.center\n"..[[if self.ability.set ~= "Enchanced" and obj.calculate and type(obj.calculate) == "function" or self.ability.set ~= "Enchanced" and obj.calculate and type(obj.calculate) == "table" then local o,t = obj.calculate(self,context) if o or t then return o,t end end]]
--[[SMODS.read_function_as_string(function()
    print("this prints hello world")
    local function haha()
        print("saying haha!!")
    end
end)]]

function SMODS.Extender:Extend(object, funcName, newFunc, pre)--Extends a targeted object function.
--print("extending!")
local previous_func = object[funcName]
local thisFunc = newFunc
if pre == true then
if thisFunc == nil then error("hook is nil") end
if thisFunc ~= nil then
object[funcName] = function(self,...)
local variables = {self,...}
--print("printing variables:",unpack(variables))
local result = thisFunc(unpack(variables))
--print("result:",unpack(result))
if previous_func ~= nil then
--print('it is not nil!')
return previous_func(unpack(result))
end    
end
    end
end
if pre ~= true then
    if thisFunc ~= nil then
    local previous_func = object[funcName]
    object[funcName] = function(self,...)
    local variables = {self,...}
    local previous_func_result = nil
    if previous_func ~= nil then
    pcall(function()
    previous_func_result = previous_func(unpack(variables))
    end)
    end
    pcall(function()
    thisFunc(unpack(variables))
    end)
    if previous_func_result ~= nil then return previous_func_result end
    end
end
end

end
load_classes()
local last_generate_card_ui=generate_card_ui
generate_card_ui = function(_c, full_UI_table, specific_vars, card_type, badges, hide_desc, main_start, main_end, card)
    full_UI_table=last_generate_card_ui(_c,full_UI_table,specific_vars,card_type,badges,hide_desc,main_start,main_end,card)
    local o_len = #full_UI_table.info
    if _c.custom_info_queue then
        for i,v in pairs(_c.custom_info_queue) do
            local generated = generate_card_ui(v, full_UI_table)
            print("generated:",generated)
            if generated.info[i][1] then
                print(generated.info[i][1])
                print(generated.info[i][1][1])
            end
            if v.set_name == true then
                print(v)
                print("setting name!")
                generated.info[i+o_len].name = v.name
            end
            if v.set_text == true then
                --[[print("printing table zero:",generated.info[1][1])
                generated.info[i][1] = generated.info[1][1]
                local this_table = generated.info[i][1]
                print("should be printing")
                print("printing table:",this_table)
                print("node:",this_table[1].n)]]
                for x,l in pairs(v.text) do
                    local text_colour = l.colour
                    local text_scale = l.scale
                    local text = l.text
                    print(x)
                    if l.dyna_text ~= true then
                    generated.info[i][x] = {
                        {n=G.UIT.T,config={text=text,colour=text_colour,scale=text_scale,}}
                    }
                    else
                        if type(text) ~= "table" then text = {text} end
                        if type(text_colour[1]) == "number" then
                            text_colour = {text_colour}
                        end
                        --[[generated.info[i][x] = {
                            {n=G.UIT.O,config={object=DynaText(this_config)}}
                        }]]
                        local main_obj = {
                            
                        }
                        local last_text_colour
                        for i = 1,#text do
                            local this_text = text[i]
                            local this_text_colour = text_colour[i]
                            local this_config = {
                            string = {this_text},
                            colours = {this_text_colour},
                            pop_in_rate = l.pop_in_rate or 1e20,
                            silent = l.silent or false,
                            random_element = l.random_element or false,
                            pop_delay = l.pop_delay or 0.5,
                            scale = text_scale,
                            min_cycle_time = l.min_cycle_time or 0,
                            }
                            local this_obj = {
                                n=G.UIT.O,config={object=DynaText(this_config)}
                            }
                            table.insert(main_obj,this_obj)
                            last_text_colour = this_text_colour
                        end
                        print("setting dyna text obj")
                        generated.info[i][x] = main_obj
                    end
                    print(generated.info[i][x])
                end 
                --[[generated.info[i][1] = {
                    {n=1,text="???",config={text="???",colour=G.C.RED,scale=0.32,},}
                }
                ]]
            end
            if v.set_info_bg == true then
                generated.info[i].background_colour = v.info_bg
            end
            if v.set_main_bg == true then
                generated.info[i].background_colour = v.main_bg
            end
        end
    end
    if _c.custom_desc then
        print(_c.custom_desc)
        for i,v in pairs(_c.custom_desc) do
            local desc = v.desc
            local colour = v.colour
            local scale = v.scale
            if full_UI_table.main[i] == nil then
                full_UI_table.main[i] = {
                    {n=G.UIT.T,config={text=desc,colour=colour,scale=scale,},}
                }
            end
        end
    end
    return full_UI_table
end
if Talisman then
    local f = SMODS.load_file("Card.lua")
    local func_code,func_variables = SMODS.read_function_as_string(f)
    --func_code="local talisman_calculate = Card.talisman_calculate\n if talisman_calculate then return talisman_calculate(self,context) end"..func_code
    Card.talisman_calculate = Card.calculate_joker
    Card.vanilla_calculate_joker = SMODS.SourcedFunction{
            source_code = func_code,
            variables = func_variables,
    }:get()
end
--Card.calculate_joker = SMODS.modify_function(Card.calculate_joker, "checkPattern", {string.escape_g_sub_pattern([[if self.ability.set ~= "Enhanced" and obj.calculate and type(obj.calculate) == 'function' then]])}, {[[if self.ability.set ~= "Enhanced" and obj.calculate and type(obj.calculate) == 'function' or self.ability.set ~= "Enchanced" and obj.calculate and type(obj.calculate) == "table" then]]},{'print("calculating joker:",self.ability.name)'}):get()
if not Talisman then 
Card.vanilla_calculate_joker = Card.calculate_joker
end
local last_add_to_deck = Card.add_to_deck
local last_remove = Card.remove
local last_start_dissolve = Card.start_dissolve

SMODS.make_card_unique = function(card)
local prohibited_sets = {
    ["Default"] = true,
    ["Enchanced"] = true,
}
local prohibited_areas = {
    [G.hand] = true,
    [G.play] = true,
}
    print(card.ability.set)
    if card.area ~= nil then
        print("has area!")
    end
    local original_center = card.config.center
    if type(card.config.center) == "table" and not prohibited_sets[card.ability.set] == true and card.config.center.j_unique ~= true and prohibited_areas[card.area] ~= true and card.area ~= nil then
        print("going to clone center!")
        card.config.original_center = original_center
        card.config.center = table.clone(card.config.center)
        card.config.center.j_unique = true
        print("cloned center!")
    end
    return true
end
print("reading calculate edition!")
SMODS.read_function_as_string(Card.calculate_edition)
local function remove_unique_card(card)
if card == nil then return end
local prohibited_sets = {
    ["Default"] = true,
}
if card.config.center and card.config.center.j_unique then
    if card.config.center.calculate then
        SMODS.SourcedFunction:remove_func_source(card.config.center.calculate)
    end
    table.clear(card.config.center)
    card.config.center = nil
end
end

function Card:add_to_deck(from_debuff)
    last_add_to_deck(self, from_debuff)
    --print("added card to deck!")
    --SMODS.make_card_unique(self)
end

function Card:remove()
last_remove(self)
remove_unique_card(self)
end

function Card:start_dissolve(dissolve_colours, silent, dissolve_time_fac, no_juice)
    last_start_dissolve(self, dissolve_colours, silent, dissolve_time_fac, no_juice)
    local this_delay = dissolve_time_fac or 0
    G.E_MANAGER:add_event(Event{
        delay=this_delay+0.05,
        func = function()
            remove_unique_card(self)
            return true
        end,
        blocking = false,
        trigger="after",
    })
end

local last_emplace = CardArea.emplace
--local last_remove_card = CardArea.remove_card
function CardArea:emplace(card, location, stay_flipped)
--print("card emplaced!")
print(card.config.center.key,":",card.config.center)
--if card.config.center then print(card.config.center.label) end
last_emplace(self, card, location, stay_flipped)
local allowed_areas = {

}
if G.jokers ~= nil then
    allowed_areas[G.jokers] = true
end
if G.consumeables ~= nil then
    allowed_areas[G.consumeables] = true
end
if card.area ~= nil and allowed_areas[card.area] ~= nil then
--SMODS.make_card_unique(card)
end

end

local last_delete_run = Game.delete_run
function Game:delete_run(...)
print("removing unique cards")
if self.jokers and self.jokers.cards then
for i = 1,#self.jokers.cards do
    remove_unique_card(self.jokers.cards[i])
end

end

if self.consumeables and self.consumeables.cards then
for i = 1,#self.consumeables.cards do
    remove_unique_card(self.consumeables.cards[i])
end

end
last_delete_run(self,...)
end

local consumeable_context = SMODS.contexts{
    name = "BalatroUtilities_before_using_consumeable",
    key = "BalatroUtilities_before_using_consumeable",
    hooks = {
    {
    target = Card,
    hook_target_func = "use_consumeable",
    pre = true,
    hook = function(self,area,copier)
        if self.debuff then return {self,area,copier} end
        print(self.ability.name)
        local this_context = {
            consumeable = self,
            area = area,
            cardarea = "this_card_area",
            before_using_consumeable = true,
            highlighted_hand = G.hand.highlighted,
            highlighted_jokers = G.jokers.highlighted,
            highlighted_consumeables = G.consumeables.highlighted,
        }
        SMODS.calculate_context(this_context)
        return {self,area,copier}
    end,
    },

    },
}
SMODS.Joker.GetJokerType = function(joker)
    if joker.config.center ~= nil then
    local config = joker.config.center.config
    if config == nil then joker.config.center.config = {} config = joker.config.center.config end
    local joker_type = config.joker_type or config.joker_types or config.types or config.type
    if joker_type == nil then config.joker_type = {} joker_type = config.joker_type end
    if type(joker_type) ~= "table" then joker_type={joker_type} end
    return joker_type
    end
    if joker.config.center == nil then
        local config = joker.config
        local joker_type = config.joker_type or config.joker_types or config.types or config.type
        if joker_type == nil then joker.config.joker_type = {} joker_type = config.joker_type end
        if type(joker_type) ~= "table" then joker_type={joker_type} end
        return joker_type
    end
end
function SMODS.Joker:IsJokerType(joker, target_joker_type)
local joker_type = self.GetJokerType(joker)
if type(joker_type) ~= "table" then joker_type={joker_type} end
for i,v in ipairs(joker_type) do
    if v == target_joker_type then return true end
end
return false
end

function SMODS:IsCardType(target_card, target)
if SMODS.Joker:IsJokerType(target_card, target) or SMODS.Consumable:IsConsumableType(target_card, target) then
    return true
end
return false
end

SMODS.Consumable.GetConsumableType = function(cons)
    if cons.config.center ~= nil then
        local config = cons.config.center.config
        if config == nil then cons.config.center.config = {} config = cons.config.center.config end
        local cons_type = config.consumable_type or config.consumable_types or config.types or config.types
        if cons_type == nil then config.consumable_type = {} cons_type = config.consumable_type end
        if type(cons_type) ~= "table" then cons_type={cons_type} end
        return cons_type
    end
    if cons.config.center == nil then
        local config = cons.config
        local cons_type = config.consumable_type or config.consumable_types or config.types or config.types
        if cons_type == nil then config.consumable_type = {} cons_type = config.consumable_type end
        if type(cons_type) ~= "table" then cons_type={cons_type} end
        return cons_type
    end
end

function SMODS.Consumable:IsConsumableType(consumable, target_consumable_type)
local consumable_type = self.GetConsumableType(consumable)
if type(consumable_type) ~= "table" then consumable_type={consumable_type} end
for i,v in ipairs(consumable_type) do
    print(v)
    if v == target_consumable_type then return true end
end
return false
end

function SMODS.GetWeightedElements(weighted_table,key,roll_amount)
    local elements = {}
    for i = 1, roll_amount do
    local total_weight = 0
    key=key or "default_weighted_element_key"
    for i,v in ipairs(weighted_table) do
        total_weight=total_weight+v.weight
    end
    local chosen_number = pseudorandom(key)*total_weight
    local current_weight = 0
    for i,v in ipairs(weighted_table) do
        current_weight=current_weight+v.weight
        if chosen_number <= current_weight then
            table.insert(elements, v.item)
        end
    end
    end
    return elements
end

local last_start_run = Game.start_run
function Game:start_run(args)
local r = last_start_run(self, args)
--sets highlighted limit to very high amount for recipe compatibility
G.consumeables.config.highlighted_limit = 1e300
G.jokers.config.highlighted_limit = 1e300
return r
end

--[[SMODS.abilities = setmetatable(smods_abilities, {
    __call = function(t, param)
        print(param.name)
        print(t)
        local function ability_constructor(name, prefix, config, action)
        local ability = {
            name = name,
            prefix = prefix,
            config = config,
            input = nil,
            keybind = nil,
            input_type = nil,
            action = action,
            set = "BalatroUtilitiesAbility",
        }
        local function update_ability_input()
            sendInfoMessage("updating ability input!")
            ability.keybind = ability.input
            print("updated???")
        end
        function ability:BindInput(input)
            sendInfoMessage("bind input called")
            if type(input) == "table" and input.keys ~= nil then
                sendInfoMessage("binding input!")
                ability.input = input
                update_ability_input()
            end
        end
        if ability.config.input ~= nil then
            ability:BindInput(ability.config.input)
        end
        if ability.config.input_type ~= nil then
            ability.input_type = ability.config.input_type
        else
            ability.config.input_type = "pressed"
        end
        return ability
        end
        print("called one")
        local name = param.name
        local prefix = param.prefix
        local config = param.config
        local action = param.action
        local ability_name = "ability_"..prefix.."_"..name
        SMODS.abilities[ability_name] = ability_constructor(name, prefix, config, action)
        print("created ability:"..ability_name)
        return SMODS.abilities[ability_name]
    end
})]]

sendInfoMessage("initted balatro utilities!")
local time_erase = SMODS.abilities({
    name = "Time Erase",
    prefix = "balatro_utilities",
    calculate = function(self)
    sendInfoMessage("time erase!")
    end,
    config = {
    cooldown = 1,
    },
})
time_erase:BindInput({
    keys = {
        {
        key = "t",
        is_held = false,
        },
    },
})
local keys_pressed = {}
local prev_key_pressed = love.keypressed
function love.keypressed(key)
prev_key_pressed(key)
if keys_pressed[key] == nil then
keys_pressed[key] = os.time()
end
end
local prev_key_released = love.keyreleased
function love.keyreleased(key)
prev_key_released(key)
keys_pressed[key] = nil
for i,v in pairs(SMODS.abilities) do
    if type(v) ~= "table" then return end
    local keybind = v.keybind
    if type(keybind) == "table" then
    local keys = keybind.keys
    for x,l in pairs(keys) do
        local tkey = l.key
        local is_held = l.is_held
        if is_held == false and key == tkey then
            v.center:calculate(0)
        end
    end
    end
end
end
local prev_update = love.update
function love.update(dt)
    prev_update(dt)
    for i,v in pairs(SMODS.abilities) do
        if type(v) ~= "table" then return end
        local keybind = v.keybind
        if type(keybind) == "table" then
            local keys = keybind.keys
            for x,l in pairs(keys) do
                local key = l.key
                local held_duration = l.held_duration
                local current_key_duration = keys_pressed[key]
                local is_held = l.is_held
                if is_held then
                if current_key_duration == nil then current_key_duration = -1 else current_key_duration=os.time()-current_key_duration end
                if current_key_duration >=held_duration then
                    print("executing action!")
                    v.center:calculate(held_duration)
                   end
               end
            end
        end
    end
end