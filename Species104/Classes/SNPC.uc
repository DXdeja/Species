class SNPC extends CBPNPC;

var(Pawn) class<carcass> CarcassType;
var float humanAnimRate;
var sound WalkSound;
var bool bCanBleed;
var bool bIsAlive;

var class<PawnType> PawnInfo;
var Rotator RotationRateX;

var Actor FoodActor;
var float LastEatTime;
var bool bAnimalAttack;
var float LastAnimalAttack;
var bool bAnimalShoot;
var float LastAnimalShoot;

var SObjectHumans EnemysObject;

var Pawn					myBurner;
var Pawn					myPoisoner;

replication
{
	reliable if (Role == ROLE_Authority && !bNetOwner)
		RotationRateX, PawnInfo;
}

function InstallPawnType(class<PT_Animal> pt)
{
	local int i;

	PawnInfo = pt;

	SetCollisionSize(PawnInfo.default.CollisionRadius, PawnInfo.default.CollisionHeight);
	BaseEyeHeight = PawnInfo.default.BaseEyeHeight;
	bCanJump = PawnInfo.default.bCanJump;
	bCanSwim = PawnInfo.default.bCanSwim;
	RotationRate = PawnInfo.default.RotationRate;
	RotationRateX = PawnInfo.default.RotationRate;
	CarcassType = PawnInfo.default.CarcassType;
	WaterSpeed = PawnInfo.default.WaterSpeed;
	Mass = PawnInfo.default.Mass;
	Buoyancy = PawnInfo.default.Buoyancy;
	AirSpeed = PawnInfo.default.AirSpeed;
    AccelRate = PawnInfo.default.AccelRate;
    JumpZ = PawnInfo.default.JumpZ;
	AirControl = PawnInfo.default.AirControl;
	humanAnimRate = PawnInfo.default.MeshAnimRate;
	WalkSound = PawnInfo.default.WalkSound;
	bCanBleed = PawnInfo.default.bCanBleed;
	PrePivot = PawnInfo.default.PrePivot;
	UnderWaterTime = PawnInfo.default.UnderWaterTime;
	Health = PawnInfo.default.HealthTorso;

	// set visualities
	Mesh = PawnInfo.default.Mesh;
	Texture = PawnInfo.default.Texture;
	DrawScale = PawnInfo.default.DrawScale;
	for (i = 0; i < 8; i++)
		MultiSkins[i] = PawnInfo.default.MultiSkins[i];

	bHidden = false;
	bDetectable = true;
	SetCollision(True, True, True);
	//SetPhysics(PHYS_Walking);
	bCollideWorld = True;
	Velocity = vect(0.00,0.00,0.00);
	Acceleration = vect(0.00,0.00,0.00);

	FindEnemysObject();

	bIsAlive = true;

	log("npc pawntype installed");
}

function FindEnemysObject()
{
	local SObjectHumans sobj;

	foreach AllActors(class'SObjectHumans', sobj)
	{
		EnemysObject = sobj;
		break;
	}

	if (EnemysObject == none)
	{
		log("ERROR: HUMANS OBJECT NOT SET IN MAP!");
	}
}

function SetMovementPhysics()
{
	// re-implement SetMovementPhysics() in subclass for flying and swimming creatures
	if (Physics == PHYS_Falling)
		return;

	if (Region.Zone.bWaterZone && bCanSwim)
		SetPhysics(PHYS_Swimming);
	else if (Default.Physics == PHYS_None)
		SetPhysics(PHYS_Walking);
	else
		SetPhysics(Default.Physics);
}

auto state StartUp
{
	function BeginState()
	{
		SetMovementPhysics(); 
		if (Physics == PHYS_Walking)
			SetPhysics(PHYS_Falling);
	}

Begin:
	Sleep(FRand()+0.2);
	WaitForLanding();
	PlayWaiting();
	GotoState('GetNewTask');
}

function bool CanHitWithShoot(Actor a)
{
	local Vector Start, outHitLocation, outHitNormal;

	Start = Location + (EyeHeight * vect(0,0,1));

	return (Trace(outHitLocation, outHitNormal, a.Location, Start, true) == a); 
}

function bool IsPlayerValidTarget(Pawn targ)
{
	if (CanHitWithShoot(targ) && targ.Health > 0)
		return true;
	else
		return false;
}

function SPlayer GetVisibleEnemy()
{
	local SPlayer target;

	foreach RadiusActors(class'SPlayer', target, 5000.0)
	{
		if (IsPlayerValidTarget(target))
			return target;
	}

	return none;
}

state GetNewTask
{
	function BeginState()
	{
		log("getting new task");
	}

	function Tick(float DeltaTime)
	{
		local SPlayer targ;

		// check for visible enemies
		targ = GetVisibleEnemy();
		if (targ != none)
		{
			Enemy = targ;
			GotoState('AttackingEnemy');
			return;
		}

		// check for visible object
		if (CanHitWithShoot(EnemysObject))
		{
			GotoState('AttackingObject');
			return;
		}
	}
}

state AttackingObject
{
	function BeginState()
	{
		log("attacking object: " $ EnemysObject);
	}

	function Tick(float DeltaTime)
	{
		global.Tick(DeltaTime);

		if (!CanHitWithShoot(EnemysObject))
		{
			GotoState('GetNewTask');
			return;
		}

		// rotate towards enemy
		ViewRotation = Rotator(EnemysObject.Location - Location);
		SetRotation(ViewRotation);

		// shoot
		AnimalShoot();
	}
}


function Carcass SpawnCarcass()
{
	local CBPCarcass Car;
	local Inventory Inv;
	local Vector Loc;

	if (CarcassType == none) return none; // no carcass

	if ( Health >= -80 )
	{
		Car = CBPCarcass(Spawn(CarcassType));
	}
	if (Car != None)
	{
		Car.Initfor(self);
		Loc = Location;
		Loc.Z = Loc.Z - CollisionHeight + Car.CollisionHeight;
		Car.SetLocation(Loc);
		MoveTarget = Car;
	}

	return Car;
}


// todo: fix this function
function AnimalTakeDamage(int Damage, Pawn instigatedBy, Vector HitLocation, Vector Momentum, name DamageType)
{
	local byte VBE;
	local int actualDamage;
	local int MPHitLoc;
	local bool bAlreadyDead;
	local bool bPlayAnim;
	local bool bDamageGotReduced;
	local Vector Offset;
	local Vector dst;
	local float origHealth;
	local float fdst;
	local DeusExLevelInfo Info;
	local WeaponRifle VBF;
	local string bodyString;
	local bool bTeamPlayer;

	bodyString="";
	origHealth=Health;
	Offset=HitLocation - Location << Rotation;

	actualDamage = Damage;

	if ( actualDamage <= 0 )
	{
		return;
	}
	if ( DamageType == 'NanoVirus' )
	{
		return;
	}

	if (SNPC(instigatedBy) != none)
		bTeamPlayer = true;
	else
		bTeamPlayer = false;

	if (DeusExPlayer(instigatedBy) != None)
	{
		VBF=WeaponRifle(DeusExPlayer(instigatedBy).Weapon);
		if ( (VBF != None) &&  !VBF.bZoomed && (VBF.Class == Class'SWeaponRifle') )
		{
			actualDamage *= VBF.mpNoScopeMult;
		}
		if (bTeamPlayer)
		{
			actualDamage *= CBPGame(Level.Game).FriendlyFireMult;
		}
	}

	if ( DamageType == 'EMP' )
	{
		//EnergyDrain += actualDamage;
		//EnergyDrainTotal += actualDamage;
		//PlayTakeHitSound(actualDamage,DamageType,1);
		return;
	}

	bPlayAnim=True;

	if ( (DamageType == 'Burned') )
	{
		bPlayAnim=False;
	}

	if ( Physics == 0 )
	{
		SetMovementPhysics();
	}

	if ( Physics == 1 )
	{
		Momentum.Z=0.40 * VSize(Momentum);
	}

	if ( instigatedBy == self )
	{
		Momentum *= 0.60;
	}

	Momentum=Momentum / Mass;

	if (actualDamage > 0)
	{
		if (!IsInState('AttackingEnemy'))
		{
			Enemy = instigatedBy;
			GotoState('AttackingEnemy');
		}
	}

	Health -= actualDamage;

	if (bPlayAnim)
	{
		if (Offset.X < 0.0) PawnInfo.static.PlayAnimation_HitTorsoBack(self);
		else PawnInfo.static.PlayAnimation_HitTorso(self);
	}

	//if ( (DamageType != 'Stunned') && (DamageType != 'TearGas') && (DamageType != 'HalonGas') && (DamageType != 'PoisonGas') && (DamageType != 'Radiation') && (DamageType != 'EMP') && (DamageType != 'NanoVirus') && (DamageType != 'Drowned') && (DamageType != 'KnockedOut') )
	//{
	//	BleedRate += (origHealth - Health) / 30.00;
	//}

	if ( Health > 0 )
	{
		if ( instigatedBy != None )
		{
			damageAttitudeTo(instigatedBy);
		}
	}
	else
	{
		bIsAlive = false;
		Died(instigatedBy,DamageType,HitLocation);
		return;
	}

	if ( (DamageType == 'Flamed') &&  !bOnFire )
	{
		if (!bTeamPlayer || CBPGame(Level.Game).FriendlyFireMult != 0.0)
		    CatchFire(instigatedBy);
	}
}

function CatchFire( Pawn burner )
{
	local Fire f;
	local int i;
	local vector loc;

	myBurner = burner;

	burnTimer = 0;

   if (bOnFire || Region.Zone.bWaterZone)
		return;

	bOnFire = True;
	burnTimer = 0;

	for (i=0; i<8; i++)
	{
		loc.X = 0.5*CollisionRadius * (1.0-2.0*FRand());
		loc.Y = 0.5*CollisionRadius * (1.0-2.0*FRand());
		loc.Z = 0.6*CollisionHeight * (1.0-2.0*FRand());
		loc += Location;

      // DEUS_EX AMSD reduce the number of smoke particles in multiplayer
      // by creating smokeless fire (better for server propagation).
      if ((Level.NetMode == NM_Standalone) || (i <= 0))
         f = Spawn(class'Fire', Self,, loc);
      else
         f = Spawn(class'SmokelessFire', Self,, loc);

		if (f != None)
		{
			f.DrawScale = 0.5*FRand() + 1.0;

         //DEUS_EX AMSD Reduce the penalty in multiplayer
         if (Level.NetMode != NM_Standalone)
            f.DrawScale = f.DrawScale * 0.5;

			// turn off the sound and lights for all but the first one
			if (i > 0)
			{
				f.AmbientSound = None;
				f.LightType = LT_None;
			}

			// turn on/off extra fire and smoke
         // MP already only generates a little.
			if ((FRand() < 0.5) && (Level.NetMode == NM_Standalone))
				f.smokeGen.Destroy();
			if ((FRand() < 0.5) && (Level.NetMode == NM_Standalone))
				f.AddFire();
		}
	}

	//LastBurnTime = Level.TimeSeconds;
}

function ExtinguishFire()
{
	local Fire f;

	bOnFire = False;
	burnTimer = 0;

	foreach BasedActors(class'Fire', f)
		f.Destroy();
}

state AttackingEnemy
{
	function BeginState()
	{
		log("attacking enemy: " $ Enemy);
	}

	function Tick(float DeltaTime)
	{
		global.Tick(DeltaTime);

		if (Enemy == none)
		{
			// enemy is gone
			GotoState('GetNewTask');
			return;
		}

		if (!IsPlayerValidTarget(Enemy))
		{
			// enemy has hidden, is dead
			GotoState('GetNewTask');
			return;
		}

		// rotate towards enemy
		ViewRotation = Rotator(Enemy.Location - Location);
		SetRotation(ViewRotation);

		// shoot
		AnimalShoot();
	}
}

simulated function Tick(float deltaTime)
{
	super.Tick(deltaTime);

	if (Role == ROLE_SimulatedProxy)
	{
		RotationRate = RotationRateX;
	}

	if (Role < ROLE_Authority)
		return;

	if ((LastAnimalShoot + PawnInfo.default.AnimalShootTime) < Level.TimeSeconds) bAnimalShoot = false;
}



function AnimalShoot()
{
	local Vector Start;
	local Rotator AdjustedAim;

	if (bAnimalShoot) return; // shooting already happening
	LastAnimalShoot = Level.TimeSeconds;
	bAnimalShoot = true;
	PawnInfo.static.PlayAnimation_Shoot(self);

	Start = Location + (EyeHeight * vect(0,0,1));
	Spawn(PawnInfo.default.AnimalShootProj, self,, Start, ViewRotation);
}

// events
function AnimEnd()
{
	PlayWaiting();
}

function TakeDamage(int Damage, Pawn instigatedBy, Vector HitLocation, Vector Momentum, name DamageType)
{
	PawnInfo.static.Event_TakeDamage(self, Damage, instigatedBy, HitLocation, Momentum, DamageType);
}

event Destroyed()
{
	log("NPC destroyed: " $ self);
}

//
// animation functions
//
function PlayTurning()
{
	PawnInfo.static.PlayAnimation_Turning(self);
}

function TweenToWalking(float tweentime)
{
	PawnInfo.static.PlayAnimation_TweenToWalking(self, tweentime);
}

function PlayWalking()
{
	PawnInfo.static.PlayAnimation_Walking(self, humanAnimRate);
}

function TweenToRunning(float tweentime)
{
	PawnInfo.static.PlayAnimation_TweenToRunning(self, tweentime, humanAnimRate);
}

function PlayRunning()
{
	PawnInfo.static.PlayAnimation_Running(self, humanAnimRate);
}

function TweenToWaiting(float tweentime)
{
	PawnInfo.static.PlayAnimation_TweenToWaiting(self, tweentime);
}

function PlayWaiting()
{
	PawnInfo.static.PlayAnimation_Waiting(self);
}

function PlayLanded(float impactVel)
{
	PawnInfo.static.PlayAnimation_Landed(self);
}

function PlayDying(name damageType, vector hitLoc)
{
	local Vector X, Y, Z;
	local float dotp;

	GetAxes(Rotation, X, Y, Z);
	dotp = (Location - HitLoc) dot X;

	if (Region.Zone.bWaterZone)
	{
		PawnInfo.static.PlayAnimation_DeathWater(self);
	}
	else
	{
		// die from the correct side
		if (dotp < 0.0)		// shot from the front, fall back
			PawnInfo.static.PlayAnimation_DeathBack(self);
		else				// shot from the back, fall front
			PawnInfo.static.PlayAnimation_DeathFront(self);
	}

	PlayDyingSound();
}


//
// sound functions
//

function Gasp()
{
	PawnInfo.static.PlaySound_Gasp(self);
}

function PlayDyingSound()
{
	if (Region.Zone.bWaterZone)
		PawnInfo.static.PlaySound_WaterDeath(self);
	else
		PawnInfo.static.PlaySound_Death(self);
}

function PlayTakeHitSound(int Damage, name damageType, int Mult)
{
	local float rnd;

	if ( Level.TimeSeconds - LastPainSound < FRand() + 0.5)
		return;

	LastPainSound = Level.TimeSeconds;

	if (Region.Zone.bWaterZone)
	{
		if (damageType == 'Drowned')
		{
			if (FRand() < 0.8)
				PawnInfo.static.PlaySound_Drown(self, FMax(Mult * TransientSoundVolume, Mult * 2.0));
		}
		else
			PawnInfo.static.PlaySound_PainSmall(self, FMax(Mult * TransientSoundVolume, Mult * 2.0));
	}
	else
	{
		// Body hit sound for multiplayer only
		if (((damageType=='Shot') || (damageType=='AutoShot'))  && ( Level.NetMode != NM_Standalone ))
		{
			PawnInfo.static.PlaySound_BodyHit(self, FMax(Mult * TransientSoundVolume, Mult * 2.0));
		}

		if ((damageType == 'TearGas') || (damageType == 'HalonGas'))
			PawnInfo.static.PlaySound_PainEye(self, FMax(Mult * TransientSoundVolume, Mult * 2.0));
		//else if (damageType == 'PoisonGas')
		//	PlaySound(sound'MaleCough', SLOT_Pain, FMax(Mult * TransientSoundVolume, Mult * 2.0),,, RandomPitch());
		else
		{
			rnd = FRand();
			if (rnd < 0.33)
				PawnInfo.static.PlaySound_PainSmall(self, FMax(Mult * TransientSoundVolume, Mult * 2.0));
			else if (rnd < 0.66)
				PawnInfo.static.PlaySound_PainMedium(self, FMax(Mult * TransientSoundVolume, Mult * 2.0));
			else
				PawnInfo.static.PlaySound_PainLarge(self, FMax(Mult * TransientSoundVolume, Mult * 2.0));
		}
	}
}

function PlayBodyThud()
{
	PawnInfo.static.PlaySound_BodyThud(self);
}

function name GetFloorMaterial()
{
	local vector EndTrace, HitLocation, HitNormal;
	local actor target;
	local int texFlags;
	local name texName, texGroup;

	// trace down to our feet
	EndTrace = Location - CollisionHeight * 2 * vect(0,0,1);

	foreach TraceTexture(class'Actor', target, texName, texGroup, texFlags, HitLocation, HitNormal, EndTrace)
	{
		if ((target == Level) || target.IsA('Mover'))
			break;
	}

	return texGroup;
}

function PlayFootStep()
{
	local Sound stepSound;
	local float rnd;
	local name mat;
	local float speedFactor, massFactor;
	local float volume, pitch, range;
	local float radius, maxRadius;
	local float volumeMultiplier;

	local DeusExPlayer dxPlayer;
	local float shakeRadius, shakeMagnitude;
	local float playerDist;

	rnd = FRand();
	mat = GetFloorMaterial();

	volumeMultiplier = 1.0;
	if (WalkSound == None)
	{
		if (FootRegion.Zone.bWaterZone)
		{
			if (rnd < 0.33)
				stepSound = Sound'WaterStep1';
			else if (rnd < 0.66)
				stepSound = Sound'WaterStep2';
			else
				stepSound = Sound'WaterStep3';
		}
		else
		{
			switch(mat)
			{
				case 'Textile':
				case 'Paper':
					volumeMultiplier = 0.7;
					if (rnd < 0.25)
						stepSound = Sound'CarpetStep1';
					else if (rnd < 0.5)
						stepSound = Sound'CarpetStep2';
					else if (rnd < 0.75)
						stepSound = Sound'CarpetStep3';
					else
						stepSound = Sound'CarpetStep4';
					break;

				case 'Foliage':
				case 'Earth':
					volumeMultiplier = 0.6;
					if (rnd < 0.25)
						stepSound = Sound'GrassStep1';
					else if (rnd < 0.5)
						stepSound = Sound'GrassStep2';
					else if (rnd < 0.75)
						stepSound = Sound'GrassStep3';
					else
						stepSound = Sound'GrassStep4';
					break;

				case 'Metal':
				case 'Ladder':
					volumeMultiplier = 1.0;
					if (rnd < 0.25)
						stepSound = Sound'MetalStep1';
					else if (rnd < 0.5)
						stepSound = Sound'MetalStep2';
					else if (rnd < 0.75)
						stepSound = Sound'MetalStep3';
					else
						stepSound = Sound'MetalStep4';
					break;

				case 'Ceramic':
				case 'Glass':
				case 'Tiles':
					volumeMultiplier = 0.7;
					if (rnd < 0.25)
						stepSound = Sound'TileStep1';
					else if (rnd < 0.5)
						stepSound = Sound'TileStep2';
					else if (rnd < 0.75)
						stepSound = Sound'TileStep3';
					else
						stepSound = Sound'TileStep4';
					break;

				case 'Wood':
					volumeMultiplier = 0.7;
					if (rnd < 0.25)
						stepSound = Sound'WoodStep1';
					else if (rnd < 0.5)
						stepSound = Sound'WoodStep2';
					else if (rnd < 0.75)
						stepSound = Sound'WoodStep3';
					else
						stepSound = Sound'WoodStep4';
					break;

				case 'Brick':
				case 'Concrete':
				case 'Stone':
				case 'Stucco':
				default:
					volumeMultiplier = 0.7;
					if (rnd < 0.25)
						stepSound = Sound'StoneStep1';
					else if (rnd < 0.5)
						stepSound = Sound'StoneStep2';
					else if (rnd < 0.75)
						stepSound = Sound'StoneStep3';
					else
						stepSound = Sound'StoneStep4';
					break;
			}
		}
	}
	else
		stepSound = WalkSound;

	// compute sound volume, range and pitch, based on mass and speed
	speedFactor = VSize(Velocity)/120.0;
	massFactor  = Mass/150.0;
	radius      = 768.0;
	maxRadius   = 2048.0;
//	volume      = (speedFactor+0.2)*massFactor;
//	volume      = (speedFactor+0.7)*massFactor;
	volume      = massFactor*1.5;
	range       = radius * volume;
	pitch       = (volume+0.5);
	volume      = 1.0;
	range       = FClamp(range, 0.01, maxRadius);
	pitch       = FClamp(pitch, 1.0, 1.5);

	// play the sound and send an AI event
	PlaySound(stepSound, SLOT_Interact, volume, , range, pitch);
	AISendEvent('LoudNoise', EAITYPE_Audio, volume*volumeMultiplier, range*volumeMultiplier);

	// Shake the camera when heavy things tread
	if (Mass > 400)
	{
		dxPlayer = DeusExPlayer(GetPlayerPawn());
		if (dxPlayer != None)
		{
			playerDist = DistanceFromPlayer;
			shakeRadius = FClamp((Mass-400)/600, 0, 1.0) * (range*0.5);
			shakeMagnitude = FClamp((Mass-400)/1600, 0, 1.0);
			shakeMagnitude = FClamp(1.0-(playerDist/shakeRadius), 0, 1.0) * shakeMagnitude;
			if (shakeMagnitude > 0)
				dxPlayer.JoltView(shakeMagnitude);
		}
	}
}

DefaultProperties
{
	NetPriority=3.000000
	DrawType=DT_Mesh
}
