// Credit to GibbableCorpsesv5 by Aspide for figuring out these requirements

class ERRoster extends xDMRoster
    hidecategories(Movement,Collision,Lighting,LightColor,Karma,Force);

function bool AddToTeam(Controller Other)
{
    local SquadAI DMSquad;

    // End:0x4E
    if(Bot(Other) != none)
    {
        DMSquad = spawn(DeathMatch(Level.Game).DMSquadClass);
        DMSquad.AddBot(Bot(Other));
    }
    Other.PlayerReplicationInfo.Team = none;
    Other.PawnClass = DefaultPlayerClass;
    return true;
    //return;    
}

defaultproperties
{
    DefaultPlayerClass=Class'BetterBodies.ExtendedRagdollPawn'
}