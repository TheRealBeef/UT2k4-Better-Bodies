class ExtendedRagdollPawn extends xPawn
    config(BetterBodies);

var() bool bHeadSevered;
var() bool bLThighSevered;
var() bool bRThighSevered;
var() bool bLFArmSevered;
var() bool bRFArmSevered;
var() bool bSpineSevered;
var() int CertainGibness;
var() float RagdollLifeTime;
var() int CorpseTotalGibDamage;
var bool bImportantRagdoll;
var bool GibTheCorpse;
var bool GibTheFallingCorpse;
var() bool GibCorpseFallingDamage;
var() int GibCorpseFallingDamageSpeed;

simulated function PostBeginPlay()
{
    super.PostBeginPlay();
    RagdollLifeSpan = RagdollLifeTime;
    DeResTime = 5.0;
    Log("ExtendedRagdollPawn - RagdollLifeSpan Extended to " @ RagdollLifeTime);
}

event KImpact(Actor Other, Vector pos, Vector impactVel, Vector impactNorm)
{
    local float Speed;

    Speed = VSize(impactVel);
    super.KImpact(Other, pos, impactVel, impactNorm);
    // End:0x3F
    if(!GibCorpseFallingDamage || bSkeletized)
    {
        return;
    }
    // End:0x6C
    if((Speed > float(GibCorpseFallingDamageSpeed)) && GibTheCorpse)
    {
        GibTheFallingCorpse = true;
        SetTimer(0.0010000, false);
    }
    //return;    
}

simulated function SpawnBoneGiblet(name HitBone, xPawnGibGroup.EGibType gibType)
{
    local Vector BoneLocation;

    // End:0x66
    if(HitBone != 'None')
    {
        BoneLocation = GetBoneCoords(HitBone).Origin;
        spawn(GibGroupClass.static.GetGibClass(gibType), self,, BoneLocation, Rotation);
        spawn(GibGroupClass.static.GetBloodEmitClass(), self,, BoneLocation, Rotation);
    }
    //return;    
}

function DoGibDamageFX(name BoneName, int Damage, class<DamageType> DamageType, Rotator R)
{
    local bool bExtraGib;

    // End:0x4CE
    if(((FRand() > 0.3000000) || Damage > 30) || Health <= 0)
    {
        HitFx[HitFxTicker].damtype = DamageType;
        HitFx[HitFxTicker].bSever = false;
        // End:0x91
        if(DamageType.default.bAlwaysSevers || Damage == 1000)
        {
            HitFx[HitFxTicker].bSever = true;
            bExtraGib = true;            
        }
        else
        {
            // End:0x114
            if((FRand() < Abs((float(Health) - (float(Damage) * DamageType.default.GibModifier)) / 130.0000000)) || ((float(Damage) * DamageType.default.GibModifier) > (float(50) + (float(120) * FRand()))) && (Damage + Health) > 0)
            {
                HitFx[HitFxTicker].bSever = true;
            }
        }
        // End:0x12C
        if(!HitFx[HitFxTicker].bSever)
        {
            return;
        }
        // End:0x186
        if((BoneName == 'lfoot') || BoneName == 'lthigh')
        {
            BoneName = 'lthigh';
            // End:0x17B
            if(bLThighSevered)
            {
                HitFx[HitFxTicker].bSever = false;
                bExtraGib = false;
            }
            bLThighSevered = true;            
        }
        else
        {
            // End:0x1E0
            if((BoneName == 'rfoot') || BoneName == 'rthigh')
            {
                BoneName = 'rthigh';
                // End:0x1D5
                if(bRThighSevered)
                {
                    HitFx[HitFxTicker].bSever = false;
                    bExtraGib = false;
                }
                bRThighSevered = true;                
            }
            else
            {
                // End:0x21E
                if(BoneName == 'head')
                {
                    // End:0x213
                    if(bHeadSevered)
                    {
                        HitFx[HitFxTicker].bSever = false;
                        bExtraGib = false;
                    }
                    bHeadSevered = true;                    
                }
                else
                {
                    // End:0x278
                    if((BoneName == 'rhand') || BoneName == 'rfarm')
                    {
                        BoneName = 'rfarm';
                        // End:0x26D
                        if(bRFArmSevered)
                        {
                            HitFx[HitFxTicker].bSever = false;
                            bExtraGib = false;
                        }
                        bRFArmSevered = true;                        
                    }
                    else
                    {
                        // End:0x2D2
                        if((BoneName == 'lhand') || BoneName == 'lfarm')
                        {
                            BoneName = 'lfarm';
                            // End:0x2C7
                            if(bLFArmSevered)
                            {
                                HitFx[HitFxTicker].bSever = false;
                                bExtraGib = false;
                            }
                            bLFArmSevered = true;                            
                        }
                        else
                        {
                            // End:0x35F
                            if((((BoneName == 'rshoulder') || BoneName == 'lshoulder') || BoneName == 'spine') || BoneName == 'None')
                            {
                                BoneName = 'spine';
                                // End:0x333
                                if(FRand() < 0.2500000)
                                {
                                    bExtraGib = true;
                                }
                                // End:0x357
                                if(bSpineSevered)
                                {
                                    HitFx[HitFxTicker].bSever = false;
                                    bExtraGib = false;
                                }
                                bSpineSevered = true;
                            }
                        }
                    }
                }
            }
        }
        // End:0x3E3
        if((DamageType.default.bNeverSevers || Class'Engine.GameInfo'.static.UseLowGore()) || (Level.Game != none) && Level.Game.PreventSever(self, BoneName, Damage, DamageType))
        {
            HitFx[HitFxTicker].bSever = false;
            bExtraGib = false;
        }
        HitFx[HitFxTicker].Bone = BoneName;
        HitFx[HitFxTicker].rotDir = R;
        HitFxTicker = HitFxTicker + 1;
        // End:0x433
        if(HitFxTicker > (8 - 1))
        {
            HitFxTicker = 0;
        }
        // End:0x4CE
        if(bExtraGib)
        {
            // End:0x47F
            if(FRand() < 0.2500000)
            {
                DoGibDamageFX('lthigh', 1000, Class'DamTypeGibCorpse', R);
                DoGibDamageFX('rthigh', 1000, Class'DamTypeGibCorpse', R);                
            }
            else
            {
                // End:0x4A8
                if(FRand() < 0.3500000)
                {
                    DoGibDamageFX('lthigh', 1000, Class'DamTypeGibCorpse', R);                    
                }
                else
                {
                    // End:0x4CE
                    if(FRand() < 0.5000000)
                    {
                        DoGibDamageFX('rthigh', 1000, Class'DamTypeGibCorpse', R);
                    }
                }
            }
        }
    }
    //return;    
}

simulated function PlayGibHit(float Damage, Pawn instigatedBy, Vector HitLocation, class<DamageType> DamageType, Vector Momentum, name HitBone)
{
    local Vector HitNormal;
    local bool bRecentHit;
    local BloodSpurt BloodHit;

    // End:0x27
    if(((DamageType == none) || Damage <= float(0)) || bSkeletized)
    {
        return;
    }
    // End:0x196
    if(DamageType.default.bCausesBlood)
    {
        // End:0xB1
        if(Class'Engine.GameInfo'.static.UseLowGore())
        {
            // End:0x87
            if(Class'Engine.GameInfo'.static.NoBlood())
            {
                BloodHit = BloodSpurt(spawn(GibGroupClass.default.NoBloodHitClass, instigatedBy,, HitLocation));
            }
            else
            {
                BloodHit = BloodSpurt(spawn(GibGroupClass.default.LowGoreBloodHitClass, instigatedBy,, HitLocation));
            }            
        }
        else
        {
            BloodHit = BloodSpurt(spawn(GibGroupClass.default.BloodHitClass, instigatedBy,, HitLocation, Rotator(HitNormal)));
        }
        // End:0x196
        if(BloodHit != none)
        {
            BloodHit.bMustShow = !bRecentHit;
            // End:0x130
            if(Momentum != vect(0.0000000, 0.0000000, 0.0000000))
            {
                BloodHit.HitDir = Momentum;                
            }
            else
            {
                // End:0x162
                if(instigatedBy != none)
                {
                    BloodHit.HitDir = Location - instigatedBy.Location;                    
                }
                else
                {
                    BloodHit.HitDir = Location - HitLocation;
                }
                BloodHit.HitDir.Z = 0.0000000;
            }
        }
    }
    // End:0x214
    if((((DamageType.Name == 'DamTypeFlakChunk') && Health < 0) && instigatedBy != none) && VSize(instigatedBy.Location - Location) < float(350))
    {
        DoGibDamageFX(HitBone, int(float(8) * Damage), DamageType, Rotator(HitNormal));        
    }
    else
    {
        DoGibDamageFX(HitBone, int(Damage), DamageType, Rotator(HitNormal));
    }
    // End:0x278
    if((DamageType.default.DamageOverlayMaterial != none) && Damage > float(0))
    {
        SetOverlayMaterial(DamageType.default.DamageOverlayMaterial, DamageType.default.DamageOverlayTime, false);
    }
    //return;    
}

function TakeDamage(int Damage, Pawn instigatedBy, Vector HitLocation, Vector Momentum, class<DamageType> DamageType)
{
    local int actualDamage;
    local Controller Killer;
    local int FinalHealth;

    // End:0x6D
    if(DamageType == none)
    {
        // End:0x62
        if(instigatedBy != none)
        {
            warn("No damagetype for damage by "$instigatedby$" with weapon "$InstigatedBy.Weapon);
        }
        DamageType = Class'Engine.DamageType';
    }
    // End:0xB6
	if ( Role < ROLE_Authority )
	{
		log(self$" client damage type "$damageType$" by "$instigatedBy);
		return;
	}
    // End:0xC3
    if(Health <= 0)
    {
        return;
    }
    // End:0x119
    if ((instigatedBy == None || instigatedBy.Controller == None) && DamageType.default.bDelayedDamage && DelayedDamageInstigatorController != None)
    {
        instigatedBy = DelayedDamageInstigatorController.Pawn;
    }
    // End:0x13C
if ( (Physics == PHYS_None) && (DrivenVehicle == None) )
    {
        SetMovementPhysics();
    }
    // End:0x185
	if (Physics == PHYS_Walking && damageType.default.bExtraMomentumZ)
    {
        Momentum.Z = FMax(Momentum.Z, 0.4000000 * VSize(Momentum));
    }
    // End:0x19C
    if(instigatedBy == self)
    {
        Momentum *= 0.6000000;
    }
    Momentum = Momentum / Mass;
    // End:0x1E1
    if(Weapon != none)
    {
        Weapon.AdjustPlayerDamage(Damage, instigatedBy, HitLocation, Momentum, DamageType);
    }
    // End:0x214
    if(DrivenVehicle != none)
    {
        DrivenVehicle.AdjustDriverDamage(Damage, instigatedBy, HitLocation, Momentum, DamageType);
    }
    // End:0x23E
    if((instigatedBy != none) && instigatedBy.HasUDamage())
    {
        Damage *= float(2);
    }
    actualDamage = Level.Game.ReduceDamage(Damage, self, instigatedBy, HitLocation, Momentum, DamageType);
    // End:0x2A6
    if(DamageType.default.bArmorStops && actualDamage > 0)
    {
        actualDamage = ShieldAbsorb(actualDamage);
    }
    FinalHealth = Health - actualDamage;
    Health -= actualDamage;
    // End:0x2E6
    if(HitLocation == vect(0.0000000, 0.0000000, 0.0000000))
    {
        HitLocation = Location;
    }
    PlayHit(float(actualDamage), instigatedBy, HitLocation, DamageType, Momentum);
    // End:0x40C
    if(Health <= 0)
    {
        // End:0x359
        if((DamageType.default.bCausedByWorld && (instigatedBy == none) || instigatedBy == self) && LastHitBy != none)
        {
            Killer = LastHitBy;            
        }
        else
        {
            // End:0x379
            if(instigatedBy != none)
            {
                Killer = instigatedBy.GetKillerController();
            }
        }
        // End:0x3A3
        if((Killer == none) && DamageType.default.bDelayedDamage)
        {
            Killer = DelayedDamageInstigatorController;
        }
        // End:0x3B7
        if(bPhysicsAnimUpdate)
        {
            TearOffMomentum = Momentum;
        }
        // End:0x3F4
        if((FinalHealth <= CertainGibness) && !DamageType.default.bSpecial)
        {
            DiedGib(Killer, DamageType, HitLocation);            
        }
        else
        {
            Died(Killer, DamageType, HitLocation);
        }        
    }
    else
    {
        AddVelocity(Momentum);
        // End:0x44A
        if(Controller != none)
        {
            Controller.NotifyTakeHit(instigatedBy, HitLocation, actualDamage, DamageType, Momentum);
        }
        // End:0x476
        if((instigatedBy != none) && instigatedBy != self)
        {
            LastHitBy = instigatedBy.Controller;
        }
    }
    MakeNoise(1.0000000);
    //return;    
}

function DiedGib(Controller Killer, class<DamageType> DamageType, Vector HitLocation)
{
    local Vector TossVel;
    local Trigger t;
    local NavigationPoint N;

    // End:0x35
    if((bDeleteMe || Level.bLevelChange) || Level.Game == none)
    {
        return;
    }
    // End:0x7D
    if((DamageType.default.bCausedByWorld && (Killer == none) || Killer == Controller) && LastHitBy != none)
    {
        Killer = LastHitBy;
    }
    // End:0xB8
    if(Level.Game.PreventDeath(self, Killer, DamageType, HitLocation))
    {
        Health = Max(Health, 1);
        return;
    }
    Health = Min(0, Health);
    // End:0x173
    if((Weapon != none) && (DrivenVehicle == none) || DrivenVehicle.bAllowWeaponToss)
    {
        // End:0x11A
        if(Controller != none)
        {
            Controller.LastPawnWeapon = Weapon.Class;
        }
        Weapon.HolderDied();
        TossVel = Vector(GetViewRotation());
        TossVel = (TossVel * ((Velocity Dot TossVel) + float(500))) + vect(0.0000000, 0.0000000, 200.0000000);
        TossWeapon(TossVel);
    }
    // End:0x1A1
    if(DrivenVehicle != none)
    {
        Velocity = DrivenVehicle.Velocity;
        DrivenVehicle.DriverDied();
    }
    // End:0x1EB
    if(Controller != none)
    {
        Controller.WasKilledBy(Killer);
        Level.Game.Killed(Killer, Controller, self, DamageType);        
    }
    else
    {
        Level.Game.Killed(Killer, Controller(Owner), self, DamageType);
    }
    DrivenVehicle = none;
    // End:0x247
    if(Killer != none)
    {
        TriggerEvent(Event, self, Killer.Pawn);        
    }
    else
    {
        TriggerEvent(Event, self, none);
    }
    // End:0x2CE
    if((IsPlayerPawn()) || WasPlayerPawn())
    {
        PhysicsVolume.PlayerPawnDiedInVolume(self);
        // End:0x299
        foreach TouchingActors(Class'Engine.Trigger', t)
        {
            t.PlayerToucherDied(self);            
        }        
        // End:0x2CD
        foreach TouchingActors(Class'Engine.NavigationPoint', N)
        {
            // End:0x2CC
            if(N.bReceivePlayerToucherDiedNotify)
            {
                N.PlayerToucherDied(self);
            }            
        }        
    }
    RemovePowerups();
    Velocity.Z *= 1.3000000;
    // End:0x302
    if(IsHumanControlled())
    {
        PlayerController(Controller).ForceDeathUpdate();
    }
    // End:0x31D
    if(DamageType != none)
    {
        GibChunkUp(Rotation, DamageType);
    }
    //return;    
}

simulated function GibChunkUp(Rotator HitRotation, class<DamageType> DamageType)
{
    // End:0x57
    if((Level.NetMode != NM_Client) && Controller != none)
    {
        // End:0x4B
        if(Controller.bIsPlayer)
        {
            Controller.PawnDied(self);            
        }
        else
        {
            Controller.Destroy();
        }
    }
    bTearOff = true;
    // End:0x7F
    if(DamageType.default.bFlaming)
    {
        HitDamageType = Class'BetterBodies.Gibbed_Flaming';
    }
    else
    {
        HitDamageType = Class'Engine.Gibbed';
    }
    // End:0xC5
    if((Level.NetMode == NM_DedicatedServer) || Level.NetMode == NM_ListenServer)
    {
        GotoState('TimingOut');
    }
    // End:0xE0
    if(Level.NetMode == NM_DedicatedServer)
    {
        return;
    }
    // End:0xF7
    if(Class'Engine.GameInfo'.static.UseLowGore())
    {
        Destroy();
        return;
    }
    SpawnChunkGibs(HitRotation, DamageType);
    // End:0x123
    if(Level.NetMode != NM_ListenServer)
    {
        Destroy();
    }
    //return;    
}

simulated function SpawnChunkGibs(Rotator HitRotation, class<DamageType> DamageType)
{
    bGibbed = true;
    PlayDyingSound();
    // End:0x88
    if((((GibCountTorso + GibCountHead) + GibCountForearm) + GibCountUpperArm) > 3)
    {
        // End:0x70
        if(Class'Engine.GameInfo'.static.UseLowGore())
        {
            // End:0x6D
            if(!Class'Engine.GameInfo'.static.NoBlood())
            {
                spawn(GibGroupClass.default.LowGoreBloodGibClass,,, Location);
            }            
        }
        else
        {
            spawn(GibGroupClass.default.BloodGibClass,,, Location);
        }
    }
    // End:0x9C
    if(Class'Engine.GameInfo'.static.UseLowGore())
    {
        return;
    }
    SpawnChunkGiblet(GetGibClass(EGT_Torso), Location, HitRotation, DamageType.default.GibPerterbation, DamageType.default.bFlaming);
    GibCountTorso--;
    J0xD8:

    // End:0x11D [Loop If]
    if(GibCountTorso-- > 0)
    {
        SpawnChunkGiblet(GetGibClass(EGT_Torso), Location, HitRotation, DamageType.default.GibPerterbation, DamageType.default.bFlaming);
        // [Loop Continue]
        goto J0xD8;
    }
    J0x11D:

    // End:0x162 [Loop If]
    if(GibCountHead-- > 0)
    {
        SpawnChunkGiblet(GetGibClass(EGT_Head), Location, HitRotation, DamageType.default.GibPerterbation, DamageType.default.bFlaming);
        // [Loop Continue]
        goto J0x11D;
    }
    J0x162:

    // End:0x1A7 [Loop If]
    if(GibCountForearm-- > 0)
    {
        SpawnChunkGiblet(GetGibClass(EGT_Forearm), Location, HitRotation, DamageType.default.GibPerterbation, DamageType.default.bFlaming);
        // [Loop Continue]
        goto J0x162;
    }
    J0x1A7:

    // End:0x1EC [Loop If]
    if(GibCountUpperArm-- > 0)
    {
        SpawnChunkGiblet(GetGibClass(EGT_UpperArm), Location, HitRotation, DamageType.default.GibPerterbation, DamageType.default.bFlaming);
        // [Loop Continue]
 		goto J0x1A7;
    }
    //return;    
}

simulated function SpawnChunkGiblet(class<Gib> GibClass, Vector Location, Rotator Rotation, float GibPerterbation, bool bFlameGib)
{
    local Gib Giblet;
    local Vector direction, Dummy;

    // End:0x21
    if((GibClass == none) || Class'Engine.GameInfo'.static.UseLowGore())
    {
        return;
    }
    Instigator = self;
    Giblet = spawn(GibClass,,, Location, Rotation);
    // End:0x4F
    if(Giblet == none)
    {
        return;
    }
    Giblet.bFlaming = bFlameGib;
    Giblet.SpawnTrail();
    GibPerterbation *= 32768.0000000;
    Rotation.Pitch += int(((FRand() * 2.0000000) * GibPerterbation) - GibPerterbation);
    Rotation.Yaw += int(((FRand() * 2.0000000) * GibPerterbation) - GibPerterbation);
    Rotation.Roll += int(((FRand() * 2.0000000) * GibPerterbation) - GibPerterbation);
    GetAxes(Rotation, Dummy, Dummy, direction);
    Giblet.Velocity = Velocity + (Normal(direction) * (float(250) + (float(260) * FRand())));
    Giblet.LifeSpan = (Giblet.LifeSpan + (float(2) * FRand())) - float(1);
    //return;    
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
			if( bDeRes )
				return;

			// Throw the body if its a rocket explosion or shock combo
 			if(((Damage > CorpseTotalGibDamage) && GibTheCorpse) && !bSkeletized)
            {
                GibChunkUp(Rotation, DamageType);
                return;
            }
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
 			CalcHitLoc(HitLocation, vect(0.0000000, 0.0000000, 0.0000000), HitBone, HitBoneDist);
            PlayGibHit(float(Damage), instigatedBy, HitLocation, DamageType, Momentum, HitBone);
            // End:0x2EB
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
        super.BeginState();
        GibTheFallingCorpse = false;
        AmbientSound = none;
        GibTheCorpse = false;
        SetTimer(0.5000000, false); 	}

    simulated function Timer()
    {
        local KarmaParamsSkel skelParams;
        GibTheCorpse = true;
        if(GibTheFallingCorpse)
        {
            TakeDamage(1000, none, Location, vect(0.0000000, 0.0000000, 0.0000000), Class'Engine.fell');
            return;
        }
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
    CertainGibness=-40
    RagdollLifeTime=300.0
    DeResTime=3.0
}
