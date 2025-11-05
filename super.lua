-- Универсальное Roblox чит-меню с анти-отдачей (анти-улетание): если вас бьют, вы не улетаете и остаётесь на месте.
-- Всё остальное не тронуто. Меню голубое, дельфин, платформа и все функции из прошлого запроса.

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")

local walkSpeed, jumpPower, flySpeed = 16, 50, 50
local isFlying, antiKB, fastStand, enlargedHitbox, espEnabled = false, false, false, false, false

local platformActive = false
local platformPart = nil
local platformSpeed = 5 -- Средняя скорость, можно менять число для другого темпа

local function getChar()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

--== UI ==
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "UniversalCheatMenu"
-- Dolphin icon
local dolphin = Instance.new("ImageLabel", gui)
dolphin.BackgroundTransparency = 1
dolphin.Image = "rbxassetid://14508850515"
dolphin.Size = UDim2.new(0,80,0,80)
dolphin.Position = UDim2.new(0, 10, 0, 2)
dolphin.ZIndex = 500
-- Main frame
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 370, 0, 440)
frame.Position = UDim2.new(0, 100, 0, 70)
frame.BackgroundColor3 = Color3.fromRGB(100, 210, 255)
frame.Active = true
frame.Draggable = true
frame.Visible = true -- Для управления видимостью
frame.BorderSizePixel = 0

-- Menu Button
local menuBtn = Instance.new("TextButton", gui)
menuBtn.Size = UDim2.new(0, 100, 0, 40)
menuBtn.Position = UDim2.new(0,95,0,18)
menuBtn.Text = "Меню"
menuBtn.BackgroundColor3 = Color3.fromRGB(51, 180, 220)
menuBtn.TextColor3 = Color3.new(1,1,1)
menuBtn.Font = Enum.Font.SourceSansBold
menuBtn.TextSize = 18
menuBtn.Visible = true
menuBtn.ZIndex = 9999
frame:GetPropertyChangedSignal("Visible"):Connect(function()
    menuBtn.Text = frame.Visible and "Закрыть" or "Меню"
end)
menuBtn.MouseButton1Click:Connect(function()
    frame.Visible = not frame.Visible
end)

local y = 0

local function makeTitle(text)
    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(1,0,0,40)
    lbl.Position = UDim2.new(0,0,0,y)
    y = y + 0.085
    lbl.BackgroundColor3 = Color3.fromRGB(63,172,236)
    lbl.TextColor3 = Color3.new(1,1,1)
    lbl.Text = text .. " 🐬"
    lbl.Font = Enum.Font.SourceSansBold
    lbl.TextSize = 22
    lbl.BorderSizePixel = 0
    return lbl
end

local function makeLabel(labelText)
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0, 200, 0, 30)
    label.Position = UDim2.new(0, 12, 0, y*frame.Size.Y.Offset)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(16,42,68)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.SourceSans
    label.Text = labelText
    label.TextSize = 18
    label.BorderSizePixel = 0
    return label
end

-- Исправленный прыжок на RENDERSTEPPED
local function applyJumpPower(power)
    jumpPower = math.clamp(power, 0, 200)
    local char = getChar()
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        pcall(function() hum.JumpPower = jumpPower end)
        pcall(function() hum.UseJumpPower = true end)
    end
end

local function makeInput(x,labelText, defaultV, callback)
    makeLabel(labelText)
    local box = Instance.new("TextBox", frame)
    box.Size = UDim2.new(0, 90, 0, 28)
    box.Position = UDim2.new(0, 225, 0, y*frame.Size.Y.Offset-2)
    box.BackgroundColor3 = Color3.fromRGB(133, 216, 255)
    box.Text = tostring(defaultV)
    box.TextColor3 = Color3.new(0.09,0.23,0.29)
    box.Font = Enum.Font.SourceSans
    box.TextSize = 17
    box.ClearTextOnFocus = false
    box.BorderSizePixel = 0
    box.FocusLost:Connect(function(enter)
        local n = tonumber(box.Text)
        if n then
            callback(n)
        else
            box.Text = tostring(defaultV)
        end
    end)
    y = y + 0.108
    return box
end

local function makeToggle(labelText, defaultValue, callback)
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0, 320, 0, 32)
    btn.Position = UDim2.new(0, 25, 0, y*frame.Size.Y.Offset)
    btn.BackgroundColor3 = defaultValue and Color3.fromRGB(63, 200, 236) or Color3.fromRGB(13, 98, 162)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.SourceSansBold
    btn.Text = labelText .. (defaultValue and " [ВКЛ]" or " [ВЫКЛ]")
    btn.TextSize = 18
    btn.BorderSizePixel = 0
    local state = defaultValue
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(63, 200, 236) or Color3.fromRGB(13, 98, 162)
        btn.Text = labelText .. (state and " [ВКЛ]" or " [ВЫКЛ]")
        callback(state)
    end)
    y = y + 0.085
    return btn
end

makeTitle("CHEAT МЕНЮ — ПК/МОБИЛКА")

makeInput(0, "Скорость (ходьба):", walkSpeed, function(n)
    walkSpeed = math.clamp(n,0,200)
    local hum = getChar():FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = walkSpeed end
end)
makeInput(0, "Прыжок:", jumpPower, function(n)
    applyJumpPower(n)
end)
makeInput(0, "Скорость полёта:", flySpeed, function(n)
    flySpeed = math.clamp(n,4,200)
end)

makeToggle("Полет (F или кнопка)", false, function(val) isFlying = val end)
makeToggle("Анти-отдача", false, function(val) antiKB = val end)
makeToggle("Анти-улетание (knockback)", false, function(val) -- Новое!
    antiKB = val
end)
makeToggle("Быстрое вставание", false, function(val) fastStand = val end)
makeToggle("Большой хитбокс врага", false, function(val)
    enlargedHitbox = val
    for _,plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local part = plr.Character.HumanoidRootPart
            if enlargedHitbox then
                part.Size = Vector3.new(7,7,7)
                part.Transparency = 0.5
                part.Color = Color3.fromRGB(145, 232, 255)
            else
                part.Size = Vector3.new(2,2,1)
                part.Transparency = 1
                part.Color = Color3.fromRGB(163, 162, 165)
            end
        end
    end
end)
makeToggle("ESP на игроков сервера", false, function(val)
    espEnabled = val
    for _,plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            if espEnabled then
                local box = Instance.new("BoxHandleAdornment")
                box.Adornee = plr.Character.HumanoidRootPart
                box.AlwaysOnTop = true
                box.ZIndex = 15
                box.Size = Vector3.new(4, 7, 4)
                box.Transparency = 0.6
                box.Color3 = Color3.fromRGB(41, 175, 232)
                box.Name = "ESPBOX"
                box.Parent = plr.Character
            else
                if plr.Character:FindFirstChild("ESPBOX") then
                    plr.Character.ESPBOX:Destroy()
                end
            end
        end
    end
end)

-- КНОПКА ПОДНИМАЮЩЕЙ ПЛАТФОРМЫ
local platBtn = Instance.new("TextButton", frame)
platBtn.Size = UDim2.new(0, 320, 0, 34)
platBtn.Position = UDim2.new(0, 25, 0, y*frame.Size.Y.Offset)
platBtn.BackgroundColor3 = Color3.fromRGB(13, 98, 162)
platBtn.TextColor3 = Color3.new(1,1,1)
platBtn.Font = Enum.Font.SourceSansBold
platBtn.Text = "Платформа (ПОДНЯТЬ/Опустить)"
platBtn.TextSize = 18
platBtn.BorderSizePixel = 0

local function togglePlatform()
    platformActive = not platformActive
    if platformPart and platformPart.Parent then
        platformPart:Destroy()
        platformPart = nil
    end
    if platformActive then
        local char = getChar()
        if char and char:FindFirstChild("HumanoidRootPart") then
            local hrp = char.HumanoidRootPart
            local plat = Instance.new("Part")
            plat.Size = Vector3.new(7, 1, 7)
            plat.Anchored = true
            plat.CanCollide = true
            plat.Position = hrp.Position - Vector3.new(0,3,0)
            plat.Color = Color3.fromRGB(41, 175, 232)
            plat.Material = Enum.Material.Neon
            plat.Name = "UpPlatform"
            plat.Parent = workspace
            platformPart = plat
        end
        platBtn.Text = "Платформа (ОПУСТИТЬ)"
        platBtn.BackgroundColor3 = Color3.fromRGB(28, 238, 255)
    else
        platBtn.Text = "Платформа (ПОДНЯТЬ)"
        platBtn.BackgroundColor3 = Color3.fromRGB(13,98,162)
        if platformPart and platformPart.Parent then
            platformPart:Destroy()
            platformPart = nil
        end
    end
end

platBtn.MouseButton1Click:Connect(togglePlatform)

y = y + 0.085

-- ======= Плавное поднятие платформы ========

RS.RenderStepped:Connect(function(dt)
    local char = getChar()
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        if not isFlying then
            hum.WalkSpeed = walkSpeed
        else
            hum.WalkSpeed = 0
        end
        applyJumpPower(jumpPower)
    end
    if platformActive and platformPart and char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        platformPart.Position = Vector3.new(hrp.Position.X, platformPart.Position.Y, hrp.Position.Z)
        platformPart.Position = platformPart.Position + Vector3.new(0, platformSpeed*dt, 0)
        if hrp.Position.Y < platformPart.Position.Y + 2 then
            hrp.CFrame = CFrame.new(hrp.Position.X, platformPart.Position.Y + 3, hrp.Position.Z)
        end
    end
end)

-- == Рабочий антикнокбек: сброс BodyVelocity и поддержка позиции ==
local lastPosition = nil
RS.RenderStepped:Connect(function()
    local char = getChar()
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if antiKB and hrp then
        -- Сброс всех "BodyVelocity", "BodyAngularVelocity" -- стирает любые отбрасывания
        for _, v in pairs(hrp:GetChildren()) do
            if v:IsA("BodyVelocity") or v:IsA("BodyForce") or v:IsA("BodyThrust") or v:IsA("BodyAngularVelocity") then
                v:Destroy()
            end
        end
        -- Позиция логгировалась и поддерживается (например, после выстрела)
        if lastPosition then
            hrp.Velocity = Vector3.new(0,0,0)
            hrp.RotVelocity = Vector3.new(0,0,0)
            hrp.CFrame = CFrame.new(lastPosition)
        end
        -- Обновляем позицию если стоите на земле (YVelocity относительно небольшая)
        if math.abs(hrp.Velocity.Y) < 3 then
            lastPosition = hrp.Position
        end
    end
end)

-- == Фиксированный полет через MoveDirection ==
RS:BindToRenderStep("FixedFly", Enum.RenderPriority.Character.Value, function()
    local char = getChar()
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildWhichIsA("Humanoid")
    if not hrp or not hum then return end
    if not isFlying and hrp:FindFirstChild("FlyVelocity") then
        hrp.FlyVelocity:Destroy()
        if hrp:FindFirstChild("FlyGyro") then hrp.FlyGyro:Destroy() end
        return
    end
    if isFlying then
        if not hrp:FindFirstChild("FlyVelocity") then
            local bv = Instance.new("BodyVelocity")
            bv.Name = "FlyVelocity"
            bv.MaxForce = Vector3.new(1e5,1e5,1e5)
            bv.P = 1280
            bv.Velocity = Vector3.new(0,0,0)
            bv.Parent = hrp
            local bg = Instance.new("BodyGyro")
            bg.Name = "FlyGyro"
            bg.MaxTorque = Vector3.new(1e5,1e5,1e5)
            bg.P = 20000
            bg.CFrame = hrp.CFrame
            bg.Parent = hrp
        end
        local bv = hrp:FindFirstChild("FlyVelocity")
        local bg = hrp:FindFirstChild("FlyGyro")
        if bv and bg then
            local moveVec = hum.MoveDirection
            local vert = 0
            if UIS:IsKeyDown(Enum.KeyCode.Space) then vert = vert + 1 end
            if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then vert = vert - 1 end
            if hum.Jump and UIS.TouchEnabled then vert = 1 end
            local final = moveVec * flySpeed + Vector3.new(0,vert*flySpeed,0)
            if final.Magnitude > flySpeed then final = final.Unit * flySpeed end
            bv.Velocity = final
            bg.CFrame = workspace.CurrentCamera.CFrame
            hum.PlatformStand = false
        end
    end
end)

-- == Горячие клавиши (ПК) для меню, полёта и платформы ==
UIS.InputBegan:Connect(function(input, gp)
    if not gp then
        if input.KeyCode == Enum.KeyCode.F then
            isFlying = not isFlying
        end
        if input.KeyCode == Enum.KeyCode.M then
            frame.Visible = not frame.Visible
        end
        if input.KeyCode == Enum.KeyCode.P then
            togglePlatform()
        end
    end
end)

-- == Антиотдача и FastStand (старое) ==
local function guardHumanoid()
    local humanoid = getChar():FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.Changed:Connect(function(prop)
            -- старый вариант sit-сброса
            if antiKB and prop == "SeatPart" and humanoid.SeatPart then
                humanoid.Sit = false
            end
        end)
        humanoid:GetPropertyChangedSignal("PlatformStand"):Connect(function()
            if fastStand and humanoid.PlatformStand then
                wait(0.05)
                humanoid.PlatformStand = false
            end
        end)
    end
end
getChar().ChildAdded:Connect(function(obj)
    if obj:IsA("Humanoid") then guardHumanoid() end
end)
guardHumanoid()