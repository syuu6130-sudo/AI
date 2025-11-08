-- Universal Game AI Script with Rayfield UI
-- 全てのゲームをAIがプレイするスクリプト

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "🤖 Universal Game AI Player",
   LoadingTitle = "AI システム起動中...",
   LoadingSubtitle = "by AI Assistant",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil,
      FileName = "GameAI"
   },
   Discord = {
      Enabled = false,
      Invite = "noinvite",
      RememberJoins = true
   },
   KeySystem = false
})

-- グローバル変数
local AIEnabled = false
local CurrentMode = "NORMAL"
local AISpeed = 1
local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- AI設定
local Settings = {
    NOOB = {
        Speed = 0.5,
        Accuracy = 0.3,
        ReactionTime = 1.5,
        DecisionDelay = 2
    },
    NORMAL = {
        Speed = 1,
        Accuracy = 0.6,
        ReactionTime = 0.8,
        DecisionDelay = 1
    },
    PRO = {
        Speed = 2,
        Accuracy = 0.95,
        ReactionTime = 0.1,
        DecisionDelay = 0.2
    }
}

-- ユーティリティ関数
local function findNearestTarget()
    local nearestDistance = math.huge
    local nearestTarget = nil
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj ~= Character then
            local humanoid = obj:FindFirstChild("Humanoid")
            local rootPart = obj:FindFirstChild("HumanoidRootPart")
            
            if humanoid and rootPart and humanoid.Health > 0 then
                local distance = (RootPart.Position - rootPart.Position).Magnitude
                if distance < nearestDistance then
                    nearestDistance = distance
                    nearestTarget = obj
                end
            end
        end
    end
    
    return nearestTarget
end

local function findCollectibles()
    local collectibles = {}
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            -- コインや収集アイテムを検索
            if obj.Name:lower():match("coin") or 
               obj.Name:lower():match("gem") or 
               obj.Name:lower():match("star") or
               obj.Name:lower():match("collectable") then
                table.insert(collectibles, obj)
            end
        end
    end
    
    return collectibles
end

local function moveToPosition(targetPos)
    if not AIEnabled then return end
    
    local currentSettings = Settings[CurrentMode]
    
    -- 精度に基づいてランダムなオフセットを追加
    local accuracy = currentSettings.Accuracy
    local offset = Vector3.new(
        math.random(-10, 10) * (1 - accuracy),
        0,
        math.random(-10, 10) * (1 - accuracy)
    )
    
    Humanoid:MoveTo(targetPos + offset)
end

local function performAction()
    if not AIEnabled then return end
    
    local currentSettings = Settings[CurrentMode]
    
    -- 反応時間を考慮
    wait(currentSettings.ReactionTime)
    
    -- ツールの使用を試みる
    for _, tool in pairs(Player.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            Humanoid:EquipTool(tool)
            wait(0.1)
            tool:Activate()
            break
        end
    end
    
    -- キャラクターが既に装備しているツールを使用
    local equippedTool = Character:FindFirstChildOfClass("Tool")
    if equippedTool then
        equippedTool:Activate()
    end
end

-- メインAIループ
local function aiLoop()
    while AIEnabled do
        local currentSettings = Settings[CurrentMode]
        
        -- ターゲットを探す
        local target = findNearestTarget()
        if target then
            local targetRoot = target:FindFirstChild("HumanoidRootPart")
            if targetRoot then
                moveToPosition(targetRoot.Position)
                performAction()
            end
        else
            -- ターゲットがいない場合は収集アイテムを探す
            local collectibles = findCollectibles()
            if #collectibles > 0 then
                local randomCollectible = collectibles[math.random(1, #collectibles)]
                moveToPosition(randomCollectible.Position)
            else
                -- ランダムに移動
                local randomPos = RootPart.Position + Vector3.new(
                    math.random(-50, 50),
                    0,
                    math.random(-50, 50)
                )
                moveToPosition(randomPos)
            end
        end
        
        wait(currentSettings.DecisionDelay)
    end
end

-- UIタブ作成
local MainTab = Window:CreateTab("🎮 メイン", 4483362458)
local SettingsTab = Window:CreateTab("⚙️ 設定", 4483362458)

-- メインタブのUI要素
local AIToggle = MainTab:CreateToggle({
   Name = "AI自動プレイ",
   CurrentValue = false,
   Flag = "AIToggle",
   Callback = function(Value)
      AIEnabled = Value
      if Value then
          Rayfield:Notify({
             Title = "AI起動",
             Content = CurrentMode .. "モードでAIが開始されました",
             Duration = 3,
             Image = 4483362458,
          })
          spawn(aiLoop)
      else
          Rayfield:Notify({
             Title = "AI停止",
             Content = "AIが停止されました",
             Duration = 3,
             Image = 4483362458,
          })
      end
   end,
})

local ModeDropdown = MainTab:CreateDropdown({
   Name = "AIモード選択",
   Options = {"NOOB", "NORMAL", "PRO"},
   CurrentOption = "NORMAL",
   MultipleOptions = false,
   Flag = "ModeDropdown",
   Callback = function(Option)
      CurrentMode = Option
      Rayfield:Notify({
         Title = "モード変更",
         Content = Option .. "モードに変更されました",
         Duration = 3,
         Image = 4483362458,
      })
   end,
})

MainTab:CreateSection("モード説明")

MainTab:CreateParagraph({
   Title = "📝 各モードについて",
   Content = "NOOB: 初心者レベル（遅い移動、低精度）\nNORMAL: 通常レベル（標準的な動き）\nPRO AI: プロレベル（高速、高精度、即座の反応）"
})

-- 設定タブ
SettingsTab:CreateSection("詳細設定")

local SpeedSlider = SettingsTab:CreateSlider({
   Name = "AI速度倍率",
   Range = {0.1, 3},
   Increment = 0.1,
   CurrentValue = 1,
   Flag = "SpeedSlider",
   Callback = function(Value)
      AISpeed = Value
      for mode, settings in pairs(Settings) do
          settings.Speed = settings.Speed * Value
      end
   end,
})

local AutoCollectToggle = SettingsTab:CreateToggle({
   Name = "自動収集モード",
   CurrentValue = true,
   Flag = "AutoCollect",
   Callback = function(Value)
      Rayfield:Notify({
         Title = "自動収集",
         Content = Value and "有効化されました" or "無効化されました",
         Duration = 2,
         Image = 4483362458,
      })
   end,
})

SettingsTab:CreateButton({
   Name = "キャラクターをリセット",
   Callback = function()
      Player.Character:BreakJoints()
      wait(2)
      Character = Player.Character or Player.CharacterAdded:Wait()
      Humanoid = Character:WaitForChild("Humanoid")
      RootPart = Character:WaitForChild("HumanoidRootPart")
   end,
})

-- 情報タブ
local InfoTab = Window:CreateTab("ℹ️ 情報", 4483362458)

InfoTab:CreateParagraph({
   Title = "使い方",
   Content = "1. AIモードを選択\n2. AI自動プレイをON\n3. AIが自動的にゲームをプレイします\n\n※ゲームによっては完全に対応していない場合があります"
})

InfoTab:CreateParagraph({
   Title = "機能",
   Content = "• 自動移動\n• 自動ターゲット検索\n• 自動攻撃\n• アイテム自動収集\n• 3段階の難易度調整"
})

-- 初期通知
Rayfield:Notify({
   Title = "AI Script ロード完了",
   Content = "Universal Game AI Playerが起動しました",
   Duration = 5,
   Image = 4483362458,
})

-- キャラクター再スポーン時の処理
Player.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
    RootPart = char:WaitForChild("HumanoidRootPart")
end)
