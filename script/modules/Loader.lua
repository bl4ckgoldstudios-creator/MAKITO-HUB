local LoaderModule = {}
LoaderModule.GITHUB_BASE = "https://raw.githubusercontent.com/bl4ckgoldstudios-creator/MAKITO-HUB/refs/heads/main/script/modules/"
function LoaderModule.GetCapabilities()
    local caps = {
        loadstring = loadstring ~= nil,
        readfile = isfile ~= nil and readfile ~= nil,
        writefile = writefile ~= nil,
        listfiles = listfiles ~= nil,
        httpget = pcall(function() return game.HttpGet end) and game.HttpGet ~= nil,
        makefolder = makefolder ~= nil,
    }
    if identifyexecutor then
        local ok, name = pcall(identifyexecutor)
        caps.executor = ok and name or "Unknown"
    else
        caps.executor = "Unknown"
    end
    return caps
end
function LoaderModule.GetSearchPaths(name)
    local folder = (getgenv and getgenv().MAKITO_SCRIPT_FOLDER) or "script"
    return {
        "modules/" .. name .. ".lua",
        "./modules/" .. name .. ".lua",
        folder .. "/modules/" .. name .. ".lua",
        "script/modules/" .. name .. ".lua",
        "workspace/script/modules/" .. name .. ".lua",
        "workspace/modules/" .. name .. ".lua",
        "MakitoHub/modules/" .. name .. ".lua",
        name .. ".lua",
    }
end
function LoaderModule.TryLoadCode(code, sourceName)
    if not code or code == "" then
        return nil, "Codigo vazio"
    end
    if not loadstring then
        return nil, "loadstring indisponivel"
    end
    local fn, syntaxErr = loadstring(code, "Makito_" .. (sourceName or "Module"))
    if not fn then
        return nil, "Sintaxe: " .. tostring(syntaxErr)
    end
    local ok, result = pcall(fn)
    if not ok then
        return nil, "Runtime: " .. tostring(result)
    end
    if type(result) ~= "table" then
        return nil, "Modulo nao retornou uma tabela"
    end
    return result
end
function LoaderModule.Load(name, report)
    report = report or {}
    report[name] = report[name] or { attempts = {}, success = false, source = nil, error = nil }
    local function logAttempt(source, ok, detail)
        table.insert(report[name].attempts, {
            source = source,
            ok = ok,
            detail = detail or "",
            time = os.date("%X"),
        })
    end
    for _, path in ipairs(LoaderModule.GetSearchPaths(name)) do
        local exists = false
        pcall(function()
            if isfile and isfile(path) then
                exists = true
            end
        end)
        if exists then
            local readOk, content = pcall(readfile, path)
            if readOk and content then
                local module, err = LoaderModule.TryLoadCode(content, path)
                if module then
                    logAttempt(path, true, "OK")
                    report[name].success = true
                    report[name].source = path
                    return module, report
                end
                logAttempt(path, false, err)
                report[name].error = err
            else
                logAttempt(path, false, "Falha ao ler arquivo")
            end
        end
    end
    local url = LoaderModule.GITHUB_BASE .. name .. ".lua"
    local httpOk, content = pcall(function()
        return game:HttpGet(url)
    end)
    if httpOk and content and content ~= "" then
        local module, err = LoaderModule.TryLoadCode(content, "GitHub:" .. name)
        if module then
            logAttempt(url, true, "OK")
            report[name].success = true
            report[name].source = url
            return module, report
        end
        logAttempt(url, false, err)
        report[name].error = err
    else
        logAttempt(url, false, "HttpGet falhou ou retornou vazio")
        if not report[name].error then
            report[name].error = "Nenhum arquivo local encontrado e GitHub indisponivel"
        end
    end
    return nil, report
end
function LoaderModule.DiscoverWorkspaceFiles()
    local found = {}
    if not listfiles then
        return found
    end
    local roots = { "script", "workspace/script", "workspace", "MakitoHub" }
    for _, root in ipairs(roots) do
        pcall(function()
            if not isfolder or not isfolder(root) then return end
            for _, file in ipairs(listfiles(root)) do
                table.insert(found, root .. "/" .. file)
            end
            if isfolder(root .. "/modules") then
                for _, file in ipairs(listfiles(root .. "/modules")) do
                    table.insert(found, root .. "/modules/" .. file)
                end
            end
        end)
    end
    return found
end
function LoaderModule.FormatReport(report, caps, discovered)
    local lines = {
        "=== MAKITO HUB - DIAGNOSTICO ===",
        "Executor: " .. tostring(caps.executor),
        "loadstring: " .. tostring(caps.loadstring),
        "readfile: " .. tostring(caps.readfile),
        "writefile: " .. tostring(caps.writefile),
        "listfiles: " .. tostring(caps.listfiles),
        "HttpGet: " .. tostring(caps.httpget),
        "",
        "=== MODULOS ===",
    }
    for _, name in ipairs({ "Settings", "Data", "Utils", "Combat", "Farming", "UI", "Security", "Updater" }) do
        local info = report[name]
        if info then
            local status = info.success and "OK" or "FALHOU"
            lines[#lines + 1] = string.format("[%s] %s -> %s", status, name, tostring(info.source or info.error))
            for _, attempt in ipairs(info.attempts) do
                lines[#lines + 1] = string.format("  - %s (%s): %s", attempt.source, attempt.ok and "ok" or "erro", attempt.detail)
            end
        end
    end
    if discovered and #discovered > 0 then
        lines[#lines + 1] = ""
        lines[#lines + 1] = "=== ARQUIVOS ENCONTRADOS ==="
        for i = 1, math.min(#discovered, 20) do
            lines[#lines + 1] = "  " .. discovered[i]
        end
        if #discovered > 20 then
            lines[#lines + 1] = "  ... +" .. (#discovered - 20) .. " arquivos"
        end
    end
    return table.concat(lines, "\n")
end
return LoaderModule
