class Animal_Gray extends PT_Animal;

var float FieldCheckInterval;
var int FieldDamagePerLevel[5];
var float FieldRadius;
var int FieldHealPerLevel[5];

static function Event_ServerTick(CBPPlayer owner, float DeltaTime)
{
	local SPlayer splayer, en;
	local bool bHealed;

	super.Event_ServerTick(owner, DeltaTime);

	splayer = SPlayer(owner);
	if (splayer == none) return;

	if (owner.bIsAlive)
	{
		owner.LightType = LT_Steady;
		owner.LightBrightness = 32;
		owner.LightHue = 96;
		owner.LightSaturation = 128;
		owner.LightRadius = 5;
		owner.ScaleGlow = 10.0;
	}
	else
	{
		owner.LightType = owner.default.LightType;
		owner.LightBrightness = owner.default.LightBrightness;
		owner.LightHue = owner.default.LightHue;
		owner.LightSaturation = owner.default.LightSaturation;
		owner.LightRadius = owner.default.LightRadius;
		owner.ScaleGlow = owner.default.ScaleGlow;
		return;
	}

	splayer.FieldCheckTime += deltaTime;

	if (splayer.FieldCheckTime >= default.FieldCheckInterval)
	{
		splayer.FieldCheckTime = 0.0;
		foreach splayer.VisibleActors(class'SPlayer', en, default.FieldRadius)
		{
			if (en == splayer) continue;

			if (!class'CBPGame'.static.ArePlayersAllied(splayer, en))
			{
				en.TakeDamage(default.FieldDamagePerLevel[splayer.XPLevel], splayer, en.Location, vect(0,0,0), 'Radiation');
			}
			else if (!bHealed && en.PawnInfo == class'Animal_Gray')
			{
				bHealed = true;
				// if it is another gray, heal self
				// todo: check number of all grays and adjust healing according to number of them
				if (splayer.HealthTorso < default.HealthTorso)
				{
					splayer.HealPlayer(default.FieldHealPerLevel[splayer.XPLevel], false);
					splayer.ClientFlash(0.5, vect(0, 0, 500));
				}
			}
		}
	}
}

static function PlayAnimation_Firing(Actor owner, DeusExWeapon w)
{
	owner.PlayAnim('Attack', 1.5, 0.1);
}

static function PlayAnimation_Shoot(Actor owner)
{
	owner.PlayAnim('Shoot', 1.5, 0.1);
}

static function PlaySound_Death(Actor owner)
{
	owner.PlaySound(Sound'DeusExSounds.Animal.GrayDeath', SLOT_Pain,,,, RandomPitch());
}

static function PlaySound_WaterDeath(Actor owner)
{
	owner.PlaySound(Sound'DeusExSounds.Animal.GrayDeath', SLOT_Pain,,,, RandomPitch() * 0.75);
}

static function PlaySound_Attack(Actor owner)
{
	owner.PlaySound(Sound'DeusExSounds.Animal.GrayAttack', SLOT_None, 1.0, , 2048);
}

static function PlaySound_Shoot(Actor owner)
{
	owner.PlaySound(Sound'DeusExSounds.Animal.GrayShoot', SLOT_None, 1.0, , 2048);
}

static function PlaySound_PainSmall(Actor owner, optional float vol)
{
	owner.PlaySound(Sound'DeusExSounds.Animal.GrayPainSmall', SLOT_Pain, vol,,, RandomPitch());
}

static function PlaySound_PainMedium(Actor owner, optional float vol)
{
	owner.PlaySound(Sound'DeusExSounds.Animal.GrayPainLarge', SLOT_Pain, vol,,, RandomPitch());
}

static function PlaySound_PainLarge(Actor owner, optional float vol)
{
	owner.PlaySound(Sound'DeusExSounds.Animal.GrayPainLarge', SLOT_Pain, vol,,, RandomPitch());
}

static function bool IsFrobbable(CBPPlayer owner, Actor A)
{
	if (!A.bHidden)
		if (A.IsA('Mover') /*|| A.IsA('DeusExDecoration')*/)
			return True;

	return False;
}

static function Exec_ParseRightClick(CBPPlayer owner)
{
	SPlayer(owner).GrayRightClick();
}

defaultproperties
{
    FieldCheckInterval=1.00
    FieldDamagePerLevel(0)=2
    FieldDamagePerLevel(1)=4
    FieldDamagePerLevel(2)=6
    FieldDamagePerLevel(3)=8
    FieldDamagePerLevel(4)=10
    FieldRadius=160.00
    FieldHealPerLevel(0)=2
    FieldHealPerLevel(1)=3
    FieldHealPerLevel(2)=4
    FieldHealPerLevel(3)=5
    FieldHealPerLevel(4)=6
    AttackImprovementPerLevel(1)=8.00
    AttackImprovementPerLevel(2)=16.00
    AttackImprovementPerLevel(3)=24.00
    AttackImprovementPerLevel(4)=32.00
    ShootImprovementPerLevel(1)=4.00
    ShootImprovementPerLevel(2)=8.00
    ShootImprovementPerLevel(3)=12.00
    ShootImprovementPerLevel(4)=16.00
    PrimGestureTexture=Texture'ui_gray_attack'
    SecGestureTexture=Texture'ui_gray_shoot'
    SecGesturePicText="SHOOT"
    AlertSound=Sound'DeusExSounds.Animal.GrayAlert'
    IdleSound=Sound'DeusExSounds.Animal.GrayIdle'
    Mass=120.00
    Buoyancy=97.00
    GroundSpeed=350.00
    WaterSpeed=20.00
    UnderWaterTime=1.00
    AirSpeed=144.00
    AccelRate=1000.00
    JumpZ=400.00
    CollisionRadius=22.00
    CollisionHeight=42.00
    SwimmingCollisionHeight=42.00
    BaseEyeHeight=32.00
    bCanJump=True
    bCanRun=True
    HealthTorso=200
    AugManagerClass=Class'SAugManager_Gray'
    AnimalAttackTime=0.60
    AnimalAttackDamage=25
    AnimalAttackDistance=150.00
    AnimalAttackDamageType=Swipe
    AnimalShootTime=0.80
    AnimalShootProj=Class'Animal_GraySpit'
    Mesh=LodMesh'DeusExCharacters.Gray'
    CarcassType=Class'Carcass_Gray'
    PrePivot=(X=0.00,Y=0.00,Z=-5.00),
    WalkSound=Sound'DeusExSounds.Animal.GrayFootstep'
    AmbientSound=Sound'Ambient.Ambient.GeigerLoop'
}
