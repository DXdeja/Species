class Human_Flamer extends PT_SHuman;

static function bool IsFrobbable(CBPPlayer owner, Actor A)
{
	if (A.IsA('CBPCarcass')) return false;
	return super(PT_Human).IsFrobbable(owner, A);
}

static function Event_ExtHUDDraw(CBPPlayer owner, GC gc, Window w);

static function GiveInitialInventory(CBPPlayer owner)
{
	owner.GiveInventory(class'SWeaponFlamethrower');
	owner.GiveInventory(class'SWeaponGEPGun');
}

static function Level1Upgrades(CBPPlayer owner)
{
	owner.GrantAugs(1);
	UpgradeSkillGroup(owner, 0); // heavy
	UpgradeSkillGroup(owner, 5); // enviro
}

static function Level2Upgrades(CBPPlayer owner)
{
	owner.GrantAugs(1);
	UpgradeSkillGroup(owner, 4); // demolition
	UpgradeSkillGroup(owner, 5); // enviro
}

static function Level3Upgrades(CBPPlayer owner)
{
	owner.GrantAugs(1);
	UpgradeSkillGroup(owner, 4); // demolition
	UpgradeSkillGroup(owner, 0); // heavy
}

static function Level4Upgrades(CBPPlayer owner)
{
	owner.GrantAugs(1);
}

defaultproperties
{
    AugPrefs(0)=Class'CBPAugTarget'
    AugPrefs(1)=Class'CBPAugEMP'
    AugPrefs(2)=Class'CBPAugMuscle'
    AugPrefs(3)=Class'CBPAugEnviro'
    AutoGenerateItemClass=Class'SWeaponNapalmGrenade'
    ItemGenTime=50.00
    ItemGenTimeRedPerLevel=6.00
    BeltInventoryClass=Class'SInventory_Flamer'
    DrawScale=0.96
    Mesh=LodMesh'DeusExCharacters.GM_Trench'
    MultiSkins(0)=Texture'DeusExCharacters.Skins.GordonQuickTex0'
    MultiSkins(1)=Texture'DeusExCharacters.Skins.GordonQuickTex2'
    MultiSkins(2)=Texture'DeusExCharacters.Skins.GordonQuickTex3'
    MultiSkins(3)=Texture'DeusExCharacters.Skins.GordonQuickTex0'
    MultiSkins(4)=Texture'DeusExCharacters.Skins.GordonQuickTex1'
    MultiSkins(5)=Texture'DeusExCharacters.Skins.GordonQuickTex2'
    MultiSkins(6)=Texture'DeusExItems.Skins.PinkMaskTex'
    MultiSkins(7)=Texture'DeusExItems.Skins.PinkMaskTex'
    CarcassType=Class'Carcass_Flamer'
    PrePivot=(X=0.00,Y=0.00,Z=-5.00),
}
