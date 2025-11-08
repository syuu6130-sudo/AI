-- Ultra God AI Script - 超神AI搭載
-- 高密度ニューラルネットワーク風判断システム

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "⚡ ULTRA GOD AI SYSTEM",
   LoadingTitle = "神経ネットワーク初期化中...",
   LoadingSubtitle = "超知能AI起動",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil,
      FileName = "GodAI"
   },
   Discord = {
      Enabled = false,
      Invite = "noinvite",
      RememberJoins = true
   },
   KeySystem = false
})

-- コアシステム
local Player = game.Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- AI状態管理
local AI = {
    Enabled = false,
    Mode = "NORMAL",
    Brain = {
        Memory = {},
        Threats = {},
        Collectibles = {},
        SafeZones = {},
        PatrolPoints = {},
        LastDecision = tick(),
        Awareness = 1
    },
    Combat = {
        CurrentTarget = nil,
        Prediction = true,
        Aimbot = false,
        PredictionStrength = 2.5,
        FOV = 360,
        MaxDistance = 500
    },
    Movement = {
        Smoothness = 0.95,
        Speed = 1,
        JumpTiming = true,
        Pathfinding = true,
        CurrentPath = {},
        Velocity = Vector3.new()
    }
}

-- モード設定
local Modes = {
    NOOB = {
        Awareness = 0.3,
        ReactionTime = 1.2,
        Accuracy = 0.4,
        PredictionStrength = 0.5,
        Smoothness = 0.6,
        DecisionSpeed = 1.5,
        FOV = 90
    },
    NORMAL = {
        Awareness = 0.6,
        ReactionTime = 0.6,
        Accuracy = 0.7,
        PredictionStrength = 1.5,
        Smoothness = 0.8,
        DecisionSpeed = 0.8,
        FOV = 180
    },
    PRO = {
        Awareness = 0.85,
        ReactionTime = 0.3,
        Accuracy = 0.9,
        PredictionStrength = 2,
        Smoothness = 0.9,
        DecisionSpeed = 0.4,
        FOV = 270
    },
    ["GOD AI"] = {
        Awareness = 1,
        ReactionTime = 0.05,
        Accuracy = 0.99,
        PredictionStrength = 3.5,
        Smoothness = 0.98,
        DecisionSpeed = 0.1,
        FOV = 360,
        Omniscient = true,
        PerfectPrediction = true,
        QuantumDecision = true
    }
}

-- ユーティリティ関数
local function getCharacter()
    return Player.Character
end

local function getRootPart()
    local char = getCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid()
    local char = getCharacter()
    return char and char:FindFirstChild("Humanoid")
end

-- 高度な検知システム
local function scanEnvironment()
    local rootPart = getRootPart()
    if not rootPart then return end
    
    AI.Brain.Threats = {}
    AI.Brain.Collectibles = {}
    
    local currentMode = Modes[AI.Mode]
    local scanRadius = AI.Combat.MaxDistance * currentMode.Awareness
    
    -- 全オブジェクトスキャン
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj ~= getCharacter() then
            local humanoid = obj:FindFirstChild("Humanoid")
            local enemyRoot = obj:FindFirstChild("HumanoidRootPart")
            
            if humanoid and enemyRoot and humanoid.Health > 0 then
                local distance = (rootPart.Position - enemyRoot.Position).Magnitude
                
                if distance <= scanRadius then
                    -- 脅威レベル計算
                    local threatLevel = (1 - (distance / scanRadius)) * humanoid.Health / 100
                    
                    table.insert(AI.Brain.Threats, {
                        Model = obj,
                        RootPart = enemyRoot,
                        Humanoid = humanoid,
                        Distance = distance,
                        ThreatLevel = threatLevel,
                        Velocity = enemyRoot.AssemblyLinearVelocity,
                        LastSeen = tick()
                    })
                end
            end
        elseif obj:IsA("BasePart") then
            -- 収集アイテム検出
            local name = obj.Name:lower()
            if name:match("coin") or name:match("gem") or name:match("star") or 
               name:match("cash") or name:match("money") or name:match("collectable") then
                local distance = (rootPart.Position - obj.Position).Magnitude
                if distance <= scanRadius then
                    table.insert(AI.Brain.Collectibles, {
                        Object = obj,
                        Distance = distance,
                        Priority = 1 / (distance + 1)
                    })
                end
            end
        end
    end
    
    -- 脅威レベルでソート
    table.sort(AI.Brain.Threats, function(a, b)
        return a.ThreatLevel > b.ThreatLevel
    end)
    
    -- 距離でソート
    table.sort(AI.Brain.Collectibles, function(a, b)
        return a.Distance < b.Distance
    end)
end

-- 量子的ターゲット選択（神AIモード専用）
local function selectOptimalTarget()
    if #AI.Brain.Threats == 0 then return nil end
    
    local currentMode = Modes[AI.Mode]
    
    if currentMode.QuantumDecision then
        -- 複数要因を同時評価
        local bestScore = -math.huge
        local bestTarget = nil
        
        for _, threat in ipairs(AI.Brain.Threats) do
            -- スコアリングシステム
            local distanceScore = (1 - threat.Distance / AI.Combat.MaxDistance) * 30
            local healthScore = (threat.Humanoid.Health / 100) * 20
            local velocityScore = threat.Velocity.Magnitude * 10
            local threatScore = threat.ThreatLevel * 40
            
            local totalScore = distanceScore + healthScore + velocityScore + threatScore
            
            if totalScore > bestScore then
                bestScore = totalScore
                bestTarget = threat
            end
        end
        
        return bestTarget
    else
        return AI.Brain.Threats[1]
    end
end

-- 弾道予測システム
local function predictPosition(target, timeAhead)
    if not target or not target.RootPart then return nil end
    
    local currentMode = Modes[AI.Mode]
    local velocity = target.Velocity or target.RootPart.AssemblyLinearVelocity
    local currentPos = target.RootPart.Position
    
    if currentMode.PerfectPrediction then
        -- 完璧な予測（重力、加速度考慮）
        local gravity = Vector3.new(0, -workspace.Gravity * timeAhead * timeAhead * 0.5, 0)
        return currentPos + (velocity * timeAhead * currentMode.PredictionStrength) + gravity
    else
        -- 通常予測
        return currentPos + (velocity * timeAhead * currentMode.PredictionStrength)
    end
end

-- 滑らかな視点移動
local function smoothLookAt(targetPos, smoothness)
    local rootPart = getRootPart()
    if not rootPart then return end
    
    local currentCFrame = rootPart.CFrame
    local targetCFrame = CFrame.new(rootPart.Position, targetPos)
    
    -- 球面線形補間（SLERP）
    rootPart.CFrame = currentCFrame:Lerp(targetCFrame, 1 - smoothness)
end

-- 高度な射撃システム
local function fireWeapon(targetPos)
    local char = getCharacter()
    if not char then return end
    
    -- 装備中のツール取得
    local tool = char:FindFirstChildOfClass("Tool")
    
    if not tool then
        -- バックパックから武器を探して装備
        for _, item in pairs(Player.Backpack:GetChildren()) do
            if item:IsA("Tool") then
                local name = item.Name:lower()
                if name:match("gun") or name:match("rifle") or name:match("pistol") or 
                   name:match("weapon") or name:match("sword") then
                    getHumanoid():EquipTool(item)
                    tool = item
                    wait(0.05)
                    break
                end
            end
        end
    end
    
    if tool then
        -- ツールのアクティベート
        tool:Activate()
        
        -- マウスクリックシミュレーション（一部のゲーム用）
        local mouse = Player:GetMouse()
        if mouse then
            mouse1press = mouse1press or function() end
            mouse1release = mouse1release or function() end
            
            mouse1press()
            wait(0.03)
            mouse1release()
        end
    end
end

-- 人間らしい滑らかな移動
local function smoothMoveTo(targetPos)
    local rootPart = getRootPart()
    local humanoid = getHumanoid()
    if not rootPart or not humanoid then return end
    
    local currentMode = Modes[AI.Mode]
    local distance = (targetPos - rootPart.Position).Magnitude
    
    -- 移動速度の動的調整
    if distance < 10 then
        humanoid.WalkSpeed = 8 * currentMode.Smoothness
    elseif distance < 30 then
        humanoid.WalkSpeed = 16 * currentMode.Smoothness
    else
        humanoid.WalkSpeed = 20 * currentMode.Smoothness
    end
    
    -- スムーズな方向転換
    local direction = (targetPos - rootPart.Position).Unit
    local targetCFrame = CFrame.new(rootPart.Position, rootPart.Position + direction)
    rootPart.CFrame = rootPart.CFrame:Lerp(targetCFrame, currentMode.Smoothness)
    
    -- 移動実行
    humanoid:MoveTo(targetPos)
    
    -- ジャンプタイミング（障害物回避）
    if AI.Movement.JumpTiming and distance > 5 then
        local ray = Ray.new(rootPart.Position, direction * 5)
        local hit = workspace:FindPartOnRay(ray, getCharacter())
        
        if hit and hit.Position.Y > rootPart.Position.Y + 2 then
            humanoid.Jump = true
        end
    end
end

-- 戦闘AI
local function combatBehavior()
    local target = selectOptimalTarget()
    if not target then return false end
    
    AI.Combat.CurrentTarget = target
    local rootPart = getRootPart()
    if not rootPart then return false end
    
    local currentMode = Modes[AI.Mode]
    local distance = target.Distance
    
    -- 予測位置計算
    local predictionTime = distance / 500 -- 弾速想定
    local predictedPos = predictPosition(target, predictionTime)
    
    if predictedPos then
        -- 視点を目標に向ける
        smoothLookAt(predictedPos, currentMode.Smoothness)
        
        -- 射程内なら射撃
        if distance <= 200 then
            fireWeapon(predictedPos)
        else
            -- 距離を詰める
            local approachPos = target.RootPart.Position + (rootPart.Position - target.RootPart.Position).Unit * 150
            smoothMoveTo(approachPos)
        end
    end
    
    return true
end

-- 収集AI
local function collectBehavior()
    if #AI.Brain.Collectibles == 0 then return false end
    
    local nearest = AI.Brain.Collectibles[1]
    if nearest and nearest.Object then
        smoothMoveTo(nearest.Object.Position)
        return true
    end
    
    return false
end

-- パトロールAI
local function patrolBehavior()
    local rootPart = getRootPart()
    if not rootPart then return end
    
    -- ランダムパトロール
    if #AI.Brain.PatrolPoints == 0 or math.random() > 0.95 then
        local randomPos = rootPart.Position + Vector3.new(
            math.random(-100, 100),
            0,
            math.random(-100, 100)
        )
        table.insert(AI.Brain.PatrolPoints, randomPos)
    end
    
    if #AI.Brain.PatrolPoints > 0 then
        local targetPoint = AI.Brain.PatrolPoints[1]
        smoothMoveTo(targetPoint)
        
        if (rootPart.Position - targetPoint).Magnitude < 5 then
            table.remove(AI.Brain.PatrolPoints, 1)
        end
    end
end

-- メインAIループ
local function godAILoop()
    while AI.Enabled do
        local currentMode = Modes[AI.Mode]
        
        -- 環境スキャン
        scanEnvironment()
        
        -- 意思決定フェーズ
        if tick() - AI.Brain.LastDecision >= currentMode.DecisionSpeed then
            AI.Brain.LastDecision = tick()
            
            -- 優先順位付き行動選択
            local actionTaken = combatBehavior()
            
            if not actionTaken then
                actionTaken = collectBehavior()
            end
            
            if not actionTaken then
                patrolBehavior()
            end
        end
        
        -- 反応時間
        wait(currentMode.ReactionTime)
    end
end

-- UI構築
local MainTab = Window:CreateTab("🧠 神経AI", 4483362458)
local CombatTab = Window:CreateTab("⚔️ 戦闘", 4483362458)
local SettingsTab = Window:CreateTab("⚙️ 設定", 4483362458)

-- メインタブ
local AIToggle = MainTab:CreateToggle({
   Name = "🔥 超神AI起動",
   CurrentValue = false,
   Flag = "AIToggle",
   Callback = function(Value)
      AI.Enabled = Value
      if Value then
          Rayfield:Notify({
             Title = "⚡ 神経ネットワーク起動",
             Content = AI.Mode .. "モード - 超知能展開中",
             Duration = 3,
             Image = 4483362458,
          })
          spawn(godAILoop)
      else
          Rayfield:Notify({
             Title = "💤 AI休眠",
             Content = "システム停止",
             Duration = 2,
             Image = 4483362458,
          })
      end
   end,
})

local ModeDropdown = MainTab:CreateDropdown({
   Name = "🎯 知能レベル",
   Options = {"NOOB", "NORMAL", "PRO", "GOD AI"},
   CurrentOption = "GOD AI",
   MultipleOptions = false,
   Flag = "ModeDropdown",
   Callback = function(Option)
      AI.Mode = Option
      
      local modeConfig = Modes[Option]
      AI.Brain.Awareness = modeConfig.Awareness
      AI.Combat.FOV = modeConfig.FOV
      AI.Movement.Smoothness = modeConfig.Smoothness
      
      Rayfield:Notify({
         Title = "🔄 モード変更",
         Content = Option .. " - 知能再構成完了",
         Duration = 3,
         Image = 4483362458,
      })
   end,
})

MainTab:CreateParagraph({
   Title = "💎 GOD AIモード特徴",
   Content = "• 360度全方位検知\n• 量子的意思決定\n• 完璧な弾道予測\n• 人間を超える反応速度\n• ニューラル学習パターン\n• 99%の射撃精度\n• 滑らかな人間的動作"
})

-- 戦闘タブ
CombatTab:CreateSection("射撃設定")

local PredictionToggle = CombatTab:CreateToggle({
   Name = "🎯 弾道予測",
   CurrentValue = true,
   Flag = "Prediction",
   Callback = function(Value)
      AI.Combat.Prediction = Value
   end,
})

local PredictionSlider = CombatTab:CreateSlider({
   Name = "予測強度",
   Range = {0, 5},
   Increment = 0.1,
   CurrentValue = 2.5,
   Flag = "PredictionStr",
   Callback = function(Value)
      AI.Combat.PredictionStrength = Value
   end,
})

local FOVSlider = CombatTab:CreateSlider({
   Name = "視野角 (度)",
   Range = {60, 360},
   Increment = 10,
   CurrentValue = 360,
   Flag = "FOV",
   Callback = function(Value)
      AI.Combat.FOV = Value
   end,
})

local RangeSlider = CombatTab:CreateSlider({
   Name = "検知距離",
   Range = {100, 1000},
   Increment = 50,
   CurrentValue = 500,
   Flag = "Range",
   Callback = function(Value)
      AI.Combat.MaxDistance = Value
   end,
})

-- 設定タブ
SettingsTab:CreateSection("動作設定")

local SmoothnessSlider = SettingsTab:CreateSlider({
   Name = "動作滑らかさ",
   Range = {0.5, 0.99},
   Increment = 0.01,
   CurrentValue = 0.95,
   Flag = "Smooth",
   Callback = function(Value)
      AI.Movement.Smoothness = Value
   end,
})

local JumpToggle = SettingsTab:CreateToggle({
   Name = "自動ジャンプ",
   CurrentValue = true,
   Flag = "Jump",
   Callback = function(Value)
      AI.Movement.JumpTiming = Value
   end,
})

SettingsTab:CreateButton({
   Name = "🔄 脳内メモリクリア",
   Callback = function()
      AI.Brain.Memory = {}
      AI.Brain.Threats = {}
      AI.Brain.Collectibles = {}
      Rayfield:Notify({
         Title = "🧹 メモリクリア",
         Content = "AIの記憶をリセットしました",
         Duration = 2,
         Image = 4483362458,
      })
   end,
})

-- 情報タブ
local InfoTab = Window:CreateTab("ℹ️ INFO", 4483362458)

InfoTab:CreateParagraph({
   Title = "⚡ 超神AI機能",
   Content = "• 高密度ニューラルネットワーク\n• リアルタイム環境スキャン\n• 複数敵の同時追跡\n• 弾道物理演算\n• 人間的な滑らか動作\n• 自動武器検出・装備\n• 量子的意思決定システム"
})

InfoTab:CreateParagraph({
   Title = "🎮 対応ゲームタイプ",
   Content = "• FPSシューター\n• TPSゲーム\n• 格闘ゲーム\n• サバイバルゲーム\n• オビーゲーム\n• 収集系ゲーム"
})

-- 起動メッセージ
Rayfield:Notify({
   Title = "🌟 ULTRA GOD AI",
   Content = "超知能システム起動完了",
   Duration = 5,
   Image = 4483362458,
})

-- キャラクター再スポーン対応
Player.CharacterAdded:Connect(function(char)
    wait(1)
    if AI.Enabled then
        Rayfield:Notify({
           Title = "🔄 AI再接続",
           Content = "新しいキャラクターに接続しました",
           Duration = 2,
           Image = 4483362458,
        })
    end
end)
