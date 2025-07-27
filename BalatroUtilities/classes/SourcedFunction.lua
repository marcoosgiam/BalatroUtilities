local SourcedFunction = Object:extend()

local functions_source = {}
local functions_variable = {}

function SourcedFunction:init(SourceFunction)
    self.source_code = SourceFunction.source_code
    self.variables = SourceFunction.variables
    local variables = ""
    for i,v in ipairs(SourceFunction.variables) do
        if i == #SourceFunction.variables then
            variables=variables..v
        else
            variables=variables..v..","
        end 
    end
    self.source_function = "return function("..variables..")"..self.source_code.." end"
    getmetatable(self).__call = function(...)
       print("Sourced Function called!")
       local variables = {...}
       print(#variables)
       print(self.source_function)
       local func_to_execute = loadstring(self.source_function)()
       func_to_execute(unpack(variables))
    end
end

function SourcedFunction:get()
if self.source_function ~= nil then
print("source function:",self.source_function)
local f = loadstring(self.source_function)()
functions_source[f] = self.source_code
functions_variable[f] = self.variables
return f
end
end

function SourcedFunction:get_func_source(f)
    if functions_source[f] ~= nil then
        return functions_source[f]
    end
    return nil
end

function SourcedFunction:get_func_variables(f)
    if functions_variable[f] ~= nil then
        return functions_variable[f]
    end
    return nil
end

function SourcedFunction:remove_func_source(f)
if functions_source[f] ~= nil then
functions_source[f] = nil
return true
end
return false
end

function SourcedFunction:change_variables(new_variables)
self.variables = new_variables
local variables = ""
for i,v in ipairs(self.variables) do
    if i == #self.variables then
        variables=variables..v
    else
        variables=variables..v..","
    end 
end
self.source_function = "return function("..variables..")"..self.source_code.." end"
end





SMODS.SourcedFunction = SourcedFunction