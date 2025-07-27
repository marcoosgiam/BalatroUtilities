local AI = Object:extend()
local https = require "SMODS.https"
local json = require "json"

function AI:init(ai_table)
if G.P_CENTER_POOLS["AI"] == nil then
    G.P_CENTER_POOLS["AI"] = {}
end
self.options = {
    messages = ai_table.messages or {},
    model = ai_table.model or "deepseek-r1-distill-llama-70b",
    frequency_penalty = ai_table.frequency_penalty or nil,
    response_format = ai_table.response_format or nil,
    seed = ai_table.seed or nil,
    temperature = ai_table.temperature or 1,
    system_message = ai_table.system_message or "",
    api_key = ai_table.api_key or "",
    optional_prompts = ai_table.optional_prompts or {},
}
self.key = ai_table.key
G.P_CENTER_POOLS["AI"][self.key] = self
end

function AI:GetSystemMessage(optional_prompts)
print(optional_prompts)
local sys_msg = self.options.system_message
optional_prompts = optional_prompts or {}
for i,v in pairs(self.options.optional_prompts) do
    print("index:",i)
    if optional_prompts[i] ~= true then
        print("yep it is not true?")
        print("message is:",v)
        if sys_msg:gsub(v, "") ~= sys_msg then
            print("economizing lol")
        end
        sys_msg=sys_msg:gsub(v, "")
    end
end
return sys_msg
end

function AI:GetResponse(key, input, cb, optional_prompts, extra)
key = key or self.options.api_key
extra = extra or {}
if type(key) == "function" then key = key() end
print("getting AI response with key:",key)
local url = "https://api.groq.com/openai/v1/chat/completions"
local data = {
    messages = self.options.messages,
    model = self.options.model,
    frequency_penalty = self.options.frequency_penalty,
    response_format = self.options.response_format,
    seed = self.options.seed,
    temperature = self.options.temperature or 1,
    system_message = self:GetSystemMessage(optional_prompts),
}
if extra.temperature then
    data.temperature = extra.temperature
end
if extra.seed then
    data.seed = extra.seed
end
local headers = {
    ["Authorization"] = "Bearer " .. key
}
print(headers["Authorization"])
--headers=json:encode(headers)
if data.response_format ~= nil and data.response_format == "json" then
    data.response_format = {
        type="json_object",
    }
end
local bodyRequest = {
    url = url,
    options = {
        method = "POST",
        headers = headers,
        data = {
            messages = {
                {
                role = "system",
                content = data.system_message,
                },
                {
                role = "user",
                content = input,
                },
            },
            model = data.model,
            response_format = data.response_format,
            seed = data.seed,
            temperature = data.temperature,
        },
    },
}
bodyRequest.options.data = json.encode(bodyRequest.options.data)
self.waiting_for_response = true
local response
self.body_coroutine = coroutine.running()
--[[local success, err = pcall(function()
local function get_body(code,body,headers)
    response=body
    print("body:",body)
    print("code:",code)
    coroutine.resume(self.body_coroutine)
end
https.asyncRequest(url, bodyRequest.options, get_body)
end)
coroutine.yield()]]
local code,body,headers = https.request(url, bodyRequest.options)
response=body
local success = false
if code == 200 then
    success = true
end
--print("success:",success)
print("ai response:",response)
if success then
print("returning:",json.decode(response))
if cb ~= nil and type(cb) == "function" then
    cb(json.decode(response))
end
return json.decode(response)
end

end
SMODS.AI = AI