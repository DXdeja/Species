class PT_Robot extends PawnType
	abstract;

var Texture PrimGestureTexture;
var Texture SecGestureTexture;
var string PrimGesturePicText;
var string SecGesturePicText;
var string PrimGestureText;
var string SecGestureText;

var Texture HealthTexture;
var Texture HealthFullTexture;

var float NoHealTime;
var float HealthCheckInterval;
var int AutoHealPerLevel[5];

var class<SWeaponRobotGun> GunType;

static function Event_LevelUpReward(CBPPlayer owner)
{
	if (SPlayer(owner).XPLevel == 1) Level1Upgrades(owner);
	else if (SPlayer(owner).XPLevel == 2) Level2Upgrades(owner);
	else if (SPlayer(owner).XPLevel == 3) Level3Upgrades(owner);
	else if (SPlayer(owner).XPLevel == 4) Level4Upgrades(owner);
}

static function UpgradeSkillGroup(CBPPlayer owner, byte group)
{
	if (CBPSkillManager(owner.SkillSystem) != none)
		CBPSkillManager(owner.SkillSystem).ForceIncLevel(group);
}

static function Event_ServerTick(CBPPlayer owner, float DeltaTime)
{
	local SPlayer splayer;

	super.Event_ServerTick(owner, DeltaTime);

	splayer = SPlayer(owner);
	if (splayer == none) return;

	if (!splayer.bIsAlive) return;

	if ((splayer.LastTakenDamageTime + default.NoHealTime) > splayer.Level.TimeSeconds) return;

	splayer.FieldCheckTime += DeltaTime;
	if (splayer.FieldCheckTime >= default.HealthCheckInterval)
	{
		splayer.FieldCheckTime = 0.0;
		if (splayer.HealthTorso < default.HealthTorso)
		{
			splayer.HealPlayer(default.AutoHealPerLevel[splayer.XPLevel], false);
			splayer.ClientFlash(0.5, vect(0, 0, 500));
		}
	}
}

static function DrawAmmoInfo(SPlayer owner, Canvas canvas)
{
	local int X, Y;
	local DeusExWeapon dxw;
	local int ammoRemaining;
	local int ammoInClip;
	local int clipsRemaining;

	canvas.Font = class'CBPBeltInventory'.default.InvFont;

	// draw ammo info
	dxw = DeusExWeapon(owner.Inventory);
	if (dxw != none)
	{
		X = 16;
		Y = canvas.SizeY - 16 - 41;

		// draw background
		class'PT_Shared'.static.DrawOutlinedRect(canvas, X, Y, 80, 41,
			class'CBPBeltInventory'.default.BackgroundColor, class'CBPBeltInventory'.default.LineColor);

		X += 2;
		Y += 2;

		// draw icon background
		class'PT_Shared'.static.DrawOutlinedRect(canvas, X, Y, 42, 37,
			class'CBPBeltInventory'.default.BackgrounSelectedColor, class'CBPBeltInventory'.default.LineSelectedColor);

		// draw icon
		canvas.SetPos(X + 1, Y + 1);
		canvas.DrawColor = class'CBPBeltInventory'.default.ItemColor;
		canvas.DrawTile(dxw.Icon, 40, 35, 10, 15, 40, 35);

		// draw texts
		Y -= 2;
		X += 46;

		canvas.SetPos(X + 2, Y);
		canvas.DrawText(class'CBPBeltInventory'.default.AmmoLabel);
		Y += 10;
		class'PT_Shared'.static.DrawOutlinedRect(canvas, X, Y, 30, 10, class'CBPBeltInventory'.default.BackgrounSelectedColor,
			class'CBPBeltInventory'.default.LineSelectedColor);
		Y += 11;
		class'PT_Shared'.static.DrawOutlinedRect(canvas, X, Y, 30, 10,
			class'CBPBeltInventory'.default.BackgrounSelectedColor, class'CBPBeltInventory'.default.LineSelectedColor);
		Y += 10;
		canvas.SetPos(X + 2, Y);
		canvas.DrawColor = class'CBPBeltInventory'.default.ItemColor;
		canvas.DrawText(class'CBPBeltInventory'.default.ClipsLabel);

		X += 4;
		Y -= 21;

		// draw text
		if (dxw.AmmoType != None)
			ammoRemaining = dxw.AmmoType.AmmoAmount;
		else
			ammoRemaining = 0;

		if ( ammoRemaining < dxw.LowAmmoWaterMark )
			canvas.DrawColor = class'CBPBeltInventory'.default.colAmmoLowText;
		else
			canvas.DrawColor = class'CBPBeltInventory'.default.colAmmoText;

		// Ammo count drawn differently depending on user's setting
		if (dxw.ReloadCount > 1 )
		{
			// how much ammo is left in the current clip?
			ammoInClip = dxw.AmmoLeftInClip();
			clipsRemaining = dxw.NumClips();

			canvas.SetPos(X, Y);
			if (dxw.IsInState('Reload'))
			{
				canvas.DrawText(class'CBPBeltInventory'.default.msgReloading);
			}
				//gc.DrawText(infoX, 26, 20, 9, msgReloading);
			else
			{
				canvas.DrawText(ammoInClip);
			}
				//gc.DrawText(infoX, 26, 20, 9, ammoInClip);

			// if there are no clips (or a partial clip) remaining, color me red
			if (( clipsRemaining == 0 ) || (( clipsRemaining == 1 ) && ( ammoRemaining < 2 * dxw.ReloadCount )))
				canvas.DrawColor = class'CBPBeltInventory'.default.colAmmoLowText;
			else
				canvas.DrawColor = class'CBPBeltInventory'.default.colAmmoText;

			canvas.SetPos(X, Y + 11);
			if (dxw.IsInState('Reload'))
				canvas.DrawText(class'CBPBeltInventory'.default.msgReloading);
				//gc.DrawText(infoX, 38, 20, 9, msgReloading);
			else
				canvas.DrawText(clipsRemaining);
				//gc.DrawText(infoX, 38, 20, 9, clipsRemaining);
		}
		else
		{
			canvas.SetPos(X, Y + 11);
			canvas.DrawText(class'CBPBeltInventory'.default.NotAvailable);
			//gc.DrawText(infoX, 38, 20, 9, NotAvailable);

			if (dxw.ReloadCount == 0)
			{
				canvas.SetPos(X, Y);
				canvas.DrawText(class'CBPBeltInventory'.default.NotAvailable);
				//gc.DrawText(infoX, 26, 20, 9, NotAvailable);
			}
			else
			{
				canvas.SetPos(X, Y);
				if (dxw.IsInState('Reload'))
					canvas.DrawText(class'CBPBeltInventory'.default.msgReloading);
					//gc.DrawText(infoX, 26, 20, 9, msgReloading);
				else
					canvas.DrawText(ammoRemaining);
					//gc.DrawText(infoX, 26, 20, 9, ammoRemaining);
			}
		}

	}
}

static function HUDDrawPrimGesture(SPlayer owner, Canvas canvas, int Xoff)
{
	class'PT_Shared'.static.HUDDrawGesturePic(canvas, Xoff, default.PrimGestureTexture, default.PrimGesturePicText);
	class'PT_Shared'.static.HUDDrawGestureText(canvas, Xoff, default.PrimGestureText);
}

static function HUDDrawSecGesture(SPlayer owner, Canvas canvas, int Xoff)
{
	class'PT_Shared'.static.HUDDrawGesturePic(canvas, Xoff, default.SecGestureTexture, default.SecGesturePicText);
	class'PT_Shared'.static.HUDDrawGestureText(canvas, Xoff, default.SecGestureText);
}

static function Event_HUDDraw(CBPPlayer owner, Canvas canvas)
{
	local int X;
	local SPlayer splayer;

	class'PT_Shared'.static.HUDDraw(SPlayer(owner), canvas);

	splayer = SPlayer(owner);

	DrawAmmoInfo(splayer, canvas);

	// draw special icons
	X = canvas.SizeX / 2 - (66 + 32);

	// if can attack
	HUDDrawPrimGesture(splayer, canvas, X);
	X += 66 + 64;

	// if can shoot / eat
	HUDDrawSecGesture(splayer, canvas, X);

	// draw health
	class'PT_Shared'.static.HUDDrawHealth(splayer, canvas, default.HealthTexture, default.HealthFullTexture, float(default.HealthTorso));
}

static function PlayAnimation_InAir(Actor owner)
{
	if (PlayingAnimGroup_Attack(owner)) return;
	owner.PlayAnim('Still', 3.0, 0.1);
}

static function PlayAnimation_Landed(Actor owner)
{
	if (CBPPlayer(owner) != none) CBPPlayer(owner).PlayFootStep();
	owner.PlayAnim('Still', 3.0, 0.1);
}

static function PlayAnimation_Waiting(Actor owner)
{
	owner.LoopAnim('BreatheLight');
}

static function PlayAnimation_TweenToWaiting(Actor owner, float tweentime)
{
	owner.TweenAnim('BreatheLight', tweentime);
}

static function PlayAnimation_DeathWater(Actor owner)
{
	owner.PlayAnim('Still',,0.1);
}

static function PlayAnimation_DeathFront(Actor owner)
{
	owner.PlayAnim('Still',,0.1);
}

static function PlayAnimation_DeathBack(Actor owner)
{
	owner.PlayAnim('Still',,0.1);
}

static function PlaySound_PainSmall(Actor owner, optional float vol)
{
	owner.PlaySound(Sound'DeusExSounds.Generic.Spark1', SLOT_Pain, vol,,, RandomPitch());
}

static function PlaySound_PainMedium(Actor owner, optional float vol)
{
	owner.PlaySound(Sound'DeusExSounds.Generic.Spark1', SLOT_Pain, vol,,, RandomPitch());
}

static function PlaySound_PainLarge(Actor owner, optional float vol)
{
	owner.PlaySound(Sound'DeusExSounds.Generic.Spark1', SLOT_Pain, vol,,, RandomPitch());
}

static function PlaySound_Death(Actor owner)
{
	owner.PlaySound(Sound'DeusExSounds.Generic.Spark1', SLOT_Pain,,,, RandomPitch());
}

static function PlaySound_WaterDeath(Actor owner)
{
	owner.PlaySound(Sound'DeusExSounds.Generic.Spark1', SLOT_Pain,,,, RandomPitch() * 0.75);
}

static function Event_TakeDamage(Pawn owner, int Damage, Pawn instigatedBy, Vector HitLocation, Vector Momentum, name DamageType)
{
	SPlayer(owner).RobotTakeDamage(Damage, instigatedBy, HitLocation, Momentum, DamageType);
}

static function Exec_Fire(CBPPlayer owner, optional float F)
{
	owner.RegularFire(F);
}

static function Exec_ParseRightClick(CBPPlayer owner)
{
	SPlayer(owner).RobotRightClick();
}

static function int Event_HealPlayer(CBPPlayer owner, int baseHealPoints, optional bool bUseMedicineSkill)
{
	return SPlayer(owner).AnimalHeal(baseHealPoints, bUseMedicineSkill);
}

static function GiveInitialInventory(CBPPlayer owner)
{
	local SWeaponRobotGun weap;

	weap = owner.Spawn(default.GunType, owner);
	if (weap != None)
	{
		weap.Instigator = owner;
		weap.BecomeItem();
		weap.GiveAmmo(owner);
		owner.AddInventory(weap);
		weap.BringUp();
		weap.WeaponSet(owner);
	}
}

static function Event_Died(CBPPlayer owner, vector HitLocation)
{
	owner.Weapon.Destroy();
	owner.Weapon = none;
}

static function Level1Upgrades(CBPPlayer owner)
{
	UpgradeSkillGroup(owner, 2); // rifles
}

static function Level2Upgrades(CBPPlayer owner)
{
}

static function Level3Upgrades(CBPPlayer owner)
{
	UpgradeSkillGroup(owner, 2); // rifles
}

static function Level4Upgrades(CBPPlayer owner)
{
}

static function bool IsFrobbable(CBPPlayer owner, Actor A)
{
	if (!A.bHidden)
		if (A.IsA('Mover') || (A.IsA('CBPCarcass') && !CBPCarcass(A).bAnimalCarcass))
			return True;

	return False;
}

defaultproperties
{
    PrimGesturePicText="ATTACK"
    SecGesturePicText="RESTOCK"
    PrimGestureText="<Left Mouse Button>"
    SecGestureText="<Right Mouse Button>"
    HealthTexture=Texture'ui_karkian_health'
    HealthFullTexture=Texture'ui_karkian_health_full'
    NoHealTime=9.00
    HealthCheckInterval=1.00
    AutoHealPerLevel(0)=3
    AutoHealPerLevel(1)=4
    AutoHealPerLevel(2)=5
    AutoHealPerLevel(3)=6
    AutoHealPerLevel(4)=7
    AccelRate=2048.00
    JumpZ=100.00
    AirControl=0.00
    bCanJump=True
    BeltInventoryClass=None
    AugManagerClass=None
    bOwnHealthBar=True
}
