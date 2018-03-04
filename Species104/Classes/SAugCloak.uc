class SAugCloak extends CBPAugCloak;

static function ActivateAction(DeusExPlayer dxp)
{
	super.ActivateAction(dxp);
	SPlayer(dxp).bCloakOn = true;
}

static function DeactivateAction(DeusExPlayer dxp)
{
	super.DeactivateAction(dxp);
	SPlayer(dxp).bCloakOn = false;
}

defaultproperties
{
}
