spawn(function()
    function click()
        local v = game:GetService("VirtualInputManager")
        while task.wait() do
            v:SendMouseButtonEvent(0,0,0, true,game, 1)
            task.wait()
            v:SendMouseButtonEvent(0,0,0, false,game, 1)
        end
    end
    click()
end)
function TP(vu)
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = vu
    end
    function Get_Quest(vu)
        game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild("GameEvent"):FireServer("Quest",vu)
    end
    local Lv = game:GetService("Players").LocalPlayer.Level.Value
    function Data()
    if Lv >= 0 and Lv <= 14 then
        M_N = "Thug [Level 5]"
        Q_C = CFrame.new(184.155289, 2.38432837, -63.5226097, -0.342042685, 0, -0.939684391, 0, 1, 0, 0.939684391, 0, -0.342042685)
    elseif Lv >= 15 and Lv <= 19 then
        M_N = "HumonUser [Level 15]"
        Q_C = CFrame.new(179.064499, 3.00752449, -277.257904, 0.676719844, 0.000578344858, -0.736240387, -0.000370113004, 0.999999821, 0.000445346348, 0.736240506, -2.88825831e-05, 0.676719964)
    elseif Lv >= 20 and Lv <= 29 then
        M_N = "Gryphon [Level 30]"
        Q_C = CFrame.new(97.4313889, 3.27583885, -442.111755, -0.000121831894, -0.00042729819, 0.999999881, -0.00042729819, 0.999999821, 0.000427246065, -0.999999881, -0.000427246065, -0.000122070312)
    elseif Lv >= 30 and Lv <= 39 then
        M_N = "Vampire [Level 40]"
        Q_C = CFrame.new(36.4484291, 3.30884743, -695.673462, -0.182368279, -0.000453423447, 0.983230472, -0.000343037042, 0.999999881, 0.00039753085, -0.983230472, -0.000264787464, -0.182368398)
    elseif Lv >= 40 and Lv <= 69 then
        M_N = "Snowman [Level 65]"
        Q_C = CFrame.new(1523.32544, -52.172142, -35.5743408, -0.986970186, 0.00232449896, 0.160887003, 0.000945004635, 0.999962151, -0.00865029264, -0.16090101, -0.00838554185, -0.986935019)
    elseif Lv >= 70 and Lv <= 89 then
        M_N = "Wammu"
        Q_C = CFrame.new(1524.604, -52.2924805, -49.5155334, -0.982467294, 0.00232620677, -0.186421111, 0.00386162335, 0.999961555, -0.00787357707, 0.18639563, -0.00845541898, -0.982438564)
    elseif Lv >= 90 and Lv <= 109 then
        M_N = "Desert Bandit [Level 95]"
        Q_C = CFrame.new(-680.960999, 22.3726921, 45.0184784, 0.609251022, -7.40688411e-05, 0.792977393, -0.000383795385, 0.999999821, 0.000388279092, -0.792977273, -0.00054090051, 0.609250903)
    elseif Lv >= 110 and Lv <= 139 then
        M_N = "Desert Monster [Level 120]"
        Q_C = CFrame.new(-672.915405, 21.7933769, -12.8314972, 0.89071238, 0.000584296882, -0.454566956, -0.00042286783, 0.999999821, 0.000456793408, 0.454567134, -0.000214649786, 0.89071244)
    elseif Lv >= 140 and Lv <= 169 then
        M_N = "Dio Guard [Level 165]"
        Q_C = CFrame.new(-1333.58813, 22.6517334, 218.4814, 0, 0, 1, 0, 1, -0, -1, 0, 0)
    elseif Lv >= 170 and Lv <= 249 then
        M_N = "Dio Royal Guard [Level  180]"
        Q_C = CFrame.new(-1557.45654, 24.7708988, 72.5477371, 1, 0, 0, 0, 1, 0, 0, 0, 1)
    elseif Lv >= 250 and Lv <= 274 then
        M_N = "School Bully  [Level 270]"
        Q_C = CFrame.new(289.279297, 3, 874.353882, 0, 0, 1, 0, 1, -0, -1, 0, 0)
    elseif Lv >= 275 and Lv <= 299 then
        M_N = "City Criminal  [Level 280]"
        Q_C = CFrame.new(115.395645, 3.71079493, 760.623413, -0.765645862, -0.0251172073, -0.642772257, -0.0327921696, 0.999462187, 5.41098416e-06, 0.642426431, 0.0210820362, -0.76605773)
    elseif Lv >= 300 and Lv <= 99999 then
        M_N = "Criminal Master [Level 300]"
        Q_C = CFrame.new(356.843811, 0.0181660354, 742.580505, 1, 0, 0, 0, 1, 0, 0, 0, 1)
        end
    end
    spawn(function()
        while task.wait() do
            pcall(function()
            if game:GetService("Players").LocalPlayer.PlayerGui.QuestGui.QuestTag.Visible == false then
                Data()
                TP(Q_C)
                wait(0.5)
                Get_Quest(M_N)
                else
                Data()
                    for _,v in pairs(workspace.Enemies:GetChildren()) do
                        if v.Name == M_N and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                            TP(v.HumanoidRootPart.CFrame*CFrame.new(0, 6.4, 0)*CFrame.Angles(math.rad(-90), 0, 0))
                            return 
                        end
                    end
                end
            end)
        end
    end)