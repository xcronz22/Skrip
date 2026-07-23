local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xcronz22/Skrip/main/RZY_Library.lua"))()
local Window = Library:MakeWindow("Train NPC Script")

-- Lokasi remote event untuk Use Ability
local AbilityEvent = game:GetService("ReplicatedStorage").AIArena.Remotes.UseAbility

-- Variabel sakelar
local AutoAbility = false

-- Membuat Toggle di UI
Window:AddToggle("Auto Use Ability", false, function(state)
    AutoAbility = state
end)

-- Mesin belakang yang berjalan setiap 1 detik
task.spawn(function()
    while task.wait(1) do
        if AutoAbility then
            pcall(function()
                -- Karena ini RemoteEvent, kita menggunakan FireServer (bukan InvokeServer)
                AbilityEvent:FireServer()
            end)
        end
    end
end)
