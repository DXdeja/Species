class SWeaponGEPGun extends CBPWeaponGEPGun;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	PickupAmmoCount = mpPickupAmmoCount;
}

defaultproperties
{
    bCanDrop=False
    LowAmmoWaterMark=1
    AmmoNames(0)=Class'DeusEx.AmmoRocketWP'
    AmmoNames(1)=None
    ProjectileNames(0)=Class'DeusEx.RocketWP'
    ProjectileNames(1)=None
    mpPickupAmmoCount=1
    AmmoName=Class'DeusEx.AmmoRocketWP'
    ProjectileClass=Class'DeusEx.RocketWP'
}
