class SAugRadarTrans extends CBPAugRadarTrans;

static function ActivateAction(DeusExPlayer dxp)
{
	//if ((dxp.inHand != None) && (dxp.inHand.IsA('DeusExWeapon')))
		//dxp.ServerConditionalNotifyMsg(dxp.MPMSG_NoCloakWeapon);
	dxp.PlaySound(Sound'CloakUp', SLOT_Interact, 0.85, ,768,1.0);
	SPlayer(dxp).bRadarTransOn = true;
}

static function DeactivateAction(DeusExPlayer dxp)
{
	dxp.PlaySound(Sound'CloakDown', SLOT_Interact, 0.85, ,768,1.0);
	SPlayer(dxp).bRadarTransOn = false;
}

defaultproperties
{
    LevelValues(3)=1.00
}
