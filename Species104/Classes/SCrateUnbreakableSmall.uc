class SCrateUnbreakableSmall extends CrateUnbreakableSmall;

var int HitDamage;
var SPlayer Instigator;

function PostPostBeginPlay()
{
	// get rid of Log: DeusExLevelInfo object missing!  Unable to bind Conversations!
}

state DeadlyFly
{
	function Bump(actor Other)
	{
		if (Other == Instigator) return;
		Other.TakeDamage(HitDamage, Instigator, Location - Other.Location, 100 * Velocity, 'ThrownDecoration');
		PlaySound(sound'MetalHit2', SLOT_None);
		GotoState('Active');
	}
}

defaultproperties
{
    HitDamage=180
}
