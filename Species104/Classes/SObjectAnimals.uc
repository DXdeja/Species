class SObjectAnimals extends SObject;

// force no-FF
auto state Active
{
	function TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, name DamageType)
	{
		if (SNPC(EventInstigator) != none) return;
		super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType);
	}
}

defaultproperties
{
    ItemName="Animals Base"
    Mesh=LodMesh'DeusExDeco.HKBuddha'
    DrawScale=2.00
    CollisionRadius=72.00
    CollisionHeight=107.00
}
