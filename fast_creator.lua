concommand.Add("fast_creator", function(ply, cmd, args)
    local sCollection = tostring(args[1])
    print(not args[1] and "You must enter a collection ID (eg : fast_creator 1092793021)" or "Here is the addon list of the collection " .. sCollection .. " :")
    if not args[1] then return end
    print("Just copy this to lua/autorun/server/workshop.lua\n")

    steamworks.FileInfo(sCollection, function(tCollectionInfo)
        for k, v in ipairs(tCollectionInfo["children"]) do
            steamworks.FileInfo(v, function(tAddonInfo)
                print(string.format("resource.AddWorkshop('%s') // %s", v, tAddonInfo["title"]))
            end)
        end
    end)
end)

--[[ 
    Simple utility to make a greate workshop.lua file for a fast dl.
    -- Exemple : fast_creator <collectionID>
    -- Return : A prebuild workshop.lua (just copy the print in your F10 console)
]]
