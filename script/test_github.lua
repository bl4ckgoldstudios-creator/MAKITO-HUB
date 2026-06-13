--[[
    TESTE DE CONEXÃO COM O GITHUB
    Verifica se todos os arquivos estão acessíveis!
]]

local GITHUB_BASE = "https://raw.githubusercontent.com/bl4ckgoldstudios-creator/MAKITO-HUB/refs/heads/main/script"
local HttpService = game:GetService("HttpService")

print("🔍 TESTANDO CONEXÃO COM O GITHUB...")
print("URL Base:", GITHUB_BASE)
print("--------------------------------------------------")

local filesToCheck = {
    "main.lua",
    "github_loader.lua",
    "modules/Settings.lua",
    "modules/Data.lua",
    "modules/Utils.lua",
    "modules/Combat.lua",
    "modules/Farming.lua",
    "modules/UI.lua",
    "modules/Security.lua",
    "modules/Updater.lua",
    "modules/Loader.lua"
}

local available = {}
local missing = {}

for _, path in ipairs(filesToCheck) do
    local url = GITHUB_BASE .. "/" .. path
    local success, result = pcall(function()
        return HttpService:GetAsync(url, true)
    end)
    
    if success and result and #result > 0 then
        table.insert(available, path)
        print("✅ DISPONÍVEL: " .. path)
    else
        table.insert(missing, path)
        warn("❌ FALTANDO OU INACESSÍVEL: " .. path)
        if not success then
            warn("   Erro:", tostring(result))
        end
    end
    task.wait(0.1)
end

print("--------------------------------------------------")
print("📊 RESUMO:")
print("✅ Arquivos disponíveis:", #available)
print("❌ Arquivos faltando:", #missing)

if #missing > 0 then
    warn("\n⚠️ OS ARQUIVOS ABAIXO NÃO ESTÃO NO GITHUB OU A URL ESTÁ ERRADA:")
    for _, path in ipairs(missing) do
        warn("   - " .. path)
    end
    warn("\n💡 SOLUÇÕES:")
    warn("   1. Certifique-se de ter ENVIADO TODOS os arquivos para o repositório!")
    warn("   2. Verifique se o repositório está PÚBLICO!")
    warn("   3. Verifique se o caminho dos arquivos no GitHub está correto!")
else
    print("\n🎉 TODOS OS ARQUIVOS ESTÃO DISPONÍVEIS NO GITHUB!")
end
