class Robot_Spider extends PT_Robot;

static function PlayAnimation_Turning(Actor owner)
{
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

static function bool PlayingAnimGroup_Waiting(Actor owner)
{
	if (owner.AnimSequence == 'BreatheLight') return true;
	else return false;
}

defaultproperties
{
    PrimGestureTexture=Texture'ui_spider_attack'
    SecGestureTexture=Texture'ui_spider_restock'
    AutoHealPerLevel(0)=4
    AutoHealPerLevel(1)=5
    AutoHealPerLevel(2)=6
    AutoHealPerLevel(3)=7
    AutoHealPerLevel(4)=8
    GunType=Class'SWeaponRobotSpider'
    Mass=200.00
    Buoyancy=50.00
    GroundSpeed=450.00
    CollisionRadius=30.00
    CollisionHeight=20.00
    BaseEyeHeight=10.00
    HealthTorso=300
    Mesh=LodMesh'DeusExCharacters.SpiderBot2'
    WalkSound=Sound'DeusExSounds.Robot.SpiderBot2Walk'
}
