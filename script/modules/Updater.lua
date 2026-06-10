--!strict

--[[
    MAKITO HUB - AUTO-UPDATE MODULE
    Real-time Script Updates & Version Management
    Maintainer: LuaMasterX (June 2026)
]]

local Updater = {}

local HttpService = game:GetService("HttpService")

local VERSION = "11.0.0"
local UPDATE_BASE_URL = "https://raw.githubusercontent.com/MakitoHub/BloxFruits/main" -- Placeholder
local LOCAL_VERSION_FILE = "makito_version.txt"

Updater.CurrentVersion = VERSION
Updater.UpdateAvailable = false
Updater.NewestVersion = VERSION

local function GetRemoteVersion()
    local success, result = pcall(function()
        return HttpService:GetAsync(UPDATE_BASE_URL .. "/version.json")
    end)
    
    if success then
        return HttpService:JSONDecode(result)
    end
    return nil
end

function Updater.CheckForUpdates()
    local remoteInfo = GetRemoteVersion()
    
    if remoteInfo and remoteInfo.version then
        Updater.NewestVersion = remoteInfo.version
        Updater.UpdateAvailable = (remoteInfo.version ~= Updater.CurrentVersion)
        
        print(string.format("Current: %s | Newest: %s", Updater.CurrentVersion, Updater.NewestVersion))
        return Updater.UpdateAvailable
    end
    
    return false
end

function Updater.GetChangelog()
    local remoteInfo = GetRemoteVersion()
    return remoteInfo and remoteInfo.changelog or "No changelog available"
end

function Updater.DownloadAndApplyUpdate(callback)
    task.spawn(function()
        local success, result = pcall(function()
            -- Download main.lua
            local mainContent = HttpService:GetAsync(UPDATE_BASE_URL .. "/main.lua")
            writefile("makito_main_temp.lua", mainContent)
            
            -- Download modules
            local modules = {"Settings", "Data", "Utils", "Combat", "Farming", "UI", "Security", "Loader", "Updater"}
            for _, name in ipairs(modules) do
                local modContent = HttpService:GetAsync(UPDATE_BASE_URL .. "/modules/" .. name .. ".lua")
                writefile("makito_modules_temp/" .. name .. ".lua", modContent)
            end
            
            return true
        end)
        
        if success then
            -- Replace files and rejoin
            callback(true, "Update downloaded successfully")
        else
            callback(false, "Failed to download update")
        end
    end)
end

function Updater.Initialize()
    print("📡 Auto-Update Module Initialized (v" .. VERSION .. ")")
    
    -- Check for updates on load
    if Updater.CheckForUpdates() then
        warn("⚠️ Update available: " .. Updater.NewestVersion)
    else
        print("✅ MAKITO HUB is up to date")
    end
end

return Updater
