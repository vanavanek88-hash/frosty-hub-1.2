-- ══════════════════════════════════════════════
--  Frosty Hub — Universal Loader (v1.0)
--  Определяет игру и экзекутор, грузит нужный модуль
-- ══════════════════════════════════════════════

-- 1. Определяем экзекутор (для логов и отладки)
local executorName = "Unknown"
if identifyexecutor then
    local ok, name = pcall(identifyexecutor)
    if ok and type(name) == "string" then
        executorName = name
    end
end

-- 2. Карта поддерживаемых игр
local Games = {
    [142823291] = { -- Murder Mystery 2
        Name = "Murder Mystery 2",
        -- Сюда вставь ссылку на raw-файл из GitHub (или LuaProtect CDN)
        Url = "https://raw.githubusercontent.com/ТВОЙ_НИК/FrostyHub-Modules/main/mm2/main.luau"
    },
    -- Сюда потом добавишь BSS, Blox Fruits и т.д.
    -- [1537690962] = { Name = "Bee Swarm Simulator", Url = "..." },
}

-- 3. Ищем игру
local gameData = Games[game.PlaceId]

if not gameData then
    -- Если игра не поддерживается — вежливо сообщаем
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Frosty Hub",
        Text = "Эта игра пока не поддерживается :(",
        Duration = 5
    })
    warn("[FrostyHub] Unsupported game. PlaceId: " .. tostring(game.PlaceId))
    return
end

-- 4. Загружаем модуль
print(string.format("[FrostyHub] Executor: %s | Game: %s", executorName, gameData.Name))

local ok, err = pcall(function()
    local code = game:HttpGet(gameData.Url)
    loadstring(code)()
end)

if not ok then
    warn("[FrostyHub] Failed to load module: " .. tostring(err))
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Frosty Hub",
        Text = "Ошибка загрузки модуля. Проверь консоль (F9).",
        Duration = 5
    })
end
