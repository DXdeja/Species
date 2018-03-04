class Animal_GreaselSpit extends GreaselSpit;

function SpawnBlood(Vector HitLocation, Vector HitNormal);

function PostBeginPlay()
{
	super.PostBeginPlay();
	if (SPlayer(Owner) != none)
	{
		Damage = Damage + class'Animal_Greasel'.default.ShootImprovementPerLevel[SPlayer(Owner).XPLevel];
	}
}

simulated function Tick(float DeltaTime)
{
	local SmokeTrail s;

	Super(DeusExProjectile).Tick(DeltaTime);

	time += DeltaTime;
	if ((time > FRand() * 0.05) && (Level.NetMode != NM_DedicatedServer))
	{
		time = 0;

		// spawn some trails
		s = Spawn(class'SmokeTrail',,, Location);
		if (s != None)
		{
			s.DrawScale = FRand() * 0.05;
			s.OrigScale = s.DrawScale;
			s.Texture = Texture'Effects.Smoke.Gas_Poison_A';
			s.Velocity = VRand() * 50;
			s.OrigVel = s.Velocity;
		}
	}
}

defaultproperties
{
    AccurateRange=800
    maxRange=850
    ItemName="Greasel Spit"
    ItemArticle="a"
    speed=1000.00
    MaxSpeed=1200.00
    Damage=11.00
}
