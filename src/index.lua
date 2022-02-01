local localPlayer = game.Players.LocalPlayer;
local HttpService = game:GetService("HttpService");

local Eurus = {};

Eurus.Commands = {};

Eurus.ScriptData = {
    FileName = "DATA_SCRIPT.json";
    Prefix = ",";
    ScriptName = "MyAdmin"
}

Eurus.Loops = {};

Eurus.RegisteredPlayers = {};

function Eurus:Notify(Text, Color, TagR)
    local Tag = Eurus.ScriptData.ScriptName;
    if TagR then
        Tag = TagR;
        if TagR == false then Tag = false; end;
    end
    if TagR == false then
        return game.StarterGui:SetCore("ChatMakeSystemMessage", {
            Text = Text,
            Color = Color or Color3.new(1,1,1),
            Font = Enum.Font.Code,
            FontSize = Enum.FontSize.Size14
        })
    end
    return game.StarterGui:SetCore("ChatMakeSystemMessage", {
        Text = "["..Tag.."]: "..Text,
        Color = Color or Color3.new(1,1,1),
        Font = Enum.Font.Code,
        FontSize = Enum.FontSize.Size14
    })
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
        Eurus:Notify('An internal error has occured! Check console to see the error.',Color3.new(1,0,0))
        return print("ReadGenv has failed: "..name.." does not exist in genv.")
    end

    return getgenv()[name];
end

function Eurus:AddCommand(Name, Aliases, Info, Code)
    Eurus.Commands[Name] = {
        Aliases = Aliases;
        Info = Info;
        Run = Code;
    }
end

function Eurus:RegisterPlayer(Player, Data)
    if not Player then return Eurus:Notify("An internal error has occured1 Check console to see the error.", Color3.new(1,0,0)) end;
    Eurus.RegisteredPlayers[Player.UserId] = Data;
end

function Eurus:Chat(Text, WhisperTo)
    if WhisperTo then
        return game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("/w "..WhisperTo.Name.." "..Text, "All") -- sends your message to all players
    end
    return game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(Text, "All") -- sends your message to all players
end

Eurus.Loops.ChatL = localPlayer.Chatted:Connect(function(Msg)
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
            return Command.Run(localPlayer, Args)
        end

        for aNum,Alias in pairs(Command.Aliases) do
            IsRan = CmdCheck(Alias)

            if IsRan and not Ran then
                Ran = true
                return Command.Run(Plr, Args)
            end
        end
    end

    if not Ran and string.sub(Msg,1,string.len(Eurus.ScriptData.Prefix))==Eurus.ScriptData.Prefix then
        Eurus:Notify("Invalid command!")
    end
end)

local function AdminChatted(Plr, Msg)
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
                    return Command.Run(Plr, Args)
                end
            else
                return Command.Run(Plr, Args)
            end
        end

        for aNum,Alias in pairs(Command.Aliases) do
            IsRan = CmdCheck(Alias)

            if IsRan and not Ran then
                Ran = true
                if Command.PermLevel and Eurus.RegisteredPlayers[Plr.UserId].Rank then
                    if Eurus.RegisteredPlayers[Plr.UserId].Rank >= Command.PermLevel then
                        return Command.Run(Plr, Args)
                    end
                else
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
        if not Eurus.RegisteredPlayers[Player.UserId] == nil then
            AdminChatted(Player, Msg)
        end
    end)
end

game.Players.PlayerAdded:Connect(function(Player)
    Player.Chatted:Connect(function(Msg)
        if not Eurus.RegisteredPlayers[Player.UserId] == nil then
            AdminChatted(Player, Msg)
        end
    end)
end)

Eurus:Notify("EurusLib b0.4.1 has loaded.", Color3.new(1,1,0), "INFO")

return Eurus;
