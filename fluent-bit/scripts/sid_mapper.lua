function cb_filter(tag, timestamp, record)
    local sid_map_file = "/fluent-bit/scripts/sid_map.lua"

    -- Lazy load the sid_map
    if not sid_map then
        local ok, result = pcall(dofile, sid_map_file)
        if ok and type(result) == "table" then
            sid_map = result
        else
            print("[sid_mapper] Failed to load sid_map")
            sid_map = {}
        end
    end

    -- Skip substitution if already known
    if record["created_by_name"] and record["created_by_name"] ~= "UNKNOWN" then
        return 1, timestamp, record
    end

    local created_by_id = record["created_by_id"]
    if created_by_id and type(created_by_id) == "table" then
        local uuid = created_by_id["uuid"]
        local object_type = created_by_id["objectType"]
        if object_type == "USER" and uuid then
            local mapped_name = sid_map[uuid]
            if mapped_name then
                record["created_by_name"] = mapped_name
            else
                record["created_by_name"] = "UNKNOWN"
            end
        else
            record["created_by_name"] = object_type or "UNKNOWN"
        end
    else
        record["created_by_name"] = "UNKNOWN"
    end

    return 1, timestamp, record
end