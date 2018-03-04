class SPlayer extends CBPPlayer;

var Actor FoodActor;
var float LastEatTime;
var bool bAnimalAttack;
var float LastAnimalAttack;
var bool bAnimalShoot;
var float LastAnimalShoot;

var byte XPLevel;
var float GestureLevel;
var float AutoGenItemTime[2];
var byte AutoGenItemTimePerc[2];

var byte ReplEnergy;
var byte ReplHealth;
var bool ReplAmmoLow;

var float FieldCheckTime; // for gray & robot

// for kark
var Vector AttackViewOffsetLoc;
var Rotator AttackViewOffsetRot;

// destroying object
var float LastObjectAttackTime;

// special sounds
var float LastSpecialSoundTime;

// robot stuff
var float LastTakenDamageTime;

var bool bRadarTransOn;
var bool bCloakOn;

// dog stuff
var bool bDogBump;



replication
{
	reliable if (Role == ROLE_Authority)
		ClientEatDeadBody, ClientRoar, ClientAnimalAttack, ClientAnimalShoot, ClientDogAttack,
		ReplEnergy, ReplHealth, ReplAmmoLow, ClientResetPlayerToDefaults, bRadarTransOn, bCloakOn;

	reliable if (Role == ROLE_Authority && bNetOwner)
		XPLevel, AutoGenItemTimePerc, GestureLevel;

	reliable if (Role < ROLE_Authority)
		ServerAnimalSpecial, ServerDogAttack;

	unreliable if (Role == ROLE_Authority)
		SEF_ObjectExplode;
}



function ClientDogAttack()
{
	PawnInfo.static.PlayAnimation_Firing(self, none);
}

function ServerDogAttack()
{
	DogAttack();
}

function DogAttack()
{
	if (RestrictInput()) return;

	if (bAnimalAttack) return; // attack already happening
	if (Physics != PHYS_Walking) return; // falling or swimming?

	LastAnimalAttack = Level.TimeSeconds;
	bAnimalAttack = true;
	PawnInfo.static.PlayAnimation_Firing(self, none);

	SetPhysics(PHYS_Falling);
	Velocity = Vector(Rotation) * 700.0 + vect(0,0,300);

	if (Role == ROLE_Authority)
	{
		// only on server side
		if (FRand() < 0.5) PlaySound(Sound'DeusExSounds.Animal.DogAttack1', SLOT_None, 1.0, , 2048);
		else PlaySound(Sound'DeusExSounds.Animal.DogAttack2', SLOT_None, 1.0, , 2048);
		bDogBump = true;
	}
}

state PlayerSwimming
{
	function BeginState()
	{
		if (class<PT_Robot>(PawnInfo) != none) Suicide();
		else super.BeginState();
	}
}

function CreateKillerProfile( Pawn killer, int damage, name damageType, String bodyPart )
{
	if (class<PT_Robot>(SPlayer(killer).PawnInfo) != none) KilledWeapon = DeusExWeapon(killer.Inventory);
	super.CreateKillerProfile(killer, damage, damageType, bodyPart);
}

exec function DualmapF3()
{
	if (AugmentationSystem == none) ServerAnimalSpecial(0);
	else super.DualmapF3();
}

exec function DualmapF4()
{
	if (AugmentationSystem == none) ServerAnimalSpecial(1);
	else super.DualmapF4();
}

exec function ActivateAugmentation(int num)
{
	if (AugmentationSystem == none) ServerAnimalSpecial(num);
	else super.ActivateAugmentation(num);
}

function ServerAnimalSpecial(byte num)
{
	if (class<PT_Animal>(PawnInfo) != none)
		(class<PT_Animal>(PawnInfo)).static.AnimalSpecial(self, num);
}

function InstallPawnInfo()
{
	super.InstallPawnInfo();
	LightType = default.LightType;
	LightBrightness = default.LightBrightness;
	LightHue = default.LightHue;
	LightSaturation = default.LightSaturation;
	LightRadius = default.LightRadius;
	ScaleGlow = default.ScaleGlow;
	SPlayerReplicationInfo(PlayerReplicationInfo).ClassIndex = class'AnimVsHumDef'.static.GetIndexOfPawnType(PawnInfo);
}

function RestockWeapon(DeusExWeapon WeaponToStock)
{
   local Ammo AmmoType;
   if (WeaponToStock.AmmoType != None)
   {
      if (WeaponToStock.AmmoNames[0] == None)
         AmmoType = Ammo(FindInventoryType(WeaponToStock.AmmoName));
      else
         AmmoType = Ammo(FindInventoryType(WeaponToStock.AmmoNames[0]));

      if ((AmmoType != None) && (AmmoType.AmmoAmount < WeaponToStock.PickupAmmoCount))
      {
         AmmoType.AddAmmo(WeaponToStock.PickupAmmoCount - AmmoType.AmmoAmount);
      }
   }
}

function RestockAmmo()
{
	local Inventory inv;

	inv = Inventory;
	while (inv != None)
	{
		if (inv.IsA('DeusExWeapon') &&  !inv.IsA('CBPWeaponLAM') &&  !inv.IsA('WeaponEMPGrenade') &&  !inv.IsA('WeaponGasGrenade'))
		{
			RestockWeapon(DeusExWeapon(inv));
		}
		inv = inv.Inventory;
	}
	ClientMessage(class'AmmoCrate'.default.AmmoReceived);
	//PlaySound(Sound'WeaponPickup',SLOT_None,0.50 + FRand() * 0.25,,256.00,0.95 + FRand() * 0.10);
	PlayLogSound(Sound'WeaponPickup');
	ReplAmmoLow = false;
}

function MaintainEnergy(float deltaTime)
{
	local Float energyUse;
   local Float energyRegen;

   if (AugmentationSystem == none) return;

	// make sure we can't continue to go negative if we take damage
	// after we're already out of energy
	if (Energy <= 0)
	{
		Energy = 0;
		EnergyDrain = 0;
		EnergyDrainTotal = 0;
	}

   energyUse = 0;

	// Don't waste time doing this if the player is dead or paralyzed
	if ((!IsInState('Dying')) && (!IsInState('Paralyzed')))
   {
      if (Energy > 0)
      {
         // Decrement energy used for augmentations
         energyUse = AugmentationSystem.CalcEnergyUse(deltaTime);

         Energy -= EnergyUse;

         // Calculate the energy drain due to EMP attacks
         if (EnergyDrain > 0)
         {
            energyUse = EnergyDrainTotal * deltaTime;
            Energy -= EnergyUse;
            EnergyDrain -= EnergyUse;
            if (EnergyDrain <= 0)
            {
               EnergyDrain = 0;
               EnergyDrainTotal = 0;
            }
         }
      }

      //Do check if energy is 0.
      // If the player's energy drops to zero, deactivate
      // all augmentations
      if (Energy <= 0)
      {
         //If we were using energy, then tell the client we're out.
         //Otherwise just make sure things are off.  If energy was
         //already 0, then energy use will still be 0, so we won't
         //spam.  DEUS_EX AMSD
         if (energyUse > 0)
            ClientMessage(EnergyDepleted);
         Energy = 0;
         EnergyDrain = 0;
         EnergyDrainTotal = 0;
         AugmentationSystem.DeactivateAll();
      }

      // If all augs are off, then start regenerating in multiplayer,
      // up to 25%.
      //if ((energyUse == 0) && (Energy <= MaxRegenPoint) && (Level.NetMode != NM_Standalone))
      //{
      //   energyRegen = RegenRate * deltaTime;
      //   Energy += energyRegen;
      //}
	}
}

function ResetPlayerToDefaults()
{
	super.ResetPlayerToDefaults();
	XPLevel = 0;
	AutoGenItemTime[0] = 0.0;
	AutoGenItemTime[1] = 0.0;
	GestureLevel = 0.0;
	ReplAmmoLow = false;
	FieldCheckTime = 0.0;
	ClientResetPlayerToDefaults();
	PlayerReplicationInfo.Streak = 0;
}

function ClientResetPlayerToDefaults()
{
	AttackViewOffsetLoc = vect(0,0,0);
	AttackViewOffsetRot = rot(0,0,0);
}

function String GetDisplayName(Actor actor, optional Bool bUseFamiliar)
{
	if (SPlayer(actor) != none)
		return SPlayer(actor).PlayerReplicationInfo.PlayerName;
	else return super.GetDisplayName(actor, bUseFamiliar);
}

exec function PlayerSetPawnType(string ptclassname)
{
	local class<PawnType> pt;

	pt = class<PawnType>(DynamicLoadObject(ptclassname, class'Class'));
	if (pt != none)
	{
		ServerSetPawnType(pt);
	}
}

function ServerSetPawnType(class<PawnType> ptclass)
{
	local byte newTeam;

	if (ptclass != none)
	{
		if (!SGame(Level.Game).IsValidPawnType(ptclass)) return;
		newTeam = SGame(Level.Game).GetPawnTypeTeam(ptclass);
		log(self $ " is now : " $ ptclass $ ", team: " $ newTeam, 'PawnInfo');
		NextPawnInfo = ptclass;
		if (newTeam != PlayerReplicationInfo.Team)
		{
			PlayerReplicationInfo.Team = newTeam;
			if (IsInState('PlayerWalking') || IsInState('PlayerSwimming')) Suicide();
		}
	}

	super.ServerSetPawnType(ptclass);
}

function Carcass SpawnCarcass()
{
	local CBPCarcass Car;
	local Inventory Inv;
	local Vector Loc;

	// no inventory
	while (Inventory != None)
	{
		Inv = Inventory;
		DeleteInventory(Inv);
		/*if (Car != None) Car.AddInventory(Inv);
		else*/ Inv.Destroy();
	}

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
		Car.bPlayerCarcass = True;
		MoveTarget = Car;
	}

	return Car;
}

function MultiplayerTick(float DeltaTime)
{
	Super.MultiplayerTick(DeltaTime);

	// reset animal attack just in case
	if ((LastAnimalAttack + PawnInfo.default.AnimalAttackTime) < Level.TimeSeconds) bAnimalAttack = false;

	if (Role < ROLE_Authority)
		return;

	// reset FoodActor just in case
	if ((LastEatTime + PawnInfo.default.EatTime) < Level.TimeSeconds) FoodActor = none;

	// reset animal shoot just in case
	if ((LastAnimalShoot + PawnInfo.default.AnimalShootTime) < Level.TimeSeconds) bAnimalShoot = false;

	// todo: handle this different way to reduce network load
	if (drugEffectTimer > 0.0) drugEffectTimer = FMax(drugEffectTimer - DeltaTime, 0.0);
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
	//if ( Level.NetMode != 0 )
	//{
	//	Damage *= MPDamageMult;
	//}
	Offset=HitLocation - Location << Rotation;
	//bDamageGotReduced=DXReduceDamage(Damage,DamageType,HitLocation,actualDamage,False);
	//if ( ReducedDamageType == DamageType )
	//{
	//	actualDamage=actualDamage * (1.00 - ReducedDamagePct);
	//}
	//if ( ReducedDamageType == 'All' )
	//{
	//	actualDamage=0;
	//}
	actualDamage = Damage;
	if ( (Level.Game != None) && (Level.Game.DamageMutator != None) )
	{
		Level.Game.DamageMutator.MutatorTakeDamage(actualDamage,self,instigatedBy,HitLocation,Momentum,DamageType);
	}
	if ( bNintendoImmunity || (actualDamage == 0) && (NintendoImmunityTimeLeft > 0.00) )
	{
		return;
	}
	if ( actualDamage <= 0 )
	{
		return;
	}
	if ( DamageType == 'NanoVirus' )
	{
		return;
	}

	if ( (DamageType == 'Poison') || (DamageType == 'PoisonEffect') )
	{
		AddDamageDisplay('PoisonGas',Offset);
	}
    else
    {
		AddDamageDisplay(DamageType,Offset);
	}

	if (Level.Game.bTeamGame && (DeusExPlayer(instigatedBy) != self) && class'CBPGame'.static.ArePlayersAllied(DeusExPlayer(instigatedBy),self))
	    bTeamPlayer = true;
    else
        bTeamPlayer = false;

	if ( (DamageType == 'Poison') || (Level.NetMode != 0) && (DamageType == 'TearGas') )
	{
		if ( Level.NetMode != 0 )
		{
			ServerConditionalNotifyMsg(4);
		}
		if (!bTeamPlayer || CBPGame(Level.Game).FriendlyFireMult != 0.0)
		    StartPoison(instigatedBy, Damage);
	}

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
			if ( (DamageType != 'TearGas') && (DamageType != 'PoisonEffect') )
			{
				DeusExPlayer(instigatedBy).MultiplayerNotifyMsg(2);
			}
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
	if ( (DamageType == 'Burned') || PlayerReplicationInfo.bFeigningDeath )
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
	//MPHitLoc=GetMPHitLocation(HitLocation);
	MPHitLoc = 2;
	bodyString=TorsoString;
	HealthArmLeft -= actualDamage;
	HealthTorso -= actualDamage;
	HealthArmRight -= actualDamage;

	if (bPlayAnim)
	{
		if (Offset.X < 0.0) PawnInfo.static.PlayAnimation_HitTorsoBack(self);
		else PawnInfo.static.PlayAnimation_HitTorso(self);
	}

	Health = HealthTorso;

	if ( (DamageType != 'Stunned') && (DamageType != 'TearGas') && (DamageType != 'HalonGas') && (DamageType != 'PoisonGas') && (DamageType != 'Radiation') && (DamageType != 'EMP') && (DamageType != 'NanoVirus') && (DamageType != 'Drowned') && (DamageType != 'KnockedOut') )
	{
		BleedRate += (origHealth - Health) / 30.00;
	}
	if ( carriedDecoration != None )
	{
		DropDecoration();
	}
	if ( Health > 0 )
	{
		if ( (Level.NetMode != 0) && (HealthLegLeft == 0) && (HealthLegRight == 0) )
		{
			ServerConditionalNotifyMsg(10);
		}
		if ( instigatedBy != None )
		{
			damageAttitudeTo(instigatedBy);
		}
		PlayDXTakeDamageHit(actualDamage,HitLocation,DamageType,Momentum,bDamageGotReduced);
	}
	else
	{
		bIsAlive = false;
		NextState='None';
		PlayDeathHit(actualDamage,HitLocation,DamageType,Momentum);

		MyLastKiller = CBPPlayer(instigatedBy);
		if (MyLastKiller == none && damageType == 'Suicided')
			MyLastKiller = self;
		KilledWeapon = DeusExWeapon(MyLastKiller.inHand);

		CreateKillerProfile(instigatedBy,actualDamage,DamageType,bodyString);

		if ( actualDamage > Mass )
		{
			Health=-1 * actualDamage;
		}
		Enemy=instigatedBy;
		Died(instigatedBy,DamageType,HitLocation);
		return;
	}

	if ( (DamageType == 'Flamed') &&  !bOnFire )
	{
		if ( Level.NetMode != 0 )
		{
			ServerConditionalNotifyMsg(5);
		}
		if (!bTeamPlayer || CBPGame(Level.Game).FriendlyFireMult != 0.0)
		    CatchFire(instigatedBy);
	}
	myProjKiller=None;
}

function bool AnimalLeftClick()
{
	if (RestrictInput())
		return false;

	if (bAnimalAttack) return false; // attack already happening
	LastAnimalAttack = Level.TimeSeconds;
	bAnimalAttack = true;
	ClientAnimalAttack();
	PawnInfo.static.PlayAnimation_Firing(self, none);

	return true;
}

function ClientAnimalAttack()
{
	PawnInfo.static.PlayAnimation_Firing(self, none);
}

function AnimalRightClick()
{
	if (RestrictInput())
		return;

	if (FrobTarget != None)
	{
		if (FrobTarget.IsA('Decoration') && Decoration(FrobTarget).bPushable)
		{
			GrabDecoration();
			return;
		}
		if (FrobTarget.IsA('CBPCarcass'))
		{
			EatDeadBody(FrobTarget);
			return;
		}

		DoFrob(Self, None);
		return;
	}
}

function GrayRightClick()
{
	if (RestrictInput())
		return;

	if (FrobTarget != None)
	{
		if (FrobTarget.IsA('Decoration') && Decoration(FrobTarget).bPushable)
		{
			GrabDecoration();
			return;
		}

		DoFrob(Self, None);
		return;
	}

	// shoot
	AnimalShoot();
}

simulated function vector AS_CalcDrawOffset()
{
	local vector		DrawOffset, WeaponBob;
	local ScriptedPawn	SPOwner;
	local Pawn			PawnOwner;

	// copied from Engine.Inventory to not be FOVAngle dependent
	DrawOffset = ((0.9/Default.FOVAngle * vect(0,0,0)) >> ViewRotation);

	DrawOffset += (EyeHeight * vect(0,0,1));
	WeaponBob = 0.960000 * WalkBob;
	WeaponBob.Z = (0.45 + 0.55 * 0.960000) * WalkBob.Z;
	DrawOffset += WeaponBob;

	return DrawOffset;
}

function AnimalShoot()
{
	local Vector X, Y, Z, Start;
	local Rotator AdjustedAim;

	if (RestrictInput()) return;

	if (bAnimalShoot) return; // shooting already happening
	LastAnimalShoot = Level.TimeSeconds;
	bAnimalShoot = true;
	ClientAnimalShoot();
	PawnInfo.static.PlayAnimation_Shoot(self);

	GetAxes(ViewRotation, X, Y, Z);
	Start = Location + AS_CalcDrawOffset() + 0.0 * X /*+FireOffset.Y * Y + FireOffset.Z * Z*/;
	AdjustedAim = AdjustAim(10000, Start, 0.0, false, false);
	Spawn(PawnInfo.default.AnimalShootProj, self,, Start, AdjustedAim);
}

function EatDeadBody(Actor fa)
{
	if (FoodActor != none) return; // already eating something
	LastEatTime = Level.TimeSeconds;
	FoodActor = fa;
	ClientEatDeadBody();
	PawnInfo.static.PlayAnimation_Eat(self);
}

function ClientRoar()
{
	PawnInfo.static.PlayAnimation_Roar(self);
}

function ClientEatDeadBody()
{
	PawnInfo.static.PlayAnimation_Eat(self);
}

function ClientAnimalShoot()
{
	PawnInfo.static.PlayAnimation_Shoot(self);
}

function KarkianBump(Actor other)
{
	local float damage;

	if (Role != ROLE_Authority) return;

	// bump is valid only if we are running with 80% or more speed
	if (VSize(Velocity) < (PawnInfo.default.GroundSpeed * class'Animal_Karkian'.default.BumpVelocityNeededPerc)) return;

	damage = (class'Animal_Karkian'.default.BumpDamageMulti + class'Animal_Karkian'.default.BumpImprovementPerLevel[XPLevel]) * VSize(Velocity);
	// reduce if turret
	if (SAutoTurret(Other) != none || SAutoTurret(Other) != none) damage = damage * 0.25;
	Other.TakeDamage(damage, self, Other.Location + vect(0,0,-1), 100 * Velocity, 'Bump');
	if (CBPPlayer(Other) != None)
		CBPPlayer(Other).ShakeView(0.15 + 0.002 * damage * 2, damage * 30 * 2, 0.3 * damage * 2);
}

function DogBump(Actor other)
{
	local float damage;
	local Vector HitLocation, HitNormal, StartTrace, EndTrace;

	if (Role != ROLE_Authority) return;

	StartTrace = Location;
	EndTrace = Location + (Vector(ViewRotation) * 40.0);
	StartTrace.Z += BaseEyeHeight;
	EndTrace.Z += BaseEyeHeight;

	if (Trace(HitLocation, HitNormal, EndTrace, StartTrace) != other) return;

	damage = class'Animal_Dog'.default.AnimalAttackDamage + class'Animal_Dog'.default.AttackImprovementPerLevel[XPLevel];
	//log("dog bump: " $ damage);
	Other.TakeDamage(damage, self, Location - Other.Location, class'Animal_Dog'.default.AnimalAttackMomentum * Velocity,
		class'Animal_Dog'.default.AnimalAttackDamageType);
	if (CBPPlayer(Other) != None)
		CBPPlayer(Other).ShakeView(0.15 + 0.002 * damage * 2, damage * 30 * 2, 0.3 * damage * 2);
	bDogBump = false;
}

simulated function float GetAttackImprovement()
{
	if (class<PT_Animal>(PawnInfo) != none)
		return (class<PT_Animal>(PawnInfo)).default.AttackImprovementPerLevel[XPLevel];
	else return 0.0;
}

//
// functions called from animations
//
simulated function HandToHandAttack()
{
	local Vector X, Y, Z, StartTrace, EndTrace, HitLocation, HitNormal;
	local Rotator AdjustedAim;
	local Actor Other;

	if (PawnInfo == class'Animal_Dog')
	{
		if (bAnimalAttack || Physics == PHYS_Falling) return;
		else if (FoodActor != none) Chomp();
		return;
	}

	if (AnimSequence == 'Shoot' || PawnInfo == class'Animal_Greasel') return;

	if (Role == ROLE_Authority)
	{
		GetAxes(ViewRotation, X, Y, Z);
		StartTrace = Location + AS_CalcDrawOffset() /* + 20.0 * X +FireOffset.Y * Y + FireOffset.Z * Z*/;
		AdjustedAim = AdjustAim(1000000, StartTrace, 0.0, False, False);
		EndTrace = StartTrace + Vector(AdjustedAim) * PawnInfo.default.AnimalAttackDistance;

		Other = TraceShot(HitLocation, HitNormal, EndTrace, StartTrace);
		if (Other != none && Other != self)
		{
			// todo: fix momentum
			Other.TakeDamage(PawnInfo.default.AnimalAttackDamage + GetAttackImprovement(),
				self, HitLocation, vect(0,0,0), PawnInfo.default.AnimalAttackDamageType);

			// todo: spawn effects
		}

		//bAnimalAttack = false; // multiplayertick will clear this value
	}

	if (Role < ROLE_Authority || GetPlayerPawn() == self)
	{
		PawnInfo.static.PlaySound_Attack(self);
	}
}

simulated function Chomp()
{
	local class<PT_Animal> animclass;

	if (Role == ROLE_Authority)
	{
		animclass = class<PT_Animal>(PawnInfo);
		if (FoodActor != none && FrobTarget == FoodActor && animclass != none)
		{
			foodActor.TakeDamage(PawnInfo.default.EatDamage, self, FoodActor.Location, vect(0,0,0), 'Munch');
			HealPlayer(animclass.default.EatHeal + animclass.default.EatHealImprovementPerLevel[XPLevel], false);
			ClientFlash(0.5, vect(0, 0, 500));
			PawnInfo.static.PlaySound_Eat(self);
			class'CBPGame'.static.SEF_SpewBlood(self, Location+Vector(Rotation)*CollisionRadius - vect(0,0,1)*CollisionHeight*0.5);
		}
		//FoodActor = none; // multiplayertick resets this
	}
}

simulated function PlayRoarSound()
{
	PawnInfo.static.PlaySound_Roar(self);
}

function RegularParseRightClick()
{
	//
	// ParseRightClick deals with things in the WORLD
	//
	// Precedence:
	// - Pickup highlighted Inventory
	// - Frob highlighted object
	// - Grab highlighted Decoration
	// - Put away (or drop if it's a deco) inHand
	//

	local AutoTurret turret;
	local int ViewIndex;
	local bool bPlayerOwnsIt;
   local Inventory oldFirstItem;
	local Inventory oldInHand;
	local Decoration oldCarriedDecoration;
	local Vector loc;

	if (RestrictInput())
		return;

   oldFirstItem = Inventory;
	oldInHand = inHand;
	oldCarriedDecoration = CarriedDecoration;

	if (FrobTarget != None)
		loc = FrobTarget.Location;

	if (FrobTarget != None)
	{
		if (FrobTarget.IsA('SPlayer'))
		{
			if ((inHand != None) && !bInHandTransition)
			{
				if (inHand.bActivatable)
					inHand.Activate();
			}
		}

		// First check if this is a NanoKey, in which case we just
		// want to add it to the NanoKeyRing without disrupting
		// what the player is holding

		else if (FrobTarget.IsA('NanoKey'))
		{
			PickupNanoKey(NanoKey(FrobTarget));
			FrobTarget.Destroy();
			FrobTarget = None;
			return;
		}
		else if (FrobTarget.IsA('Inventory'))
		{
			// If this is an item that can be stacked, check to see if
			// we already have one, in which case we don't need to
			// allocate more space in the inventory grid.
			//
			// TODO: This logic may have to get more involved if/when
			// we start allowing other types of objects to get stacked.

			if (HandleItemPickup(FrobTarget, True) == False)
				return;

			// if the frob succeeded, put it in the player's inventory
         //DEUS_EX AMSD ARGH! Because of the way respawning works, the item I pick up
         //is NOT the same as the frobtarget if I do a pickup.  So how do I tell that
         //I've successfully picked it up?  Well, if the first item in my inventory
         //changed, I picked up a new item.
			if ( ((Level.NetMode == NM_Standalone) && (Inventory(FrobTarget).Owner == Self)) ||
              ((Level.NetMode != NM_Standalone) && (oldFirstItem != Inventory)) )
			{
            if (Level.NetMode == NM_Standalone)
               FindInventorySlot(Inventory(FrobTarget));
            else
               FindInventorySlot(Inventory);
				FrobTarget = None;
			}
		}
		else if (FrobTarget.IsA('Decoration') && Decoration(FrobTarget).bPushable)
		{
			GrabDecoration();
		}
		else
		{
			if (( Level.NetMode != NM_Standalone ) && ( Level.Game.bTeamGame ))
			{
				if ( FrobTarget.IsA('LAM') || FrobTarget.IsA('GasGrenade') || FrobTarget.IsA('EMPGrenade'))
				{
					if ((ThrownProjectile(FrobTarget).team == PlayerReplicationInfo.team) && ( ThrownProjectile(FrobTarget).Owner != Self ))
					{
						if ( ThrownProjectile(FrobTarget).bDisabled )		// You can re-enable a grenade for a teammate
						{
							ThrownProjectile(FrobTarget).ReEnable();
							return;
						}
						MultiplayerNotifyMsg( MPMSG_TeamLAM );
						return;
					}
				}
				if ( FrobTarget.IsA('ComputerSecurity') && (PlayerReplicationInfo.team == ComputerSecurity(FrobTarget).team) )
				{
					// Let controlling player re-hack his/her own computer
					bPlayerOwnsIt = False;
					foreach AllActors(class'AutoTurret',turret)
					{
						for (ViewIndex = 0; ViewIndex < ArrayCount(ComputerSecurity(FrobTarget).Views); ViewIndex++)
						{
							if (ComputerSecurity(FrobTarget).Views[ViewIndex].turretTag == turret.Tag)
							{
								if (( turret.safeTarget == Self ) || ( turret.savedTarget == Self ))
								{
									bPlayerOwnsIt = True;
									break;
								}
							}
						}
					}
					if ( !bPlayerOwnsIt )
					{
						MultiplayerNotifyMsg( MPMSG_TeamComputer );
						return;
					}
				}
			}
			// otherwise, just frob it
			DoFrob(Self, None);
		}
	}
	else
	{
		// if there's no FrobTarget, put away an inventory item or drop a decoration
		// or drop the corpse
		if ((inHand != None) && inHand.IsA('POVCorpse'))
			DropItem();
		else
			PutInHand(None);
	}

	if ((oldInHand == None) && (inHand != None))
		PlayPickupAnim(loc);
	else if ((oldCarriedDecoration == None) && (CarriedDecoration != None))
		PlayPickupAnim(loc);
}


function int AnimalHeal(int baseHealPoints, optional Bool bUseMedicineSkill)
{
	local int deltaMax, adjustedHealAmount;

	deltaMax = PawnInfo.default.HealthTorso - HealthTorso;
	adjustedHealAmount = Min(deltaMax, baseHealPoints);
	HealthTorso += adjustedHealAmount;
	Health = HealthTorso;

	if (adjustedHealAmount == 1)
		ClientMessage(Sprintf(HealedPointLabel, adjustedHealAmount));
	else
		ClientMessage(Sprintf(HealedPointsLabel, adjustedHealAmount));

	return adjustedHealAmount;
}

function PlayerCalcView(out actor ViewActor, out vector CameraLocation, out rotator CameraRotation)
{
	super.PlayerCalcView(ViewActor, CameraLocation, CameraRotation);
	CameraLocation += AttackViewOffsetLoc >> CameraRotation;
	CameraRotation += AttackViewOffsetRot;
}

function RobotRightClick()
{
	if (RestrictInput())
		return;

	if (FrobTarget != None)
	{
		if (CBPCarcass(FrobTarget) != none)
		{
			FrobTarget.Destroy();
			SWeaponRobotGun(Inventory).RestockMe();
			ClientMessage(class'AmmoCrate'.default.AmmoReceived);
			PlayLogSound(Sound'WeaponPickup');
			ReplAmmoLow = false;
			return;
		}

		DoFrob(Self, None);
		return;
	}
}

function SEF_ObjectExplode(Actor exp, vector HitLocation)
{
	local int i, num;
	local float explosionRadius;
	local Vector loc;
	local DeusExFragment s;
	local ExplosionLight light;

	explosionRadius = (exp.CollisionRadius + exp.CollisionHeight) / 2;
	exp.PlaySound(Sound'DeusExSounds.Robot.RobotExplode', SLOT_None, 2.0,, explosionRadius*32);

	if (explosionRadius < 48.0)
		exp.PlaySound(sound'LargeExplosion1', SLOT_None,,, explosionRadius*32);
	else
		exp.PlaySound(sound'LargeExplosion2', SLOT_None,,, explosionRadius*32);

	// draw a pretty explosion
	light = Spawn(class'ExplosionLight',,, HitLocation);
	for (i=0; i<explosionRadius/20+1; i++)
	{
		loc = exp.Location + VRand() * exp.CollisionRadius;
		if (explosionRadius < 16)
		{
			Spawn(class'ExplosionSmall',,, loc);
			light.size = 2;
		}
		else if (explosionRadius < 32)
		{
			Spawn(class'ExplosionMedium',,, loc);
			light.size = 4;
		}
		else
		{
			Spawn(class'ExplosionLarge',,, loc);
			light.size = 8;
		}
	}

	// spawn some metal fragments
	//num = FMax(3, explosionRadius/6);
	num = 4;
	for (i=0; i<num; i++)
	{
		s = Spawn(class'MetalFragment', exp,, exp.Location);
		if (s != None)
		{
			//s.Instigator = exp;
			s.CalcVelocity(exp.Velocity, explosionRadius);
			s.DrawScale = explosionRadius*0.075*FRand();
			s.Skin = exp.GetMeshTexture();
			if (FRand() < 0.75)
				s.bSmoking = True;
		}
	}
}

// todo: fix this function
function RobotTakeDamage(int Damage, Pawn instigatedBy, Vector HitLocation, Vector Momentum, name DamageType)
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

	bodyString="";
	origHealth=Health;

	Offset=HitLocation - Location << Rotation;
	//bDamageGotReduced=DXReduceDamage(Damage,DamageType,HitLocation,actualDamage,False);
	//if ( ReducedDamageType == DamageType )
	//{
	//	actualDamage=actualDamage * (1.00 - ReducedDamagePct);
	//}
	//if ( ReducedDamageType == 'All' )
	//{
	//	actualDamage=0;
	//}
	actualDamage = Damage;
	if ( (Level.Game != None) && (Level.Game.DamageMutator != None) )
	{
		Level.Game.DamageMutator.MutatorTakeDamage(actualDamage,self,instigatedBy,HitLocation,Momentum,DamageType);
	}

	if ( bNintendoImmunity || (actualDamage == 0) && (NintendoImmunityTimeLeft > 0.00) )
	{
		return;
	}

	if ( actualDamage <= 0 )
	{
		return;
	}

	if ( DamageType == 'NanoVirus' || DamageType == 'Poison' || DamageType == 'PoisonEffect' || DamageType == 'PoisonGas' || DamageType == 'TearGas')
	{
		return;
	}

	if (DeusExPlayer(instigatedBy) != None)
	{
		VBF=WeaponRifle(DeusExPlayer(instigatedBy).Weapon);
		if ( (VBF != None) &&  !VBF.bZoomed && (VBF.Class == Class'SWeaponRifle') )
		{
			actualDamage *= VBF.mpNoScopeMult;
		}
		if ( Level.Game.bTeamGame && (DeusExPlayer(instigatedBy) != self) && class'CBPGame'.static.ArePlayersAllied(DeusExPlayer(instigatedBy),self))
		{
			actualDamage *= CBPGame(Level.Game).FriendlyFireMult;
			if ( (DamageType != 'TearGas') && (DamageType != 'PoisonEffect') )
			{
				DeusExPlayer(instigatedBy).MultiplayerNotifyMsg(2);
			}
		}
	}

	// todo: fix what happens when EMPed
	if ( DamageType == 'EMP' )
	{
		SGame(Level.Game).GestureReward(SPlayer(instigatedBy), self, 'EMPed', 0.1);
		drugEffectTimer += actualDamage / 15.0;
		drugEffectTimer = FMin(drugEffectTimer, 40.0);
		PlayTakeHitSound(actualDamage,DamageType,1);
		return;
	}

	bPlayAnim=True;
	if ( (DamageType == 'Burned') || PlayerReplicationInfo.bFeigningDeath )
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
	//MPHitLoc=GetMPHitLocation(HitLocation);
	MPHitLoc = 2;
	bodyString=TorsoString;
	HealthArmLeft -= actualDamage;
	HealthTorso -= actualDamage;
	HealthArmRight -= actualDamage;

	Health = HealthTorso;

	LastTakenDamageTime = Level.TimeSeconds;

	if ( carriedDecoration != None )
	{
		DropDecoration();
	}
	if ( Health > 0 )
	{
		if ( (Level.NetMode != 0) && (HealthLegLeft == 0) && (HealthLegRight == 0) )
		{
			ServerConditionalNotifyMsg(10);
		}
		if ( instigatedBy != None )
		{
			damageAttitudeTo(instigatedBy);
		}
		PlayDXTakeDamageHit(actualDamage,HitLocation,DamageType,Momentum,bDamageGotReduced);
	}
	else
	{
		bIsAlive = false;
		NextState='None';
		PlayDeathHit(actualDamage,HitLocation,DamageType,Momentum);

		MyLastKiller = CBPPlayer(instigatedBy);
		if (MyLastKiller == none && damageType == 'Suicided')
			MyLastKiller = self;
		KilledWeapon = DeusExWeapon(MyLastKiller.inHand);

		CreateKillerProfile(instigatedBy,actualDamage,DamageType,bodyString);

		if ( actualDamage > Mass )
		{
			Health=-1 * actualDamage;
		}
		Enemy=instigatedBy;
		Died(instigatedBy,DamageType,HitLocation);
		return;
	}

	if ( (DamageType == 'Flamed') &&  !bOnFire )
	{
		if ( Level.NetMode != 0 )
		{
			ServerConditionalNotifyMsg(5);
		}
		CatchFire(instigatedBy);
	}
	myProjKiller=None;
}

function UpdateTranslucency(float DeltaTime)
{
   if ((inHand != None) && (inHand.IsA('DeusExWeapon')))
   {

	  if (AugmentationSystem != none)
	  {
		if (AugmentationSystem.GetAugLevelValue(class'AugCloak') != -1.0)
		{
			ClientMessage(WeaponUnCloak);
			AugmentationSystem.FindAugmentation(class'AugCloak').Deactivate();
		}
		if (AugmentationSystem.GetAugLevelValue(class'AugRadarTrans') != -1.0)
		{
			ClientMessage("Weapon drawn... Turning Radar Transparency off.");
			AugmentationSystem.FindAugmentation(class'AugRadarTrans').Deactivate();
		}
	  }
   }
}

state Dying
{
	function BeginState()
	{
		super.BeginState();
		if (class<PT_Robot>(PawnInfo) != none)
		{
			class'SGame'.static.SEF_ObjectExplode(self, vect(0,0,0));
		}
	}
}

function bool PropelDecoration()
{
	local Vector X, Y, Z, dropVect, origLoc, HitLocation, HitNormal, extent;
	local float velscale, size, mult;
	local bool bSuccess;
	local Actor hitActor;

	bSuccess = False;

	if (SCrateUnbreakableSmall(CarriedDecoration) != none && AugmentationSystem != none && AugmentationSystem.GetAugLevelValue(class'AugMuscle') != -1.0)
	{
		origLoc = CarriedDecoration.Location;
		GetAxes(Rotation, X, Y, Z);

		// throw velocity is based on augmentation
		CarriedDecoration.Velocity = Vector(ViewRotation) * 3000 + vect(0, 0, 200);

		// scale it based on the mass
		velscale = FClamp(CarriedDecoration.Mass / 20.0, 1.0, 40.0);

		CarriedDecoration.Velocity /= velscale;
		dropVect = Location + (CarriedDecoration.CollisionRadius + CollisionRadius + 4) * X;
		dropVect.Z += BaseEyeHeight;

		// is anything blocking the drop point? (like thin doors)
		if (FastTrace(dropVect))
		{
			CarriedDecoration.SetCollision(True, True, True);
			CarriedDecoration.bCollideWorld = True;

			// check to see if there's space there
			extent.X = CarriedDecoration.CollisionRadius;
			extent.Y = CarriedDecoration.CollisionRadius;
			extent.Z = 1;
			hitActor = Trace(HitLocation, HitNormal, dropVect, CarriedDecoration.Location, True, extent);

			if ((hitActor == None) && CarriedDecoration.SetLocation(dropVect))
				bSuccess = True;
			else
			{
				CarriedDecoration.SetCollision(False, False, False);
				CarriedDecoration.bCollideWorld = False;
			}
		}

		// if we can drop it here, then drop it
		if (bSuccess)
		{
			CarriedDecoration.bWasCarried = True;
			CarriedDecoration.SetBase(None);
			CarriedDecoration.SetPhysics(PHYS_Falling);
			CarriedDecoration.Instigator = Self;

			// turn off translucency
			CarriedDecoration.Style = CarriedDecoration.Default.Style;
			CarriedDecoration.bUnlit = CarriedDecoration.Default.bUnlit;
			if (CarriedDecoration.IsA('DeusExDecoration'))
				DeusExDecoration(CarriedDecoration).ResetScaleGlow();

			SCrateUnbreakableSmall(CarriedDecoration).Instigator = self;
			SCrateUnbreakableSmall(CarriedDecoration).GotoState('DeadlyFly');

			CarriedDecoration = None;
		}
		else
		{
			// otherwise, don't drop it and display a message
			CarriedDecoration.SetLocation(origLoc);
			ClientMessage(CannotDropHere);
		}
	}

	return bSuccess;
}

//exec function ShowShitT()
//{
//	local DeusExRootWindow root;

//	root = DeusExRootWindow(rootWindow);
//	if (root != None)
//	{
//		if (root.actorDisplay == none)
//		{
//			root.actorDisplay=ActorDisplayWindow(root.NewChild(Class'ActorDisplayWindow'));
//			root.actorDisplay.SetWindowAlignments(HALIGN_Full,VALIGN_Full);
//		}
//		root.actorDisplay.SetViewClass(class'SAutoTurret');
//		root.actorDisplay.ShowCylinder(true);
//		//root.actorDisplay.ShowEyes(true);
//	}
//}

defaultproperties
{
    AfterDeathPause=5.00
    DroneSpeedMulti=5.00
    WFlameThrowerClass=Class'SWeaponFlamethrower'
    DeusExHUDClass=Class'SDeusExHUD'
    PlayerTrackClass=Class'SPlayerTrack'
    PlayerReplicationInfoClass=Class'SPlayerReplicationInfo'
}
