class SObject extends DeusExDecoration;

var byte Team;
var bool bBurning;

function PostPostBeginPlay()
{
	// get rid of Log: DeusExLevelInfo object missing!  Unable to bind Conversations!
}

function Ignite()
{
	local Fire f;
	local int i;
	local vector loc;

	for (i=0; i<8; i++)
	{
		loc.X = 0.9*CollisionRadius * (1.0-2.0*FRand());
		loc.Y = 0.9*CollisionRadius * (1.0-2.0*FRand());
		loc.Z = 0.9*CollisionHeight * (1.0-2.0*FRand());
		loc += Location;
		f = Spawn(class'Fire', Self,, loc);
		if (f != None)
		{
			f.DrawScale = FRand() + 1.0;
			f.LifeSpan = Flammability;

			// turn off the sound and lights for all but the first one
			if (i > 0)
			{
				f.AmbientSound = None;
				f.LightType = LT_None;
			}

			// turn on/off extra fire and smoke
			if (FRand() < 0.5)
				f.smokeGen.Destroy();
			if (FRand() < 0.5)
				f.AddFire(1.5);
		}
	}
}

auto state Active
{
	function TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, name DamageType)
	{
		if (SPlayer(EventInstigator) != none)
		{
			// FF for now disabled
			if (EventInstigator.PlayerReplicationInfo.Team == Team) return;
			if ((SPlayer(EventInstigator).LastObjectAttackTime + 0.5) > Level.TimeSeconds) return;
			class'PT_Shared'.static.GestureReward(SPlayer(EventInstigator), none, 'ObjectHurt', 0.05); // give +5%
			SPlayer(EventInstigator).LastObjectAttackTime = Level.TimeSeconds;
		}
		Damage = 1;
		DamageType = 'Shot';
		super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType);
		if (!bBurning && (float(HitPoints) / float(default.HitPoints)) < 0.20)
		{
			bBurning = true;
			Ignite();
		}
	}
}

function Destroyed()
{
	super.Destroyed();
	if (Team == 0) CBPGame(Level.Game).FinishGame(1);
	else CBPGame(Level.Game).FinishGame(0);
}

defaultproperties
{
    HitPoints=500
    Flammability=0.00
    bHighlight=False
    bPushable=False
    bAlwaysRelevant=True
    Mass=1000.00
    bVisionImportant=True
    NetUpdateFrequency=5.00
}
