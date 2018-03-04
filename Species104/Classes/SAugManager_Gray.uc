class SAugManager_Gray extends CBPAugmentationManager;

function AddDefaultAugmentations()
{
	mpStatus[10] = 1; // add vision
}

simulated function Float CalcEnergyUse(float deltaTime)
{
	return 0.0; // no energy drain
}

function bool ActivateAugByKey(int keyNum)
{
	if (keyNum == 0 || keyNum == 1)
		SPlayer(player).ServerAnimalSpecial(keyNum);
	else super.ActivateAugByKey(keyNum);
}

defaultproperties
{
}
