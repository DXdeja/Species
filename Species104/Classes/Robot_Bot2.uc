class Robot_Bot2 extends PT_Robot;

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
    PrimGestureTexture=Texture'ui_robot_attack'
    SecGestureTexture=Texture'ui_robot_restock'
    GunType=Class'SWeaponRobotGun'
    Mass=800.00
    Buoyancy=100.00
    GroundSpeed=270.00
    CollisionRadius=62.00
    CollisionHeight=58.28
    BaseEyeHeight=45.00
    HealthTorso=600
    Mesh=LodMesh'DeusExCharacters.SecurityBot2'
    MultiSkins=Texture'DeusExCharacters.Skins.SecurityBot2Tex1'
    WalkSound=Sound'DeusExSounds.Robot.SecurityBot2Walk'
}
