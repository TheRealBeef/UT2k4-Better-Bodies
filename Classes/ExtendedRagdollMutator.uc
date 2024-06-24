class ExtendedRagdollMutator extends Mutator
	config(ExtRag)
	hidecategories(Movement,Collision,Lighting,LightColor,Karma,Force);

var() config float RagdollLifespanModded;	
var() config int MaxRagdollsModded;

function PreBeginPlay()
{
    super.PreBeginPlay();
	
    // Set the custom LevelInfo class
    // Set the max number of ragdolls
    if (Level != none)
    {
        Level.MaxRagdolls = MaxRagdollsModded;
    }
	
	
    Level.Game.DefaultPlayerClassName = "BetterBodies.ExtendedRagdollPawn";
    // End:0x92
    if(TeamGame(Level.Game) != none)
    {
        TeamGame(Level.Game).DefaultEnemyRosterClass = "BetterBodies.ERTeamRoster";
    }
    else
    {
        // End:0xE4
        if(DeathMatch(Level.Game) != none)
        {
            DeathMatch(Level.Game).DefaultEnemyRosterClass = "BetterBodies.ERRoster";
        }
    }
    //return;    
}

function PlayerChangedClass(Controller C)
{
    super.PlayerChangedClass(C);
    // End:0x64
    if((Bot(C) != none) && (C.PawnClass == none) || C.PawnClass == Class'XGame.xPawn')
    {
        Bot(C).PawnClass = Class'BetterBodies.ExtendedRagdollPawn';
    }
    //return;    
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
   if (Other != none)
    {
		// End:0x66
		if((PlayerController(Other) != none) && (Controller(Other).PawnClass == none) || Controller(Other).PawnClass == Class'XGame.xPawn')
		{
			PlayerController(Other).PawnClass = Class'BetterBodies.ExtendedRagdollPawn';
		}
		else
		{
			// End:0xC9
			if((Bot(Other) != none) && (Controller(Other).PawnClass == none) || Controller(Other).PawnClass == Class'XGame.xPawn')
			{
				Bot(Other).PreviousPawnClass = Class'BetterBodies.ExtendedRagdollPawn';
			}
		}
		return super.CheckReplacement(Other, bSuperRelevant);
		//return;    
	}
}

function ModifyPlayer(Pawn Other)
{
    // End:0x8F
    if (Other != none && ExtendedRagdollPawn(Other) != none)
    {
        ExtendedRagdollPawn(Other).RagdollLifeTime = RagdollLifespanModded;
    }

    // Call the next mutator's ModifyPlayer function if NextMutator is not None
    if (NextMutator != none)
    {
        NextMutator.ModifyPlayer(Other);
    }
    //return;    
}


defaultproperties
{
    RagdollLifespanModded=300.0000000
    bAddToServerPackages=true
	MaxRagdollsModded=256
    FriendlyName="Better Bodies"
    Description="Increases the time that ragdolls exist and prevents them from despawning."
    bAlwaysRelevant=true
    RemoteRole=2
}