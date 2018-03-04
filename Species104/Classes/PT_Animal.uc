class PT_Animal extends PawnType
	abstract;

var float AttackImprovementPerLevel[5];
var float ShootImprovementPerLevel[5];
var int EatHealImprovementPerLevel[5];

var Color BackgroundColor;
var Color BackgroundSelectedColor;
var Color LineColor;
var Color LineSelectedColor;
var Color TextColor;
var Font TextFont;
var Texture PrimGestureTexture;
var Texture SecGestureTexture;
var string PrimGesturePicText;
var string SecGesturePicText;
var string PrimGestureText;
var string SecGestureText;

var Texture HealthTexture;
var Texture HealthFullTexture;

var Sound AlertSound;
var Sound IdleSound;

static function AnimalSpecial(SPlayer owner, byte num)
{
	if (!owner.bIsAlive) return;
	if ((owner.LastSpecialSoundTime + 2.0) > owner.Level.TimeSeconds) return;

	if (num == 0) owner.PlaySound(default.AlertSound, SLOT_None);
	else if (num == 1) owner.PlaySound(default.IdleSound, SLOT_None);
	else return;

	owner.LastSpecialSoundTime = owner.Level.TimeSeconds;
}

static function HUDDrawPrimGesture(SPlayer owner, Canvas canvas, int Xoff)
{
	class'PT_Shared'.static.HUDDrawGesturePic(canvas, Xoff, default.PrimGestureTexture, default.PrimGesturePicText);
	class'PT_Shared'.static.HUDDrawGestureText(canvas, Xoff, default.PrimGestureText);
}

static function HUDDrawSecGesture(SPlayer owner, Canvas canvas, int Xoff)
{
	class'PT_Shared'.static.HUDDrawGesturePic(canvas, Xoff, default.SecGestureTexture, default.SecGesturePicText);
	class'PT_Shared'.static.HUDDrawGestureText(canvas, Xoff, default.SecGestureText);
}

static function Event_HUDDraw(CBPPlayer owner, Canvas canvas)
{
	local int X;
	local SPlayer splayer;

	class'PT_Shared'.static.HUDDraw(SPlayer(owner), canvas);

	splayer = SPlayer(owner);

	// draw special icons
	X = canvas.SizeX / 2 - (66 + 32);

	// if can attack
	HUDDrawPrimGesture(splayer, canvas, X);
	X += 66 + 64;

	// if can shoot / eat
	HUDDrawSecGesture(splayer, canvas, X);

	// draw health
	class'PT_Shared'.static.HUDDrawHealth(splayer, canvas, default.HealthTexture, default.HealthFullTexture, float(default.HealthTorso));
}

static function PlayAnimation_InAir(Actor owner)
{
	if (PlayingAnimGroup_Attack(owner)) return;
	owner.PlayAnim('Still', 3.0, 0.1);
}

static function PlayAnimation_Landed(Actor owner)
{
	if (CBPPlayer(owner) != none) CBPPlayer(owner).PlayFootStep();
	owner.PlayAnim('Still', 3.0, 0.1);
}

static function PlayAnimation_Waiting(Actor owner)
{
	//log("PlayAnimation_Waiting");
	owner.LoopAnim('BreatheLight');
}

static function PlayAnimation_TweenToWaiting(Actor owner, float tweentime)
{
	//log("PlayAnimation_TweenToWaiting");
	owner.TweenAnim('BreatheLight', tweentime);
}

static function PlayAnimation_Turning(Actor owner)
{
	//log("PlayAnimation_Turning");
	owner.TweenAnim('Walk', 0.1);
}

static function PlayAnimation_TweenToWalking(Actor owner, float tweentime)
{
	owner.TweenAnim('Walk', tweentime);
}

static function PlayAnimation_Walking(Actor owner, float animrate)
{
	owner.LoopAnim('Walk', animrate * 1.5, 0.15);
}

static function PlayAnimation_TweenToRunning(Actor owner, float tweentime, float animrate)
{
	//log("PlayAnimation_TweenToRunning");
	owner.TweenAnim('Run', tweentime);
}

static function PlayAnimation_Running(Actor owner, float animrate)
{
	//log("PlayAnimation_Running");
	owner.LoopAnim('Run', animrate);
}

static function PlayAnimation_DeathWater(Actor owner)
{
	owner.PlayAnim('DeathFront',,0.1);
}

static function PlayAnimation_DeathFront(Actor owner)
{
	owner.PlayAnim('DeathFront',,0.1);
}

static function PlayAnimation_DeathBack(Actor owner)
{
	owner.PlayAnim('DeathBack',,0.1);
}

static function PlayAnimation_HitTorso(Actor owner)
{
	if (owner.AnimSequence == 'Attack' || owner.AnimSequence == 'WaterAttack') return;
	owner.PlayAnim('HitFront',,0.1);
}

static function PlayAnimation_HitTorsoBack(Actor owner)
{
	if (owner.AnimSequence == 'Attack' || owner.AnimSequence == 'WaterAttack') return;
	owner.PlayAnim('HitBack',,0.1);
}

static function bool PlayingAnimGroup_Waiting(Actor owner)
{
	if (owner.AnimSequence == 'BreatheLight') return true;
	else return false;
}

static function bool PlayingAnimGroup_Gesture(Actor owner)
{
	if (owner.AnimSequence == 'Roar') return true;
	else return false;
}

static function bool PlayingAnimGroup_TakeHit(Actor owner)
{
	if (owner.AnimSequence == 'HitFront' || owner.AnimSequence == 'HitBack') return true;
	else return false;
}

static function bool PlayingAnimGroup_Landing(Actor owner)
{
	return false;
}

static function bool PlayingAnimGroup_Attack(Actor owner)
{
	// eat, hitfront, hitback is here because else waiting and running anims get over it
	if (owner.AnimSequence == 'Eat' ||
		owner.AnimSequence == 'Attack' ||
		owner.AnimSequence == 'WaterAttack' ||
		owner.AnimSequence == 'Shoot' ||
		owner.AnimSequence == 'HitFront' ||
		owner.AnimSequence == 'HitBack') return true;
	return false;
}

static function Event_TakeDamage(Pawn owner, int Damage, Pawn instigatedBy, Vector HitLocation, Vector Momentum, name DamageType)
{
	if (SPlayer(owner) != none)
		SPlayer(owner).AnimalTakeDamage(Damage, instigatedBy, HitLocation, Momentum, DamageType);
	else if (SNPC(owner) != none)
		SNPC(owner).AnimalTakeDamage(Damage, instigatedBy, HitLocation, Momentum, DamageType);
}

static function Exec_ParseLeftClick(CBPPlayer owner)
{
	SPlayer(owner).AnimalLeftClick();
}

static function Event_ServerTick(CBPPlayer owner, float DeltaTime)
{
	// check if wants to fire but no action going on
	if (owner.bFire != 0 && !SPlayer(owner).bAnimalAttack)
	{
		SPlayer(owner).AnimalLeftClick();
	}
}

static function int Event_HealPlayer(CBPPlayer owner, int baseHealPoints, optional bool bUseMedicineSkill)
{
	return SPlayer(owner).AnimalHeal(baseHealPoints, bUseMedicineSkill);
}

defaultproperties
{
    BackgroundColor=(R=40,G=40,B=40,A=0),
    BackgroundSelectedColor=(R=127,G=127,B=127,A=0),
    LineColor=(R=80,G=80,B=80,A=0),
    LineSelectedColor=(R=200,G=200,B=200,A=0),
    TextColor=(R=255,G=255,B=255,A=0),
    textFont=Font'DeusExUI.FontMenuSmall_DS'
    PrimGesturePicText="ATTACK"
    SecGesturePicText="EAT"
    PrimGestureText="<Left Mouse Button>"
    SecGestureText="<Right Mouse Button>"
    HealthTexture=Texture'ui_karkian_health'
    HealthFullTexture=Texture'ui_karkian_health_full'
    BeltInventoryClass=None
    AugManagerClass=None
    SkillManagerClass=None
    bCanBleed=True
    bOwnHealthBar=True
}
