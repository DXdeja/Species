class Human_SpecForce extends PT_SHuman;

static function bool IsFrobbable(CBPPlayer owner, Actor A)
{
	if (A.IsA('CBPCarcass')) return false;
	return super(PT_Human).IsFrobbable(owner, A);
}

static function Event_ExtHUDDraw(CBPPlayer owner, GC gc, Window w);

static function GiveInitialInventory(CBPPlayer owner)
{
	owner.GiveInventory(class'SWeaponStealthPistol');
	owner.GiveInventory(class'SWeaponRifle');
	//owner.GiveInventory(class'SWeaponLAM'); // no lam at start
}

static function Level1Upgrades(CBPPlayer owner)
{
	owner.GrantAugs(1);
	UpgradeSkillGroup(owner, 2); // rifles
	UpgradeSkillGroup(owner, 1); // pistols
}

static function Level2Upgrades(CBPPlayer owner)
{
	owner.GrantAugs(1);
	UpgradeSkillGroup(owner, 4); // demolition
	UpgradeSkillGroup(owner, 4); // demolition
}

static function Level3Upgrades(CBPPlayer owner)
{
	owner.GrantAugs(1);
	UpgradeSkillGroup(owner, 1); // pistols
	UpgradeSkillGroup(owner, 2); // rifles
}

static function Level4Upgrades(CBPPlayer owner)
{
	owner.GrantAugs(1);
}

defaultproperties
{
    AugPrefs(0)=Class'SAugCloak'
    AugPrefs(1)=Class'CBPAugStealth'
    AugPrefs(2)=Class'CBPAugShield'
    AutoGenerateItemClass=Class'SWeaponLAM'
    ItemGenTime=60.00
    ItemGenTimeRedPerLevel=7.00
    BeltInventoryClass=Class'SInventory_SpecForce'
    DrawScale=0.93
    Mesh=LodMesh'MPCharacters.mp_jumpsuit'
    MultiSkins(0)=Texture'DeusExCharacters.Skins.SkinTex1'
    MultiSkins(1)=Texture'DeusExCharacters.Skins.MJ12TroopTex1'
    MultiSkins(2)=Texture'DeusExCharacters.Skins.MJ12TroopTex2'
    MultiSkins(3)=Texture'DeusExCharacters.Skins.SkinTex1'
    MultiSkins(4)=Texture'DeusExItems.Skins.PinkMaskTex'
    MultiSkins(5)=Texture'DeusExCharacters.Skins.MJ12TroopTex3'
    MultiSkins(6)=Texture'DeusExCharacters.Skins.MJ12TroopTex4'
    MultiSkins(7)=Texture'DeusExItems.Skins.PinkMaskTex'
    CarcassType=Class'Carcass_SpecForce'
    PrePivot=(X=0.00,Y=0.00,Z=-5.00),
}
