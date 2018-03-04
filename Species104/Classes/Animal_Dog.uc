class Animal_Dog extends PT_Animal;

static function PlayAnimation_HitTorso(Actor owner)
{
}

static function PlayAnimation_HitTorsoBack(Actor owner)
{
}

static function PlayAnimation_Eat(Actor owner)
{
	owner.PlayAnim('Attack', 1.5, 0.1);
}

static function PlaySound_Death(Actor owner)
{
	owner.PlaySound(Sound'DeusExSounds.Animal.DogLargeDie', SLOT_Pain,,,, RandomPitch());
}

static function PlaySound_WaterDeath(Actor owner)
{
	owner.PlaySound(Sound'DeusExSounds.Animal.DogLargeDie', SLOT_Pain,,,, RandomPitch() * 0.75);
}

static function PlaySound_Eat(Actor owner)
{
	owner.PlaySound(sound'DeusExSounds.Animal.GreaselEat', SLOT_None,,, 384);
}

static function PlaySound_PainSmall(Actor owner, optional float vol)
{
	owner.PlaySound(Sound'DeusExSounds.Animal.DogLargePain', SLOT_Pain, vol,,, RandomPitch());
}

static function PlaySound_PainMedium(Actor owner, optional float vol)
{
	owner.PlaySound(Sound'DeusExSounds.Animal.DogLargeGrowl', SLOT_Pain, vol,,, RandomPitch());
}

static function PlaySound_PainLarge(Actor owner, optional float vol)
{
	owner.PlaySound(Sound'DeusExSounds.Animal.DogLargeDie', SLOT_Pain, vol,,, RandomPitch());
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
}

static function PlayAnimation_Firing(Actor owner, DeusExWeapon w)
{
	owner.PlayAnim('Attack', 2.0, 0.1);
}

static function Event_Bump(CBPPlayer owner, Actor Other)
{
	if (SPlayer(owner).bAnimalAttack && SPlayer(owner).bDogBump && owner.Physics == PHYS_Falling)
		SPlayer(owner).DogBump(Other);
}

static function Event_ServerTick(CBPPlayer owner, float DeltaTime);

static function Exec_Fire(CBPPlayer owner, float F)
{
	if (owner.Role < ROLE_Authority) SPlayer(owner).ServerDogAttack();
	else SPlayer(owner).DogAttack();
}

defaultproperties
{
    AttackImprovementPerLevel(1)=5.00
    AttackImprovementPerLevel(2)=10.00
    AttackImprovementPerLevel(3)=20.00
    AttackImprovementPerLevel(4)=40.00
    EatHealImprovementPerLevel(1)=5
    EatHealImprovementPerLevel(2)=10
    EatHealImprovementPerLevel(3)=15
    EatHealImprovementPerLevel(4)=20
    PrimGestureTexture=Texture'ui_dog_attack'
    SecGestureTexture=Texture'ui_dog_eat'
    Mass=25.00
    Buoyancy=27.00
    GroundSpeed=500.00
    WaterSpeed=100.00
    UnderWaterTime=10.00
    AirSpeed=144.00
    AccelRate=5000.00
    JumpZ=400.00
    CollisionRadius=30.00
    CollisionHeight=28.00
    SwimmingCollisionHeight=28.00
    BaseEyeHeight=20.00
    bCanJump=True
    bCanRun=True
    bCanSwim=True
    HealthTorso=150
    EatTime=1.00
    EatDamage=20
    EatHeal=15
    AnimalAttackTime=0.75
    AnimalAttackDamage=40
    AnimalAttackDamageType=Bite
    Mesh=LodMesh'DeusExCharacters.Doberman'
    CarcassType=Class'Carcass_Dog'
}
