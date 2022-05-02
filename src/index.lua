local localPlayer = game.Players.LocalPlayer;
local LocalizationService = game:GetService("LocalizationService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService");


local Data = game:HttpGet("https://raw.githubusercontent.com/Ix1x0x3/eurus/main/lib/data.json");
Data = HttpService:JSONDecode(Data);

local Eurus = {};

Eurus.Commands = {};

Eurus.ScriptData = {
    FileName = "DATA_SCRIPT.json";
    Prefix = ",";
    ScriptName = "MyAdmin";
    NotifCache = {}
}

Eurus.Loops = {};

Eurus.RegisteredPlayers = {};

Eurus.RawCommandRan = Instance.new("BindableEvent");
Eurus.CommandRan = Eurus.RawCommandRan.Event

-- make cmdbar
local CmdGui = Instance.new("ScreenGui", game.CoreGui);
CmdGui.IgnoreGuiInset = true
local CmdTop = Instance.new("Frame", CmdGui)
CmdTop.BackgroundColor3 = Color3.fromRGB(22, 20, 14)
CmdTop.Size = UDim2.new(1, 0, 0.2, 0)
CmdTop.BorderSizePixel = 0
CmdTop.Visible = false
local CmdPrompt = Instance.new("TextBox", CmdTop)
CmdPrompt.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
CmdPrompt.BackgroundTransparency = 0.7
CmdPrompt.Position = UDim2.new(0,0,0.13,0)
CmdPrompt.Size = UDim2.new(1,0,0.87,0)
CmdPrompt.TextScaled = true;
CmdPrompt.Font = Enum.Font.Code;
CmdPrompt.PlaceholderText = "command here"
CmdPrompt.TextXAlignment = Enum.TextXAlignment.Left;
CmdPrompt.TextYAlignment = Enum.TextYAlignment.Center;
CmdPrompt.TextColor3 = Color3.new(1,1,1)
local CmdPromptPredict = Instance.new("TextLabel", CmdTop)
CmdPromptPredict.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
CmdPromptPredict.BackgroundTransparency = 0.7
CmdPromptPredict.Position = UDim2.new(0,0,0.13,0)
CmdPromptPredict.Size = UDim2.new(1,0,0.87,0)
CmdPromptPredict.TextScaled = true;
CmdPromptPredict.Font = Enum.Font.Code;
CmdPromptPredict.TextXAlignment = Enum.TextXAlignment.Left;
CmdPromptPredict.TextColor3 = Color3.new(1,1,1)
CmdPromptPredict.TextYAlignment = Enum.TextYAlignment.Center;
CmdPromptPredict.TextTransparency = 0.5
CmdPromptPredict.Text = "";

function Eurus:Notify(Txt, Time, Tag)
    local NotifGui = game.CoreGui:FindFirstChild("EURUS");

        if not NotifGui then
            NotifGui = Instance.new("ScreenGui", game.CoreGui);
            NotifGui.Name = "EURUS";
        end

        local Ntif = Instance.new("TextLabel", NotifGui)
        Ntif.Position = UDim2.new(0.5, 0, 0.9, 0);
        Ntif.Size = UDim2.new(1,0,0.25,0);
        Ntif.TextTransparency = 1;
        Ntif.Text = Tag and "["..Tag.."] "..Txt or Txt
        Ntif.BackgroundTransparency = 1;
        Ntif.Font = Enum.Font.SourceSansSemibold;
        Ntif.AnchorPoint = Vector2.new(0.5, 0.5)
        Ntif.TextSize = 32;
        Ntif.TextColor3 = Color3.new(0.8,0.8,0.8)

        table.insert(Eurus.NotifCache, Ntif)

        game.TweenService:Create(
            Ntif,
            TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
            {
                Position = UDim2.new(0.5,0,0.8-(#Eurus.NotifCache*0.05),0);
                TextTransparency = 0;
            }
        ):Play()

        local CanLeave = false;
        local IgnoreDelay = false;

        Ntif.MouseEnter:Connect(function()
            CanLeave = true
            Ntif.TextColor3 = Color3.new(1,1,1)
        end)

        Ntif.MouseLeave:Connect(function()
            CanLeave = false;
            Ntif.TextColor3 = Color3.new(0.8,0.8,0.8)
        end)

        localPlayer:GetMouse().Button1Down:Connect(function()
            if CanLeave then
                IgnoreDelay = true;
                game.TweenService:Create(
                    Ntif,
                    TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
                    {
                        TextTransparency = 1;
                        Position = UDim2.new(0.5, 0, 0.9, 0);
                    }
                ):Play()
                table.remove(Eurus.NotifCache, table.find(Eurus.NotifCache, Ntif))
            end
        end)

        delay(Time or 5, function()
            if not IgnoreDelay then
                game.TweenService:Create(
                    Ntif,
                    TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
                    {
                        TextTransparency = 1;
                        Position = UDim2.new(0.5, 0, 0.9, 0);
                    }
                ):Play()
                table.remove(Eurus.NotifCache, table.find(Eurus.NotifCache, Ntif))
            end
        end)
end

function Eurus:WriteFile(FileName, Data)
	writefile(FileName, HttpService:JSONEncode(Data))
end

function Eurus:SetScriptData(Data)
    Eurus.ScriptData = Data;
end

function Eurus:ReadFile(FileName)
	return HttpService:JSONDecode(readfile(FileName))
end

function Eurus:AppendData(FileName, Name, Val)
    local ExistingData = ReadFile(FileName);
    if ExistingData[Name] ~= nil then
        ExistingData[Name] = Val
    end

    writefile(FileName, ExistingData);
end

function Eurus:WriteGenv(name, val)
    getgenv()[name] = val;
end

function Eurus:ReadGenv(name)
    if not getgenv()[name] then
        Eurus:Notify('An internal error has occured! Check console to see the error.', 5, "Eurus")
        return print("ReadGenv has failed: "..name.." does not exist in genv.")
    end

    return getgenv()[name];
end

function Eurus:AddCommand(Name, Aliases, Info, Code)
    print(Code, Name, Aliases, Info)
	
    Eurus.Commands[Name] = {
        Aliases = Aliases;
        Info = Info;
        Run = Code;
    }
end

function Eurus:RegisterPlayer(Player, Data)
    if not Player then return Eurus:Notify("An internal error has occured! Check console to see the error.", 5, "Eurus") end;
    Eurus.RegisteredPlayers[Player] = Data;
end

function Eurus:Chat(Text, WhisperTo)
    if WhisperTo then
        return game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("/w "..WhisperTo.Name.." "..Text, "All") -- sends your message to all players
    end
    return game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(Text, "All") -- sends your message to all players
end

function LocalChatted(Msg)
    if not string.sub(Msg,1,string.len(Eurus.ScriptData.Prefix))==Eurus.ScriptData.Prefix then return end;
    local function CmdCheck(Name)
        local temp1 = Msg:split(" ");
        local temp2 = temp1[1]:gsub(Eurus.ScriptData.Prefix, ""):lower()
        local CName = temp2;

        return Name == CName, CName;
    end

    local Ran = false;
    local Args = string.split(
        Msg,
        " "
    )
    
    table.remove(Args, 1);

    for i,Command in pairs(Eurus.Commands) do
        local IsRan = CmdCheck(i);

        -- main name
        if IsRan then
            Ran = true
            Eurus.RawCommandRan:Fire(localPlayer, i, Args)
            return Command.Run(localPlayer, Args)
        end

        for aNum,Alias in pairs(Command.Aliases) do
            IsRan = CmdCheck(Alias)

            if IsRan and not Ran then
                Ran = true
		Eurus.RawCommandRan:Fire(localPlayer, i, Args)
                return Command.Run(localPlayer, Args)
            end
        end
    end

    if not Ran and string.sub(Msg,1,string.len(Eurus.ScriptData.Prefix))==Eurus.ScriptData.Prefix then
        Eurus:Notify("Invalid command!", 5, "Eurus")
    end
end

Eurus.Loops.ChatL = localPlayer.Chatted:Connect(LocalChatted)

local function AdminChatted(Plr, Msg)
    if not string.sub(Msg,1,string.len(Eurus.ScriptData.Prefix))==Eurus.ScriptData.Prefix then return end;
    local function CmdCheck(Name)
        local temp1 = Msg:split(" ");
        local temp2 = temp1[1]:gsub(Eurus.ScriptData.Prefix, ""):lower()
        local CName = temp2;

        return Name == CName, CName;
    end

    local Ran = false;
    local Args = string.split(
        Msg,
        " "
    )
    table.remove(Args, 1);

    for i,Command in pairs(Eurus.Commands) do
        local IsRan = CmdCheck(i);

        -- main name
        if IsRan then
            Ran = true
            if Command.PermLevel and Eurus.RegisteredPlayers[Plr.UserId].Rank then
                if Eurus.RegisteredPlayers[Plr.UserId].Rank >= Command.PermLevel then
		    Eurus.RawCommandRan:Fire(localPlayer, i, Args)
                    return Command.Run(Plr, Args)
                end
            else
		Eurus.RawCommandRan:Fire(localPlayer, i, Args)
                return Command.Run(Plr, Args)
            end
        end

        for aNum,Alias in pairs(Command.Aliases) do
            IsRan = CmdCheck(Alias)

            if IsRan and not Ran then
                Ran = true
                if Command.PermLevel and Eurus.RegisteredPlayers[Plr.UserId].Rank then
                    if Eurus.RegisteredPlayers[Plr.UserId].Rank >= Command.PermLevel then
			Eurus.RawCommandRan:Fire(localPlayer, i, Args)
                        return Command.Run(Plr, Args)
                    end
                else
		    Eurus.RawCommandRan:Fire(localPlayer, i, Args)
                    return Command.Run(Plr, Args)
                end
            end
        end
    end

    if not Ran and string.sub(Msg,1,string.len(Eurus.ScriptData.Prefix))==Eurus.ScriptData.Prefix then
        Eurus:Chat("Invalid command!", Plr)
    end
end

for i,Player in pairs(game.Players:GetPlayers()) do
    Player.Chatted:Connect(function(Msg)
        if Eurus.RegisteredPlayers[Player] ~= nil then
            AdminChatted(Player, Msg)
        end
    end)
end

game.Players.PlayerAdded:Connect(function(Player)
    Player.Chatted:Connect(function(Msg)
        if Eurus.RegisteredPlayers[Player] ~= nil then
            AdminChatted(Player, Msg)
        end
    end)
end)

pcall(function() Eurus:Notify("EurusLib "..(Data.version.beta == true and "b" or "v")..Data.version.majorRel.."."..Data.version.minorRel.."."..Data.version.smallRel, 5, "Eurus") end)

-- cmd bar
UserInputService.InputBegan:Connect(function(Input, _)
    if not _ then
        if Input.KeyCode == Enum.KeyCode.Semicolon then
            CmdTop.Visible = true
            CmdPrompt:CaptureFocus()
            CmdPrompt.Text = ""
        end

        if Input.KeyCode == Enum.KeyCode.Tab then
            if CmdPromptPredict.Text ~= "" then
                CmdPrompt.Text = CmdPromptPredict.Text
            end
        end
    end
end)

CmdPrompt.FocusLost:Connect(function(e)
    if e and CmdTop.Visible then
        CmdTop.Visible = false
        CmdPrompt:ReleaseFocus()
        LocalChatted(CmdPrompt.Text)
        CmdPrompt.Text = ""
    end
end)

coroutine.wrap(function()
    RunService.Heartbeat:Connect(function()
        CmdPrompt.Text = string.gsub(CmdPrompt.Text, ";", "")

        -- find commands matching text in cmdprompt
        local function Check(str)
            for name, cmd in pairs(Eurus.Commands) do
                if (name:lower()):match(str) then
                    return name
                end
            end
		end

        local predicted = Check(CmdPrompt.Text)

        if predicted then
            CmdPromptPredict.Text = predicted
        else
            CmdPromptPredict.Text = ""
        end

        if CmdPrompt.Text == "" then
            CmdPromptPredict.Text = ""
        end
    end)
end)()

return Eurus;
