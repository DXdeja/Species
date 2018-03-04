class FireCloud extends Cloud;

function Timer()
{
	//local Actor A;
	//local Vector HitLocation;

	//foreach VisibleCollidingActors(class 'Actor', A, cloudRadius, HitLocation)
	//{
	//	A.TakeDamage(Damage, Instigator, HitLocation, vect(0,0,0), damageType);
	//}
}

event Touch(Actor Other)
{
	Other.TakeDamage(Damage, Instigator, Other.Location, vect(0,0,0), damageType);
}

defaultproperties
{
    DamageType=Flamed
    maxDrawScale=2.00
    Damage=5.00
    Physics=PHYS_Falling
    Texture=FireTexture'Effects.Fire.OnFire_J'
    AmbientSound=Sound'Ambient.Ambient.FireSmall1'
    CollisionRadius=32.00
}
