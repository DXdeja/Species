class Human_Nurse extends PT_SHuman;

// todo: fix anims, not all are correct!

static function string GetPlayersInfo(SPlayer other, out color txtcol, Window w)
{
	if (other.ReplHealth == 0)
	{
		txtcol.R = 255;
		txtcol.B = 0;
		txtcol.G = 0;
	}
	else txtcol = w.GetColorScaled(float(other.ReplHealth) / 100.0);
	return "Health: " $ other.ReplHealth $ "%";
}

static function GiveInitialInventory(CBPPlayer owner)
{
	owner.GiveInventory(class'SWeaponPistol');
	owner.GiveInventory(class'SWeaponMiniCrossbow');
	owner.GiveInventory(class'SMedkit');
}

static function Level1Upgrades(CBPPlayer owner)
{
	owner.GrantAugs(1);
	UpgradeSkillGroup(owner, 8); // medicine
	UpgradeSkillGroup(owner, 1); // pistols
}

static function Level2Upgrades(CBPPlayer owner)
{
	owner.GrantAugs(1);
	UpgradeSkillGroup(owner, 8); // medicine
	UpgradeSkillGroup(owner, 5); // enviro
}

static function Level3Upgrades(CBPPlayer owner)
{
	owner.GrantAugs(1);
	UpgradeSkillGroup(owner, 5); // enviro
	UpgradeSkillGroup(owner, 1); // pistols
}

static function Level4Upgrades(CBPPlayer owner)
{
	owner.GrantAugs(1);
}

static function PlayAnimation_Crouch(Actor owner)
{
	if (owner.AnimSequence != 'Crouch' && owner.AnimSequence != 'CrouchShoot')
	{
		if (CBPPlayer(owner) != none && CBPPlayer(owner).IsFiring())
		{
			owner.PlayAnim('CrouchShoot', , 0.1);
		}
		else
		{
			owner.PlayAnim('Crouch', , 0.1);
		}
	}
}

static function PlayAnimation_TweenToWalking(Actor owner, float tweentime)
{
	if (CBPPlayer(owner) != none && (CBPPlayer(owner).bForceDuck || CBPPlayer(owner).bCrouchOn))
	{
		owner.PlayAnim('Crouch', , tweentime);
	}
	else
	{
		if (CBPPlayer(owner) != none && CBPPlayer(owner).HasTwoHandedWeapon())
		{
			owner.TweenAnim('Walk2H', tweentime);
		}
		else
		{
			owner.TweenAnim('Walk', tweentime);
		}
	}
}

static function PlayAnimation_Walking(Actor owner, float animrate)
{
	local float newhumanAnimRate;

	// UnPhysic.cpp walk speed changed by proportion 0.7/0.3 (2.33), but that looks too goofy (fast as hell), so we'll try something a little slower
	newhumanAnimRate = animrate * 1.75;

	if (CBPPlayer(owner) != none && (CBPPlayer(owner).bForceDuck || CBPPlayer(owner).bCrouchOn))
	{
		//owner.LoopAnim('Crouch', newhumanAnimRate);
	}
	else
	{
		if (CBPPlayer(owner) != none && CBPPlayer(owner).HasTwoHandedWeapon())
		{
			owner.LoopAnim('Walk2H', newhumanAnimRate);
		}
		else
		{
			owner.LoopAnim('Walk', newhumanAnimRate);
		}
	}
}

static function PlayAnimation_TweenToWaiting(Actor owner, float tweentime)
{
	if (owner.IsInState('PlayerSwimming') || (owner.Physics == PHYS_Swimming))
	{
		if (CBPPlayer(owner) != none && CBPPlayer(owner).IsFiring())
			owner.LoopAnim('TreadShoot');
		else
			owner.LoopAnim('Tread');
	}
	else if (CBPPlayer(owner) != none && CBPPlayer(owner).bForceDuck)
	{
		//owner.TweenAnim('Crouch', tweentime);
		if (owner.AnimSequence != 'Crouch')
			owner.PlayAnim('Crouch', , tweentime);
	}
	else if ((owner.AnimSequence == 'Pickup' && owner.bAnimFinished) ||
		((owner.AnimSequence != 'Pickup') && CBPPlayer(owner) != none && !CBPPlayer(owner).IsFiring()))
	{
		if (CBPPlayer(owner) != none && CBPPlayer(owner).HasTwoHandedWeapon())
			owner.TweenAnim('BreatheLight2H', tweentime);
		else
			owner.TweenAnim('BreatheLight', tweentime);
	}
}

static function PlayAnimation_Waiting(Actor owner)
{
	if (owner.IsInState('PlayerSwimming') || owner.Physics == PHYS_Swimming)
	{
		if (CBPPlayer(owner) != none && CBPPlayer(owner).IsFiring())
			owner.LoopAnim('TreadShoot');
		else
			owner.LoopAnim('Tread');
	}
	else if (CBPPlayer(owner) != none && CBPPlayer(owner).bForceDuck)
	{
		owner.PlayAnim('Crouch', , 0.1);
		//owner.TweenAnim('Crouch', 0.1);
	}
	if (CBPPlayer(owner) != none && CBPPlayer(owner).IsFiring())
	{
		if (CBPPlayer(owner).HasTwoHandedWeapon())
			owner.LoopAnim('BreatheLight2H');
		else
			owner.LoopAnim('BreatheLight');
	}
}

static function PlayAnimation_Crawling(Actor owner)
{
	if (CBPPlayer(owner) != none && CBPPlayer(owner).IsFiring())
		owner.LoopAnim('CrouchShoot');
	else
	{
		if (owner.AnimSequence != 'Crouch')
		{
			owner.PlayAnim('Crouch', 10.0, 0.0);
		}
	}
}

static function PlayAnimation_Turning(Actor owner)
{
	if (CBPPlayer(owner) != none && (CBPPlayer(owner).bForceDuck || CBPPlayer(owner).bCrouchOn))
	{
		//owner.TweenAnim('Crouch', 0.1);
		if (owner.AnimSequence != 'Crouch')
		{
			owner.PlayAnim('Crouch', 10.0, 0.0);
		}
	}
	else
	{
		if (CBPPlayer(owner) != none && CBPPlayer(owner).HasTwoHandedWeapon())
			owner.TweenAnim('Walk2H', 0.1);
		else
			owner.TweenAnim('Walk', 0.1);
	}
}

static function PlaySound_Jump(Actor owner)
{
	owner.PlaySound(Sound'FemaleJump', SLOT_None, 1.5, true, 1200, 1.0 - 0.2*FRand());
}

static function PlaySound_Death(Actor owner)
{
	owner.PlaySound(sound'FemaleDeath', SLOT_Pain,,,, RandomPitch());
}

static function PlaySound_WaterDeath(Actor owner)
{
	owner.PlaySound(sound'FemaleWaterDeath', SLOT_Pain,,,, RandomPitch());
}

static function PlaySound_PainSmall(Actor owner, optional float vol)
{
	owner.PlaySound(sound'FemalePainSmall', SLOT_Pain, vol,,, RandomPitch());
}

static function PlaySound_PainMedium(Actor owner, optional float vol)
{
	owner.PlaySound(sound'FemalePainMedium', SLOT_Pain, vol,,, RandomPitch());
}

static function PlaySound_PainLarge(Actor owner, optional float vol)
{
	owner.PlaySound(sound'FemalePainLarge', SLOT_Pain, vol,,, RandomPitch());
}

static function PlaySound_PainEye(Actor owner, optional float vol)
{
	owner.PlaySound(sound'FemalePainSmall', SLOT_Pain, vol,,, RandomPitch());
}

static function PlaySound_Drown(Actor owner, optional float vol)
{
	owner.PlaySound(sound'FemaleDrown', SLOT_Pain, vol,,, RandomPitch());
}

defaultproperties
{
    AugPrefs(0)=Class'CBPAugHealing'
    AugPrefs(1)=Class'CBPAugAqualung'
    AugPrefs(2)=Class'CBPAugShield'
    AugPrefs(3)=Class'CBPAugTarget'
    AutoGenerateItemClass=Class'SMedkit'
    Mass=120.00
    Buoyancy=125.00
    CollisionHeight=43.00
    CrouchingCollisionHeight=27.00
    BaseEyeHeight=36.00
    KillReward=0.50
    BeltInventoryClass=Class'SInventory_Nurse'
    DrawScale=0.90
    Mesh=LodMesh'DeusExCharacters.GFM_SuitSkirt'
    MultiSkins(0)=Texture'DeusExCharacters.Skins.NurseTex0'
    MultiSkins(1)=Texture'DeusExCharacters.Skins.NurseTex0'
    MultiSkins(2)=Texture'DeusExCharacters.Skins.NurseTex0'
    MultiSkins(3)=Texture'DeusExCharacters.Skins.LegsTex1'
    MultiSkins(4)=Texture'DeusExCharacters.Skins.NurseTex1'
    MultiSkins(5)=Texture'DeusExCharacters.Skins.NurseTex1'
    MultiSkins(6)=Texture'DeusExItems.Skins.PinkMaskTex'
    MultiSkins(7)=Texture'DeusExItems.Skins.PinkMaskTex'
    CarcassType=Class'Carcass_Nurse'
    PrePivot=(X=0.00,Y=0.00,Z=-5.00),
}
