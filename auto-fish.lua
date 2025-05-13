local FishGame = require(game:GetService("ReplicatedStorage").Library.Client.EventFishingCmds.Game)

if not FishGame.BeginOld then
    FishGame.BeginOld = FishGame.Begin
end

FishGame.Begin = function(arg1, arg2, arg3)
    arg2.BarSize=1
    return FishGame.BeginOld(arg1, arg2, arg3)
end
