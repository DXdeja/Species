class SAugmentationDisplayWindow extends CBPAugmentationDisplayWindow;

function GetTargetReticleColorX(Actor target, out Color xcolor)
{
	if (SNPC(target) != none)
	{
		xcolor = colRed;
		return;
	}
	if (SObject(target) != none)
	{
		if (SObject(target).Team == player.PlayerReplicationInfo.Team)
			xcolor = colGreen;
		else xcolor = colRed;
		return;
	}
	super.GetTargetReticleColorX(target, xcolor);
}

function int GetVisionTargetStatus(Actor Target)
{
	if (SNPC(Target) != none)
	{
		return VISIONENEMY;
	}
	if (SObject(Target) != none)
	{
		if (SObject(Target).Team == player.PlayerReplicationInfo.Team)
			return VISIONALLY;
		else
			return VISIONENEMY;
	}
	return super.GetVisionTargetStatus(Target);
}

function bool IsHeatSource(Actor A)
{
	if (SObject(A) != none) return true;
	else return super.IsHeatSource(A);
}

defaultproperties
{
}
