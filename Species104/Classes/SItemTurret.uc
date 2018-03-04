class SItemTurret extends CBPPickup;

#exec TEXTURE IMPORT FILE=Textures\ui_turret.pcx NAME=ui_turret FLAGS=2 MIPS=Off

var class<SAutoTurret> AutoTurretClass;

var localized string TurretPlaced;
var localized string CannotPlaceTurret;

function bool PlaceTurret(SPlayer player)
{
	local Vector HitLocation, HitNormal, StartTrace, EndTrace, Extent;
	local Actor HitActor;
	local Rotator TurretRot;
	local SAutoTurret Turret;

	StartTrace = player.Location;
	EndTrace = player.Location + (Vector(player.ViewRotation) * player.MaxFrobDistance);
	StartTrace.Z += player.BaseEyeHeight;
	EndTrace.Z += player.BaseEyeHeight;

	Extent.Z = AutoTurretClass.default.CollisionHeight;
	Extent.Y = 2 * AutoTurretClass.default.CollisionRadius;
	Extent.X = Extent.Y;

	HitActor = player.Trace(HitLocation, HitNormal, EndTrace, StartTrace, , Extent);
	if (HitActor != Level || HitNormal != vect(0, 0, 1.0)) return false;
	if (HitLocation.Z > player.Location.Z) return false;

	TurretRot = player.ViewRotation;
	TurretRot.Pitch = 0;
	TurretRot.Roll = 0;

	Turret = Spawn(AutoTurretClass, player, , HitLocation, TurretRot);
	if (Turret != none)
	{
		Turret.SetSafeTarget(player);
		return true;
	}

	return false;
}

state Activated
{
	function Activate()
	{
		// can't turn it off
	}

	function BeginState()
	{
		local SPlayer player;

		Super.BeginState();

		player = SPlayer(Owner);
		if (player == none) return;

		if (PlaceTurret(player))
		{
			player.ClientMessage(TurretPlaced);
			if (SGame(Level.Game) != none)
				SGame(Level.Game).GestureReward(player, none, 'TurretPlaced', 0.5);
			UseOnce();
		}
		else
		{
			player.ClientMessage(CannotPlaceTurret);
			GotoState('Pickup');
		}
	}
Begin:
}

function bool UpdateInfo(Object winObject)
{
}

defaultproperties
{
    AutoTurretClass=Class'SAutoTurret'
    TurretPlaced="Auto turret has been placed."
    CannotPlaceTurret="Cannot place auto turret here."
    bCanDrop=False
    maxCopies=2
    bCanHaveMultipleCopies=True
    bActivatable=True
    ItemName="Auto Turret"
    PlayerViewOffset=(X=20.00,Y=0.00,Z=-12.00),
    PlayerViewMesh=LodMesh'DeusExDeco.AutoTurretGun'
    PlayerViewScale=0.30
    PickupViewMesh=LodMesh'DeusExDeco.AutoTurretGun'
    PickupViewScale=0.30
    ThirdPersonMesh=LodMesh'DeusExDeco.AutoTurretGun'
    ThirdPersonScale=0.30
    LandSound=Sound'DeusExSounds.Generic.PlasticHit2'
    Icon=Texture'ui_turret'
    largeIcon=Texture'ui_turret'
    largeIconWidth=44
    largeIconHeight=43
    Description="When placed, it fires on enemy targets."
    beltDescription="AUTOTURRET"
    Mesh=LodMesh'DeusExDeco.AutoTurretGun'
    bOnlyOwnerSee=True
    CollisionRadius=5.00
    CollisionHeight=5.00
    Mass=5.00
    Buoyancy=4.00
}
