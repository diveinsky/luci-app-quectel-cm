module("rpcd.diagagent", package.seeall)

function index()
    local ubus = require "ubus"
    local cjson = require "cjson"

    local conn = ubus.connect()
    if not conn then
        return
    end

    local function status(args)
        local f = io.popen("/usr/bin/diag-agent --all 2>/dev/null", "r")
        if not f then
            return { error = "failed to execute diag-agent --all" }
        end

        local output = f:read("*a") or ""
        f:close()

        local success, parsed = pcall(cjson.decode, output)
        if not success then
            return {
                error = "failed to parse JSON output",
                detail = parsed,
                raw_report = output
            }
        end

        return parsed
    end

    conn:add({
        diagagent = {
            status = status
        }
    })
end
