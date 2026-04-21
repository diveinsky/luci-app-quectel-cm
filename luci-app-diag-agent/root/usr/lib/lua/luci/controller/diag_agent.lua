module("luci.controller.diag_agent", package.seeall)

function index()
    entry({"admin", "system", "diag_agent"}, template("diag_agent/index"), translate("Diag Agent"), 70)
    entry({"admin", "system", "diag_agent", "status"}, call("action_status"))
        .leaf = true
end

function action_status()
    local http = require "luci.http"
    local sys = require "luci.sys"

    local output = sys.exec("/usr/bin/diagagent --all 2>/dev/null")
    http.prepare_content("application/json")
    http.write(output)
end
