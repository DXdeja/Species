class SDetailsScreen_Nurse extends SDetailsScreen_Human;

defaultproperties
{
    Weapons(0)=(image=Texture'DeusExUI.Icons.BeltIconPistol',Text="Pistol",bTextOnly=False),
    Weapons(1)=(image=Texture'DeusExUI.Icons.BeltIconCrossbow',Text="Mini Crossbow",bTextOnly=False),
    LevelUpgrades1(0)=(image=Texture'DeusExUI.UserInterface.AugIconHealing_Small',Text="Aug: Regeneration",bTextOnly=False),
    LevelUpgrades1(1)=(image=Texture'DeusExUI.UserInterface.SkillIconMedicine',Text="Skill: Medicine",bTextOnly=False),
    LevelUpgrades1(2)=(image=Texture'DeusExUI.UserInterface.SkillIconWeaponPistol',Text="Skill: Pistols",bTextOnly=False),
    LevelUpgrades1(3)=(image=None,Text="|nDecreased Medkit generating time.",bTextOnly=True),
    LevelUpgrades2(0)=(image=Texture'DeusExUI.UserInterface.AugIconAquaLung_Small',Text="Aug:|nAqualung",bTextOnly=False),
    LevelUpgrades2(1)=(image=Texture'DeusExUI.UserInterface.SkillIconMedicine',Text="Skill: Medicine",bTextOnly=False),
    LevelUpgrades2(2)=(image=Texture'DeusExUI.UserInterface.SkillIconEnviro',Text="Skill: Enviro",bTextOnly=False),
    LevelUpgrades2(3)=(image=None,Text="|nDecreased Medkit generating time.",bTextOnly=True),
    LevelUpgrades3(0)=(image=Texture'DeusExUI.UserInterface.AugIconShield_Small',Text="Aug: Shield",bTextOnly=False),
    LevelUpgrades3(1)=(image=Texture'DeusExUI.UserInterface.SkillIconWeaponPistol',Text="Skill: Pistols",bTextOnly=False),
    LevelUpgrades3(2)=(image=Texture'DeusExUI.UserInterface.SkillIconEnviro',Text="Skill: Enviro",bTextOnly=False),
    LevelUpgrades3(3)=(image=None,Text="|nDecreased Medkit generating time.",bTextOnly=True),
    LevelUpgrades4(0)=(image=Texture'DeusExUI.UserInterface.AugIconTarget_Small',Text="Aug:|nTargeting",bTextOnly=False),
    LevelUpgrades4(1)=(image=None,Text="|nDecreased Medkit generating time.",bTextOnly=True),
    AutoGenerates=(image=Texture'DeusExUI.Icons.BeltIconMedKit',Text="Medkit",bTextOnly=False),
    Title="Nurse"
}
