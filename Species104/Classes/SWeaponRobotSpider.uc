class SWeaponRobotSpider extends SWeaponRobotGun;

#exec TEXTURE IMPORT FILE=Textures\ui_spider_el.pcx NAME=ui_spider_el FLAGS=2 MIPS=Off

var ElectricityEmitter emitter;
var float zapTimer;
var vector lastHitLocation;
var int shockDamage;

var bool bEmitterOnRepl;
var bool bEmitterOn;

replication
{
	reliable if (Role == ROLE_Authority)
		bEmitterOnRepl, lastHitLocation;
}

function ProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	local float        mult;
	local name         damageType;
	local DeusExPlayer dxPlayer;

	if (Other != None)
	{
		// AugCombat increases our damage if hand to hand
		mult = 1.0;

		// skill also affects our damage
		// GetWeaponSkill returns 0.0 to -0.7 (max skill/aug)
		mult += -2.0 * GetWeaponSkill();

		if ((Other == Level) || (Other.IsA('Mover')))
		{
			if ( Role == ROLE_Authority )
				Other.TakeDamage(HitDamage * mult, Pawn(Owner), HitLocation, 1000.0*X, 'Shot');

			SelectiveSpawnEffects( HitLocation, HitNormal, Other, HitDamage * mult);
		}
		else if ((Other != self) && (Other != Owner))
		{
			if ( Role == ROLE_Authority )
			{
				Other.TakeDamage(HitDamage * mult, Pawn(Owner), HitLocation, 1000.0*X, 'Shot');
				if (SPlayer(Other) != none && SPlayer(Other).Energy > 0.0)
					// reward for taking energy
					SGame(Level.Game).GestureReward(SPlayer(Owner), SPlayer(Other), 'SpiderEMP', 0.1);
				Other.TakeDamage(shockDamage * mult, Pawn(Owner), HitLocation, 1000.0*X, 'EMP');
			}
			//if (bHandToHand)
			//	SelectiveSpawnEffects( HitLocation, HitNormal, Other, HitDamage * mult);

			if (Role == ROLE_Authority && CBPPlayer(Other) != none)
			{
				if (bPenetrating && CBPPlayer(Other).bCanBleed)
					class'CBPGame'.static.SEF_SpawnBloodFromWeapon(Other, HitLocation, HitNormal);
			}
		}
	}

	zapTimer = 0.3;
	bEmitterOnRepl = true;
	lastHitLocation = HitLocation;
}

simulated function Tick(float deltaTime)
{
	Super.Tick(deltaTime);

	if (Role < ROLE_Authority)
	{
		// perform on clients only
		if (bEmitterOnRepl)
		{
			if (!bEmitterOn)
			{
				emitter.TurnOn();
				emitter.SetBase(Owner);
				bEmitterOn = true;
			}

			emitter.SetLocation(Owner.Location);
			emitter.SetRotation(Rotator(lastHitLocation - emitter.Location));
		}

		if (!bEmitterOnRepl)
		{
			if (bEmitterOn)
			{
				emitter.TurnOff();
				bEmitterOn = false;
			}
		}
	}
	else
	{
		if (zapTimer > 0)
		{
			zapTimer -= deltaTime;
			if (zapTimer < 0)
			{
				zapTimer = 0;
				bEmitterOnRepl = false;
			}
		}
	}
}

simulated function Destroyed()
{
	if (Role < ROLE_Authority)
	{
		if (emitter != None)
		{
			emitter.Destroy();
			emitter = None;
		}
	}

	Super.Destroyed();
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	if (Role < ROLE_Authority)
	{
		emitter = Spawn(class'ElectricityEmitter', Self);
		if (emitter != None)
		{
			emitter.bFlicker = False;
			emitter.randomAngle = 1024;
			emitter.damageAmount = 0;
			emitter.TurnOff();
			emitter.Instigator = Pawn(Owner);
			emitter.AmbientSound = none;
		}
	}
}

defaultproperties
{
    shockDamage=20
    SingleFireTime=0.50
    weapShotTime=0.52
    LowAmmoWaterMark=20
    ShotTime=1.00
    maxRange=1280
    AccurateRange=640
    BaseAccuracy=0.00
    AmmoName=Class'DeusEx.AmmoBattery'
    ReloadCount=60
    PickupAmmoCount=20
    FireSound=Sound'DeusExSounds.Weapons.ProdFire'
    AltFireSound=Sound'DeusExSounds.Weapons.ProdReloadEnd'
    CockingSound=Sound'DeusExSounds.Weapons.ProdReload'
    SelectSound=Sound'DeusExSounds.Weapons.ProdSelect'
    ItemName="Electricity"
    ItemArticle="an"
    Icon=Texture'ui_spider_el'
}
