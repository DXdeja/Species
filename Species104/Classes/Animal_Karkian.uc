class Animal_Karkian extends PT_Animal;

// todo: fix swimming pivoting; wtf is this shit at all? did creators fucked up when importing animations???
// todo: adjust collisions + drawscale
// todo: crouch should walk

var float BumpDamageMulti;
var float BumpVelocityNeededPerc;
var float BumpImprovementPerLevel[5];

var float AttackAnimSpeed;

static function Event_PlayerTick(CBPPlayer owner, float DeltaTime)
{
	local SPlayer splayer;
	local float sinceAttack, AttackTime, delta;

	super.Event_PlayerTick(owner, DeltaTime);
	splayer = SPlayer(owner);

	AttackTime = (18.0 / 25.0) / default.AttackAnimSpeed;
	sinceAttack = splayer.Level.TimeSeconds - splayer.LastAnimalAttack;
	if (sinceAttack < AttackTime)
	{
		if (sinceAttack >= (AttackTime * 0.65))
		{
			// go back
			sinceAttack = AttackTime - sinceAttack;
			delta = sinceAttack / (AttackTime * 0.35);
		}
		else
		{
			// go on
			delta = sinceAttack / (AttackTime * 0.65);
			delta = Square(Square(delta));
		}
		splayer.AttackViewOffsetLoc = vect(30, 0, 0) * delta;
		splayer.AttackViewOffsetRot = rot(500, 0, 1000) * delta;
	}
	else
	{
		splayer.AttackViewOffsetLoc = vect(0, 0, 0);
		splayer.AttackViewOffsetRot = rot(0, 0, 0);
	}
}

static function vector SetSwimPivot(Actor owner)
{
	owner.PrePivot = (vect(0,0,1) * default.CollisionHeight * 1.0);
}

static function vector ResetSwimPivot(Actor owner)
{
	owner.PrePivot = vect(0,0,0);
}

static function PlayAnimation_InAir(Actor owner)
{
	ResetSwimPivot(owner);
	super.PlayAnimation_InAir(owner);
}

static function PlayAnimation_Landed(Actor owner)
{
	ResetSwimPivot(owner);
	super.PlayAnimation_Landed(owner);
}

static function PlayAnimation_Waiting(Actor owner)
{
	if (owner.IsInState('PlayerSwimming') || (owner.Physics == PHYS_Swimming))
	{
		SetSwimPivot(owner);
		owner.LoopAnim('Tread');
	}
	else
	{
		ResetSwimPivot(owner);
		super.PlayAnimation_Waiting(owner);
	}
}

static function PlayAnimation_TweenToWaiting(Actor owner, float tweentime)
{
	if (owner.IsInState('PlayerSwimming') || (owner.Physics == PHYS_Swimming))
	{
		//SetSwimPivot(owner);
		owner.TweenAnim('Tread', tweentime);
	}
	else
	{
		//ResetSwimPivot(owner);
		super.PlayAnimation_TweenToWaiting(owner, tweentime);
	}
}

static function PlayAnimation_Turning(Actor owner)
{
	ResetSwimPivot(owner);
	super.PlayAnimation_Turning(owner);
}

static function PlayAnimation_Walking(Actor owner, float animrate)
{
	ResetSwimPivot(owner);
	super.PlayAnimation_Walking(owner, animrate);
}

static function PlayAnimation_Running(Actor owner, float animrate)
{
	ResetSwimPivot(owner);
	super.PlayAnimation_Running(owner, animrate);
}

static function PlayAnimation_Swimming(Actor owner)
{
	SetSwimPivot(owner);
	owner.LoopAnim('Tread');
}

static function PlayAnimation_TweenToSwimming(Actor owner, float tweentime)
{
	//SetSwimPivot(owner);
	owner.TweenAnim('Tread', tweentime);
}

static function PlayAnimation_DeathWater(Actor owner)
{
	ResetSwimPivot(owner);
	super.PlayAnimation_DeathWater(owner);
}

static function PlayAnimation_DeathFront(Actor owner)
{
	ResetSwimPivot(owner);
	super.PlayAnimation_DeathFront(owner);
}

static function PlayAnimation_DeathBack(Actor owner)
{
	ResetSwimPivot(owner);
	super.PlayAnimation_DeathBack(owner);
}

static function PlayAnimation_Eat(Actor owner)
{
	ResetSwimPivot(owner);
	owner.PlayAnim('Eat', 1.0, 0.1);
}

static function PlayAnimation_Roar(Actor owner)
{
	ResetSwimPivot(owner);
	owner.PlayAnim('Roar', 2.0, 0.1);
}

static function PlayAnimation_Firing(Actor owner, DeusExWeapon w)
{
	ResetSwimPivot(owner);
	if (owner.Role < ROLE_Authority) SPlayer(owner).LastAnimalAttack = owner.Level.TimeSeconds;
	owner.PlayAnim('Attack', default.AttackAnimSpeed, 0.1);
}

static function PlaySound_Death(Actor owner)
{
	owner.PlaySound(Sound'DeusExSounds.Animal.KarkianDeath', SLOT_Pain,,,, RandomPitch());
}

static function PlaySound_WaterDeath(Actor owner)
{
	owner.PlaySound(Sound'DeusExSounds.Animal.KarkianDeath', SLOT_Pain,,,, RandomPitch() * 0.75);
}

static function PlaySound_Eat(Actor owner)
{
	owner.PlaySound(sound'DeusExSounds.Animal.KarkianEat', SLOT_None,,, 384);
}

static function PlaySound_Roar(Actor owner)
{
	local float multi;
	if (owner.IsInState('PlayerSwimming') || (owner.Physics == PHYS_Swimming)) multi = 0.75;
	else multi = 1.0;
	owner.PlaySound(Sound'DeusExSounds.Animal.KarkianIdle2', SLOT_Pain, 1.0,,, RandomPitch() * multi);
}

static function PlaySound_Attack(Actor owner)
{
	owner.PlaySound(Sound'DeusExSounds.Animal.KarkianAttack', SLOT_None, 1.0, , 2048);
}

static function PlaySound_PainSmall(Actor owner, optional float vol)
{
	owner.PlaySound(Sound'DeusExSounds.Animal.KarkianPainSmall', SLOT_Pain, vol,,, RandomPitch());
}

static function PlaySound_PainMedium(Actor owner, optional float vol)
{
	owner.PlaySound(Sound'DeusExSounds.Animal.KarkianPainLarge', SLOT_Pain, vol,,, RandomPitch());
}

static function PlaySound_PainLarge(Actor owner, optional float vol)
{
	owner.PlaySound(Sound'DeusExSounds.Animal.KarkianPainLarge', SLOT_Pain, vol,,, RandomPitch());
}

static function Exec_ParseRightClick(CBPPlayer owner)
{
	SPlayer(owner).AnimalRightClick();

	if (owner.RestrictInput()) return;

	if (owner.FrobTarget == none)
	{
		// roar
		SPlayer(owner).ClientRoar();
		PlayAnimation_Roar(owner);
	}
}

static function bool IsFrobbable(CBPPlayer owner, Actor A)
{
	if (!A.bHidden)
		if (A.IsA('Mover') /*|| A.IsA('DeusExDecoration')*/ || A.IsA('DeusExCarcass'))
			return True;

	return False;
}

static function Event_Bump(CBPPlayer owner, Actor Other)
{
	SPlayer(owner).KarkianBump(Other);
}

defaultproperties
{
    BumpDamageMulti=0.035
    BumpVelocityNeededPerc=0.80
    BumpImprovementPerLevel(1)=0.005
    BumpImprovementPerLevel(2)=0.01
    BumpImprovementPerLevel(3)=0.017
    BumpImprovementPerLevel(4)=0.03
    AttackAnimSpeed=1.20
    AttackImprovementPerLevel(1)=5.00
    AttackImprovementPerLevel(2)=10.00
    AttackImprovementPerLevel(3)=20.00
    AttackImprovementPerLevel(4)=40.00
    EatHealImprovementPerLevel(1)=10
    EatHealImprovementPerLevel(2)=20
    EatHealImprovementPerLevel(3)=30
    EatHealImprovementPerLevel(4)=40
    PrimGestureTexture=Texture'ui_karkian_attack'
    SecGestureTexture=Texture'ui_karkian_eat'
    AlertSound=Sound'DeusExSounds.Animal.KarkianAlert'
    IdleSound=Sound'DeusExSounds.Animal.KarkianIdle'
    Mass=400.00
    Buoyancy=400.00
    GroundSpeed=450.00
    WaterSpeed=300.00
    UnderWaterTime=99999.00
    AirSpeed=144.00
    AccelRate=500.00
    JumpZ=200.00
    CollisionRadius=50.00
    CollisionHeight=37.10
    SwimmingCollisionHeight=37.10
    BaseEyeHeight=20.00
    bCanJump=True
    bCanRun=True
    bCanSwim=True
    HealthTorso=500
    EatTime=1.00
    EatDamage=20
    EatHeal=50
    AnimalAttackTime=0.70
    AnimalAttackDamage=30
    AnimalAttackDistance=150.00
    AnimalAttackDamageType=Bite
    Mesh=LodMesh'DeusExCharacters.Karkian'
    RotationRate=(Pitch=0,Yaw=30000,Roll=0),
    CarcassType=Class'Carcass_Karkian'
    WalkSound=Sound'DeusExSounds.Animal.KarkianFootstep'
}
