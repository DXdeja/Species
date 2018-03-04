class Human_Engineer extends PT_SHuman;

static function string GetPlayersInfo(SPlayer other, out color txtcol, Window w)
{
	local string str;

	str = "Energy: " $ other.ReplEnergy $ "%";
	if (Other.ReplAmmoLow)
	{
		str = str $ " LOW AMMO!";
		txtcol.R = 255;
		txtcol.G = 0;
		txtcol.B = 0;
	}
	else if (other.ReplEnergy == 0)
	{
		txtcol.R = 255;
		txtcol.G = 0;
		txtcol.B = 0;
	}
	else txtcol = w.GetColorScaled(float(other.ReplEnergy) / 100.0);
	return str;
}

static function GiveInitialInventory(CBPPlayer owner)
{
	owner.GiveInventory(class'SWeaponAssaultShotgun');
	owner.GiveInventory(class'SWeaponNanoSword');
	owner.GiveInventory(class'SBioelectricCell');
	owner.GiveInventory(class'SAmmoBox');
}

static function Level1Upgrades(CBPPlayer owner)
{
	owner.GrantAugs(1);
	UpgradeSkillGroup(owner, 2); // rifles
	UpgradeSkillGroup(owner, 5); // enviro
}

static function Level2Upgrades(CBPPlayer owner)
{
	owner.GrantAugs(1);
	UpgradeSkillGroup(owner, 3); // low tech
	UpgradeSkillGroup(owner, 5); // enviro
}

static function Level3Upgrades(CBPPlayer owner)
{
	owner.GrantAugs(1);
	UpgradeSkillGroup(owner, 3); // low tech
	UpgradeSkillGroup(owner, 2); // rifles
}

static function Level4Upgrades(CBPPlayer owner)
{
	owner.GrantAugs(1);
}

static function Exec_ParseLeftClick(CBPPlayer owner)
{
	if (!SPlayer(owner).PropelDecoration())
		owner.RegularParseLeftClick();
}

defaultproperties
{
    AugPrefs(0)=Class'CBPAugMuscle'
    AugPrefs(1)=Class'CBPAugCombat'
    AugPrefs(2)=Class'CBPAugPower'
    AugPrefs(3)=Class'SAugRadarTrans'
    AutoGenerateItemClass(0)=Class'SAmmoBox'
    AutoGenerateItemClass(1)=Class'SBioelectricCell'
    ItemGenTime(1)=30.00
    ItemGenTimeRedPerLevel(1)=4.00
    KillReward=0.50
    BeltInventoryClass=Class'SInventory_Engineer'
    DrawScale=0.93
    Mesh=LodMesh'MPCharacters.mp_jumpsuit'
    MultiSkins(0)=Texture'DeusExCharacters.Skins.SkinTex4'
    MultiSkins(1)=Texture'DeusExCharacters.Skins.MechanicTex2'
    MultiSkins(2)=Texture'DeusExCharacters.Skins.MechanicTex1'
    MultiSkins(3)=Texture'DeusExCharacters.Skins.SkinTex4'
    MultiSkins(4)=Texture'DeusExItems.Skins.PinkMaskTex'
    MultiSkins(5)=Texture'DeusExItems.Skins.PinkMaskTex'
    MultiSkins(6)=Texture'DeusExCharacters.Skins.MechanicTex3'
    MultiSkins(7)=Texture'DeusExItems.Skins.PinkMaskTex'
    CarcassType=Class'Carcass_Engineer'
    PrePivot=(X=0.00,Y=0.00,Z=-5.00),
}
