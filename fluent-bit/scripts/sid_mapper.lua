local sid_map = {}

-- Load the sid_map.json once at startup
local function load_sid_map()
    local file = io.open("/fluent-bit/sid_map.json", "r")
    if file then
        local content = file:read("*a")
        file:close()
        sid_map = cjson.decode(content)
    else
        print("[sid_mapper] Failed to open sid_map.json")
    end
end

-- Load once at startup
load_sid_map()

function sid_mapper(tag, timestamp, record)
    local id = record["created_by_id"]
    local typ = record["created_by_type"]

    if id and typ == "USER" and sid_map[id] then
        record["created_by_name"] = sid_map[id]
    end

    return 1, timestamp, record
end
