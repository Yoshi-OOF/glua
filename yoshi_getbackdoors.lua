-- Script pour vérifier si vous avez une backdoor
-- Placer le script dans un fichier lua/autorun/server/yoshiestbeau.lua
-- Éxécuter le script avec la commande "yoshi_getbackdoors" dans la console côté server
-- Si vous avez une backdoor et qu'il vous est impossible de l'enlever, bah tampis pour vous :)
local Danger = {
    ["RunString"] = 3,
    ["RunStringEx"] = 3,
    ["CompileString"] = 3,
    ["http"] = 3,
    ["SetUserGroup"] = 3
}

concommand.Add("yoshi_getbackdoors", function()
    -- détour de net.Receivers pour avoid les bugs de l'autorun
    local actualNetReceiver = net.Receivers
    local backdoorsResult = {}

    for netName, netFunc in pairs(actualNetReceiver) do
        for backdoorType, backdoorLevel in pairs(Danger) do
            for i = 0, 30 do
                local funcElement = jit.util.funck(netFunc, -i)

                if funcElement == backdoorType then
                    local src = debug.getinfo(netFunc)
                    if not src.short_src then table.insert(backdoorsResult, {["netName"] = netName,["netFile"] = src.short_src,["netFunc"] = "(Source Introuvable)"}) continue end
                    if not file.Exists(src.short_src, "GAME") then table.insert(backdoorsResult, {["netName"] = netName,["netFile"] = src.short_src,["netFunc"] = "(RunString)"}) continue end
                    local lines = string.Split(file.Read(src.short_src, "GAME"), "\n")
                    local recodedFunc = ""

                    for start, arg in pairs(lines) do
                        if (start >= src.linedefined) and (start <= src.lastlinedefined) then
                            recodedFunc = recodedFunc .. arg .. "\n"
                        end
                    end

                    table.insert(backdoorsResult, {
                        ["netName"] = netName,
                        ["netFile"] = src.short_src,
                        ["netFunc"] = recodedFunc
                    })
                end
            end
        end
    end

    if not table.IsEmpty(backdoorsResult) then
        MsgC(Color(255, 0, 0), "Backdoors trouvées: " .. tostring(table.Count(backdoorsResult)) .. "\n")

        for _, v in pairs(backdoorsResult) do
            MsgC(Color(255, 0, 0), "\nWARNING | ", Color(255, 125, 0), "Backdoor détectée : " .. v.netName .. " - " .. v.netFile .. "\n")
            MsgC(Color(255, 0, 0), "-- Début du code --\n")
            MsgC(Color(255, 0, 0), "\n" .. v.netFunc)
            MsgC(Color(255, 0, 0), "\n-- Fin du code --\n")
        end
    else
        MsgC(Color(0, 255, 8), "Aucune backdoor détectée\n")
        MsgC(Color(0, 255, 8), "c carré ma gueule\n")
    end
end)
