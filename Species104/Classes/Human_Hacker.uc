class Human_Hacker extends PT_SHuman;

static function bool IsFrobbable(CBPPlayer owner, Actor A)
{
	if (A.IsA('CBPCarcass')) return false;
	return super(PT_Human).IsFrobbable(owner, A);
}

static function Event_ExtHUDDraw(CBPPlayer owner, GC gc, Window w);

static function GiveInitialInventory(CBPPlayer owner)
{
	owner.GiveInventory(class'SWeaponSawedOffShotgun');
	//owner.GiveInventory(class'SWeaponEMP');
	//owner.GiveInventory(class'SItemTurret');
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
	UpgradeSkillGroup(owner, 4); // demolition
	UpgradeSkillGroup(owner, 5); // enviro
}

static function Level3Upgrades(CBPPlayer owner)
{
	owner.GrantAugs(1);
	UpgradeSkillGroup(owner, 4); // demolition
	UpgradeSkillGroup(owner, 2); // rifles
}

static function Level4Upgrades(CBPPlayer owner)
{
	owner.GrantAugs(1);
}

defaultproperties
{
    AugPrefs(0)=Class'SAugRadarTrans'
    AugPrefs(1)=Class'CBPAugDrone'
    AugPrefs(2)=Class'CBPAugBallistic'
    AugPrefs(3)=Class'CBPAugPower'
    AutoGenerateItemClass(0)=Class'SItemTurret'
    AutoGenerateItemClass(1)=Class'SWeaponEMP'
    ItemGenTime(0)=60.00
    ItemGenTime(1)=60.00
    ItemGenTimeRedPerLevel(0)=0.00
    ItemGenTimeRedPerLevel(1)=7.00
    KillReward=0.50
    BeltInventoryClass=Class'SInventory_Hacker'
    DrawScale=0.93
    Mesh=LodMesh'MPCharacters.mp_jumpsuit'
    MultiSkins(0)=Texture'DeusExCharacters.Skins.SamCarterTex0'
    MultiSkins(1)=Texture'DeusExCharacters.Skins.SamCarterTex2'
    MultiSkins(2)=Texture'DeusExCharacters.Skins.SamCarterTex1'
    MultiSkins(3)=Texture'DeusExCharacters.Skins.SamCarterTex0'
    MultiSkins(4)=Texture'DeusExItems.Skins.PinkMaskTex'
    MultiSkins(5)=Texture'DeusExItems.Skins.PinkMaskTex'
    MultiSkins(6)=Texture'DeusExItems.Skins.PinkMaskTex'
    MultiSkins(7)=Texture'DeusExItems.Skins.PinkMaskTex'
    CarcassType=Class'Carcass_Hacker'
    Texture=Texture'DeusExItems.Skins.PinkMaskTex'
    PrePivot=(X=0.00,Y=0.00,Z=-5.00),
}
