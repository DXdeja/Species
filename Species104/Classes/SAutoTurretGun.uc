class SAutoTurretGun extends AutoTurretGun;

function PostPostBeginPlay()
{
	// get rid of Log: DeusExLevelInfo object missing!  Unable to bind Conversations!
}

auto state Active
{
	function TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, name DamageType)
	{
		if (Owner != none)
			Owner.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType);
	}
}

function PreBeginPlay()
{
	Super(HackableDevices).PreBeginPlay();
}

defaultproperties
{
    bHighlight=False
    bCollideWorld=True
}
