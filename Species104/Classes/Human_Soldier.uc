class Human_Soldier extends PT_SHuman;

static function bool IsFrobbable(CBPPlayer owner, Actor A)
{
	if (A.IsA('CBPCarcass')) return false;
	return super(PT_Human).IsFrobbable(owner, A);
}

static function Event_ExtHUDDraw(CBPPlayer owner, GC gc, Window w);

static function GiveInitialInventory(CBPPlayer owner)
{
	owner.GiveInventory(class'SWeaponAssaultGun');
	owner.GiveInventory(class'SWeaponRifle');
	owner.GiveInventory(class'SWeaponCombatKnife');
}

static function Level1Upgrades(CBPPlayer owner)
{
	owner.GrantAugs(1);
	UpgradeSkillGroup(owner, 2); // rifles
	UpgradeSkillGroup(owner, 3); // low tech
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
	UpgradeSkillGroup(owner, 5); // enviro
	UpgradeSkillGroup(owner, 2); // rifles
}

static function Level4Upgrades(CBPPlayer owner)
{
	owner.GrantAugs(1);
}

defaultproperties
{
    AugPrefs(0)=Class'CBPAugSpeed'
    AugPrefs(1)=Class'CBPAugBallistic'
    AugPrefs(2)=Class'CBPAugEnviro'
    AugPrefs(3)=Class'CBPAugShield'
    BeltInventoryClass=Class'SInventory_Soldier'
    DrawScale=0.93
    Mesh=LodMesh'MPCharacters.mp_jumpsuit'
    MultiSkins(0)=Texture'DeusExCharacters.Skins.SoldierTex0'
    MultiSkins(1)=Texture'DeusExCharacters.Skins.SoldierTex2'
    MultiSkins(2)=Texture'DeusExCharacters.Skins.SoldierTex1'
    MultiSkins(3)=Texture'DeusExCharacters.Skins.SoldierTex0'
    MultiSkins(4)=Texture'DeusExItems.Skins.PinkMaskTex'
    MultiSkins(5)=Texture'DeusExItems.Skins.PinkMaskTex'
    MultiSkins(6)=Texture'DeusExCharacters.Skins.SoldierTex3'
    MultiSkins(7)=Texture'DeusExItems.Skins.PinkMaskTex'
    CarcassType=Class'Carcass_Soldier'
    Texture=Texture'DeusExItems.Skins.PinkMaskTex'
    PrePivot=(X=0.00,Y=0.00,Z=-5.00),
}
