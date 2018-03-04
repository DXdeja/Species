class Animal_Greasel extends PT_Animal;

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
	super.PlayAnimation_Running(owner, animrate * 1.5);
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

static function PlayAnimation_Shoot(Actor owner)
{
	if (owner.IsInState('PlayerSwimming'))
	{
		SetSwimPivot(owner);
		owner.PlayAnim('WaterAttack', 4.0, 0.1);
	}
	else
	{
		ResetSwimPivot(owner);
		owner.PlayAnim('Attack', 4.0, 0.1);
	}
}

static function PlaySound_Death(Actor owner)
{
	owner.PlaySound(Sound'DeusExSounds.Animal.GreaselDeath', SLOT_Pain,,,, RandomPitch());
}

static function PlaySound_WaterDeath(Actor owner)
{
	owner.PlaySound(Sound'DeusExSounds.Animal.GreaselDeath', SLOT_Pain,,,, RandomPitch() * 0.75);
}

static function PlaySound_Eat(Actor owner)
{
	owner.PlaySound(sound'DeusExSounds.Animal.GreaselEat', SLOT_None,,, 384);
}

static function PlaySound_PainSmall(Actor owner, optional float vol)
{
	owner.PlaySound(Sound'DeusExSounds.Animal.GreaselPainSmall', SLOT_Pain, vol,,, RandomPitch());
}

static function PlaySound_PainMedium(Actor owner, optional float vol)
{
	owner.PlaySound(Sound'DeusExSounds.Animal.GreaselPainLarge', SLOT_Pain, vol,,, RandomPitch());
}

static function PlaySound_PainLarge(Actor owner, optional float vol)
{
	owner.PlaySound(Sound'DeusExSounds.Animal.GreaselPainLarge', SLOT_Pain, vol,,, RandomPitch());
}

static function Exec_ParseRightClick(CBPPlayer owner)
{
	SPlayer(owner).AnimalRightClick();
}

static function bool IsFrobbable(CBPPlayer owner, Actor A)
{
	if (!A.bHidden)
		if (A.IsA('Mover') /*|| A.IsA('DeusExDecoration')*/ || A.IsA('DeusExCarcass'))
			return True;

	return False;
}

static function Exec_ParseLeftClick(CBPPlayer owner)
{
	SPlayer(owner).AnimalShoot();
}

static function Event_ServerTick(CBPPlayer owner, float DeltaTime)
{
	// check if wants to fire but no action going on
	if (owner.bFire != 0 && !SPlayer(owner).bAnimalShoot)
	{
		SPlayer(owner).AnimalShoot();
	}
}

defaultproperties
{
    ShootImprovementPerLevel(1)=2.00
    ShootImprovementPerLevel(2)=4.00
    ShootImprovementPerLevel(3)=6.00
    ShootImprovementPerLevel(4)=8.00
    EatHealImprovementPerLevel(1)=3
    EatHealImprovementPerLevel(2)=8
    EatHealImprovementPerLevel(3)=13
    EatHealImprovementPerLevel(4)=18
    PrimGestureTexture=Texture'ui_greasel_attack'
    SecGestureTexture=Texture'ui_greasel_eat'
    PrimGesturePicText="SHOOT"
    AlertSound=Sound'DeusExSounds.Animal.GreaselAlert'
    IdleSound=Sound'DeusExSounds.Animal.GreaselIdle'
    Mass=40.00
    Buoyancy=40.00
    GroundSpeed=300.00
    WaterSpeed=250.00
    UnderWaterTime=99999.00
    AirSpeed=144.00
    AccelRate=1024.00
    JumpZ=300.00
    CollisionRadius=20.00
    CollisionHeight=22.00
    SwimmingCollisionHeight=22.00
    BaseEyeHeight=13.00
    bCanJump=True
    bCanRun=True
    bCanSwim=True
    HealthTorso=200
    EatTime=1.00
    EatDamage=20
    EatHeal=12
    AnimalShootTime=0.80
    AnimalShootProj=Class'Animal_GreaselSpit'
    Mesh=LodMesh'DeusExCharacters.Greasel'
    CarcassType=Class'Carcass_Greasel'
    WalkSound=Sound'DeusExSounds.Animal.GreaselFootstep'
}
