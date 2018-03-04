class Animal_GraySpit extends GraySpit;

function SpawnBlood(Vector HitLocation, Vector HitNormal);

function PostBeginPlay()
{
	super.PostBeginPlay();
	if (SPlayer(Owner) != none)
	{
		Damage = Damage + class'Animal_Gray'.default.ShootImprovementPerLevel[SPlayer(Owner).XPLevel];
	}
}

defaultproperties
{
    AccurateRange=800
    maxRange=900
    ItemName="Gray Spit"
    ItemArticle="a"
    speed=1000.00
    MaxSpeed=1200.00
    Damage=25.00
}
