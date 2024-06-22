class ExtendedRagdollPawn extends xPawn
    config(User);

var() float RagdollLifeTime;
var bool bImportantRagdoll;

simulated function PostBeginPlay()
{
    super.PostBeginPlay();
    RagdollLifeSpan = RagdollLifeTime;
    DeResTime = 5.0;
    Log("ExtendedRagdollPawn - RagdollLifeSpan Extended to " @ RagdollLifeTime);
}

state Dying
{

	simulated function AnimEnd( int Channel )
    {
        ReduceCylinder();
    }

	event FellOutOfWorld(eKillZType KillType)
	{
		local LavaDeath LD;

		// If we fall past a lava killz while dead- burn off skin.
		if( KillType == KILLZ_Lava )
		{
			if ( !bSkeletized )
			{
				if ( SkeletonMesh != None )
				{
					LinkMesh(SkeletonMesh, true);
					Skins.Length = 0;
				}
				bSkeletized = true;

				LD = spawn(class'LavaDeath', , , Location + vect(0, 0, 10), Rotation );
				if ( LD != None )
					LD.SetBase(self);
				// This should destroy itself once its finished.

				PlaySound( sound'WeaponSounds.BExplosion5', SLOT_None, 1.5*TransientSoundVolume );
			}

			return;
		}

		Super.FellOutOfWorld(KillType);
	}

    function LandThump()
    {
        // animation notify - play sound if actually landed, and animation also shows it
        if ( Physics == PHYS_None)
        {
            bThumped = true;
            PlaySound(GetSound(EST_CorpseLanded));
        }
    }

    simulated function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> damageType)
    {
        local Vector SelfToHit, SelfToInstigator, CrossPlaneNormal;
        local float W;
        local float YawDir;

        local Vector HitNormal, shotDir;
        local Vector PushLinVel, PushAngVel;
        local Name HitBone;
        local float HitBoneDist;
        local int MaxCorpseYawRate;

		if ( bFrozenBody || bRubbery )
			return;

		if( Physics == PHYS_KarmaRagdoll )
		{
			// Can't shoot corpses during de-res
			if( bDeRes || bRubbery )
				return;

			// Throw the body if its a rocket explosion or shock combo
			if( damageType.Default.bThrowRagdoll )
			{
				shotDir = Normal(Momentum);
                PushLinVel = (RagDeathVel * shotDir) +  vect(0, 0, 250);
				PushAngVel = Normal(shotDir Cross vect(0, 0, 1)) * -18000;
				KSetSkelVel( PushLinVel, PushAngVel );
			}
			else if( damageType.Default.bRagdollBullet )
			{
				if ( Momentum == vect(0,0,0) )
					Momentum = HitLocation - InstigatedBy.Location;
				if ( FRand() < 0.65 )
				{
					if ( Velocity.Z <= 0 )
						PushLinVel = vect(0,0,40);
					PushAngVel = Normal(Normal(Momentum) Cross vect(0, 0, 1)) * -8000 ;
					PushAngVel.X *= 0.5;
					PushAngVel.Y *= 0.5;
					PushAngVel.Z *= 4;
					KSetSkelVel( PushLinVel, PushAngVel );
				}
                PushLinVel = RagShootStrength*Normal(Momentum);
				KAddImpulse(PushLinVel, HitLocation);
				if ( (LifeSpan > 0) && (LifeSpan < DeResTime + 2) )
					LifeSpan += 0.2;
			}
			else
			{
                PushLinVel = RagShootStrength*Normal(Momentum);
				KAddImpulse(PushLinVel, HitLocation);
			}
			if ( (DamageType.Default.DamageOverlayMaterial != None) && (Level.DetailMode != DM_Low) && !Level.bDropDetail )
				SetOverlayMaterial(DamageType.Default.DamageOverlayMaterial, DamageType.default.DamageOverlayTime, true);
			return;
		}

        if ( DamageType.default.bFastInstantHit && GetAnimSequence() == 'Death_Spasm' && RepeaterDeathCount < 6)
        {
            PlayAnim('Death_Spasm',, 0.2);
            RepeaterDeathCount++;
        }
        else if (Damage > 0)
        {
			if ( InstigatedBy != None )
			{
				if ( InstigatedBy.IsA('xPawn') && xPawn(InstigatedBy).bBerserk )
					Damage *= 2;

				// Figure out which direction to spin:

				if( InstigatedBy.Location != Location )
				{
					SelfToInstigator = InstigatedBy.Location - Location;
					SelfToHit = HitLocation - Location;

					CrossPlaneNormal = Normal( SelfToInstigator cross Vect(0,0,1) );
					W = CrossPlaneNormal dot Location;

					if( HitLocation dot CrossPlaneNormal < W )
						YawDir = -1.0;
					else
						YawDir = 1.0;
				}
			}
            if( VSize(Momentum) < 10 )
            {
                Momentum = - Normal(SelfToInstigator) * Damage * 1000.0;
                Momentum.Z = Abs( Momentum.Z );
            }

            SetPhysics(PHYS_Falling);
            Momentum = Momentum / Mass;
            AddVelocity( Momentum );
            bBounce = true;

            RotationRate.Pitch = 0;
            RotationRate.Yaw += VSize(Momentum) * YawDir;

            MaxCorpseYawRate = 150000;
            RotationRate.Yaw = Clamp( RotationRate.Yaw, -MaxCorpseYawRate, MaxCorpseYawRate );
            RotationRate.Roll = 0;

            bFixedRotationDir = true;
            bRotateToDesired = false;

            Health -= Damage;
            CalcHitLoc( HitLocation, vect(0,0,0), HitBone, HitBoneDist );

            if( InstigatedBy != None )
                HitNormal = Normal( Normal(InstigatedBy.Location-HitLocation) + VRand() * 0.2 + vect(0,0,2.8) );
            else
                HitNormal = Normal( Vect(0,0,1) + VRand() * 0.2 + vect(0,0,2.8) );

            DoDamageFX( HitBone, Damage, DamageType, Rotator(HitNormal) );
        }
    }

    simulated function BeginState()
	{
		Super.BeginState();
		AmbientSound = None;
 	}

    simulated function Timer()
    {
        local KarmaParamsSkel skelParams;
		skelParams.bKImportantRagdoll = true;
		if ( LifeSpan <= DeResTime && bDeRes == false )
        {
            skelParams = KarmaParamsSkel(KParams);

            if ( (PlayerController(OldController) != None) && (PlayerController(OldController).ViewTarget == self)
                && (Viewport(PlayerController(OldController).Player) != None) )
            {
                skelParams.bKImportantRagdoll = true;
                LifeSpan = FMax(LifeSpan,DeResTime + 2.0);
                SetTimer(1.0, false);
                return;
            }
            else
            {
                skelParams.bKImportantRagdoll = false;
            }
            StartDeRes();
        }
        else
        {
            SetTimer(1.0, false);
        }
    }

    event KVelDropBelow()
    {
        // Prevent reducing lifespan when the velocity drops below a threshold
        Log("Preventing lifespan reduction on low velocity.");
        LifeSpan = RagdollLifeTime;
    }
}


simulated function SpawnGiblet( class<Gib> GibClass, Vector Location, Rotator Rotation, float GibPerterbation )
{
    local Gib Giblet;
    local Vector Direction, Dummy;

    if( (GibClass == None) || class'GameInfo'.static.UseLowGore() )
        return;

	Instigator = self;
    Giblet = Spawn( GibClass,,, Location, Rotation );
    if( Giblet == None )
        return;
	Giblet.bFlaming = bFlaming;
	Giblet.SpawnTrail();

    GibPerterbation *= 32768.0;
    Rotation.Pitch += ( FRand() * 2.0 * GibPerterbation ) - GibPerterbation;
    Rotation.Yaw += ( FRand() * 2.0 * GibPerterbation ) - GibPerterbation;
    Rotation.Roll += ( FRand() * 2.0 * GibPerterbation ) - GibPerterbation;

    GetAxes( Rotation, Dummy, Dummy, Direction );

    Giblet.Velocity = Velocity + Normal(Direction) * (250 + 260 * FRand());
    //Giblet.LifeSpan = Giblet.LifeSpan + 2 * FRand() - 1;
	Giblet.LifeSpan = RagdollLifeTime;
}

defaultproperties
{
    RagdollLifeTime=300.0
    DeResTime=3.0
}
