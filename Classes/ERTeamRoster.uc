// Credit to GibbableCorpsesv5 by Aspide for figuring out these requirements

class ERTeamRoster extends xTeamRoster
    hidecategories(Movement,Collision,Lighting,LightColor,Karma,Force);

function bool AddToTeam(Controller Other)
{
    local bool bResult;

    bResult = super(UnrealTeamInfo).AddToTeam(Other);
    Other.PawnClass = DefaultPlayerClass;
    return bResult;
    //return;    
}

defaultproperties
{
    DefaultPlayerClass=Class'BetterBodies.ExtendedRagdollPawn'
}