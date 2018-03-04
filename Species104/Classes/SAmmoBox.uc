class SAmmoBox extends CBPPickup;

#exec TEXTURE IMPORT FILE=Textures\ui_ammobox.pcx NAME=ui_ammobox FLAGS=2 MIPS=Off

var localized String msgAmmoRestock;

state Activated
{
	function Activate()
	{
		// can't turn it off
	}

	function BeginState()
	{
		local SPlayer player, affected;
		local bool bWasAmmoLow;

		Super.BeginState();

		player = SPlayer(Owner);

		if (player != none && SPlayer(player.FrobTarget) != none &&
			class'CBPGame'.static.ArePlayersAllied(player, SPlayer(Player.FrobTarget)))
		{
			// refill teammates ammo
			affected = SPlayer(Player.FrobTarget);
		}
		else affected = player;

		if (affected != none)
		{
			bWasAmmoLow = affected.ReplAmmoLow;
			affected.RestockAmmo();
			if (affected != player) player.PlayLogSound(Sound'WeaponPickup');

			if (bWasAmmoLow && player != affected)
			{
				if (SGame(Level.Game) != none)
					SGame(Level.Game).GestureReward(player, affected, 'Ammo', 0.5);
			}
		}

		UseOnce();
	}
Begin:
}

function bool UpdateInfo(Object winObject)
{
}

defaultproperties
{
    msgAmmoRestock="Ammo restocked."
    bCanDrop=False
    maxCopies=5
    bCanHaveMultipleCopies=True
    bActivatable=True
    ItemName="Ammo Box"
    PlayerViewOffset=(X=20.00,Y=0.00,Z=-12.00),
    PlayerViewMesh=LodMesh'DeusExItems.DXMPAmmobox'
    PlayerViewScale=0.30
    PickupViewMesh=LodMesh'DeusExItems.DXMPAmmobox'
    PickupViewScale=0.30
    ThirdPersonMesh=LodMesh'DeusExItems.DXMPAmmobox'
    ThirdPersonScale=0.30
    LandSound=Sound'DeusExSounds.Generic.PlasticHit2'
    Icon=Texture'ui_ammobox'
    largeIcon=Texture'ui_ammobox'
    largeIconWidth=44
    largeIconHeight=43
    Description="Restocks all carried weapons."
    beltDescription="AMMOBOX"
    Mesh=LodMesh'DeusExItems.DXMPAmmobox'
    bOnlyOwnerSee=True
    CollisionRadius=5.00
    CollisionHeight=5.00
    Mass=5.00
    Buoyancy=4.00
}
