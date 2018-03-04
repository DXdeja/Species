class SWeaponRobotGun extends CBPWeapon;

#exec TEXTURE IMPORT FILE=Textures\ui_robotgun.pcx NAME=ui_robotgun FLAGS=2 MIPS=Off

var float SingleFireTime;

state NormalFire
{
	function AnimEnd()
	{
		SetTimer(SingleFireTime, false);
	}

	function Timer()
	{
		if ((Pawn(Owner).bFire != 0) && (AmmoType.AmmoAmount > 0))
		{
			Global.Fire(0);
		}
		else
			GotoState('FinishFire');
	}
}

simulated state ClientFiring
{
	simulated function AnimEnd()
	{
		SetTimer(SingleFireTime, false);
	}

	simulated function Timer()
	{
		bInProcess = False;

		if ((Pawn(Owner).bFire != 0) && (AmmoType.AmmoAmount > 0))
		{
			ClientReFire(0);
		}
		else
			GotoState('SimFinishFire');
	}
}

simulated function bool ClientFire( float value )
{
	super(DeusExWeapon).ClientFire(value);
}

function RestockMe()
{
	AmmoType.AmmoAmount = PickupAmmoCount;
}

simulated function PlayFiringSound()
{
	if (Owner != none)
	{
		// correct pitch according to firerate
		Owner.PlayOwnedSound(FireSound, SLOT_None, TransientSoundVolume, , 2048, default.SingleFireTime / SingleFireTime);
	}
}

// slow down firing if being emped
simulated function Tick(float DeltaTime)
{
	if (Role == ROLE_Authority || Owner == GetPlayerPawn())
	{
		if (DeusExPlayer(Owner) != none)
		{
			SingleFireTime = default.SingleFireTime + FMin(DeusExPlayer(Owner).drugEffectTimer / 50, 0.4);
			ShotTime = default.ShotTime + FMin(DeusExPlayer(Owner).drugEffectTimer / 200, 0.1);
		}
	}
}

defaultproperties
{
    SingleFireTime=0.40
    weapShotTime=0.42
    LowAmmoWaterMark=80
    GoverningSkill=Class'DeusEx.SkillWeaponRifle'
    EnviroEffective=1
    Concealability=1
    bAutomatic=True
    ShotTime=0.10
    reloadTime=2.00
    HitDamage=5
    maxRange=3000
    AccurateRange=3000
    BaseAccuracy=0.20
    AmmoName=Class'CBPAmmo762mm'
    ReloadCount=80
    PickupAmmoCount=80
    bInstantHit=True
    shakemag=200.00
    FireSound=Sound'DeusExSounds.Robot.RobotFireGun'
    AltFireSound=Sound'DeusExSounds.Weapons.AssaultGunReloadEnd'
    CockingSound=Sound'DeusExSounds.Weapons.AssaultGunReload'
    SelectSound=Sound'DeusExSounds.Weapons.AssaultGunSelect'
    ItemName="Mini Gun"
    PlayerViewOffset=(X=0.00,Y=0.00,Z=0.00),
    PlayerViewMesh=LodMesh'DeusExItems.InvisibleWeapon'
    ThirdPersonMesh=LodMesh'DeusExItems.InvisibleWeapon'
    Icon=Texture'ui_robotgun'
    largeIconWidth=1
    largeIconHeight=1
    Mesh=LodMesh'DeusExItems.InvisibleWeapon'
    CollisionRadius=1.00
    CollisionHeight=1.00
    Mass=5.00
}
