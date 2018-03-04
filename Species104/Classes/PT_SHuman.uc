class PT_SHuman extends PT_Human
	abstract;

var class<CBPAugmentation> AugPrefs[9];
var class<Inventory> AutoGenerateItemClass[2];
var float ItemGenTime[2];
var float ItemGenTimeRedPerLevel[2];

var Color BackgroundColor;
var Color BackgroundSelectedColor;
var Color LineColor;
var Color LineSelectedColor;
var Color TextColor;
var Color DarkCol;
var Font TextFont;
var Font TextFontBig;

static function bool IsFrobbable(CBPPlayer owner, Actor A)
{
	local SPlayer splayer;

	if (A.IsA('CBPCarcass')) return false;

	if (super.IsFrobbable(owner, A)) return true;

	splayer = SPlayer(A);
	if (splayer != none && 
		splayer.bIsAlive && 
		class'CBPGame'.static.ArePlayersAllied(owner, splayer))
		return true;

	return false;
}

static function Event_GrantAugs(CBPPlayer owner, int NumAugs)
{
   local int PriorityIndex;
   local int AugsLeft;
   local int i;
   local CBPAugmentationManager mmaugmanager;

   mmaugmanager = CBPAugmentationManager(owner.AugmentationSystem);
   if (mmaugmanager == none) return;

   AugsLeft = NumAugs;

   for (PriorityIndex = 0; PriorityIndex < ArrayCount(default.AugPrefs); PriorityIndex++)
   {
		if (AugsLeft <= 0)
		{
			return;
		}
		if (default.AugPrefs[PriorityIndex] == none)
		{
			return;
		}

		for (i = 0; i < 18; i++)
		{
			if (mmaugmanager.mpAugs[i] == default.AugPrefs[PriorityIndex])
			{
				if (mmaugmanager.mpStatus[i] == 0)
				{
					mmaugmanager.NewGivePlayerAugmentation(mmaugmanager.mpAugs[i]);
					AugsLeft -= 1;
				}
				break;
			}
		}
	}
}

static function Event_ServerTick(CBPPlayer owner, float DeltaTime)
{
	local SPlayer splayer;
	local CBPPickup pickup;
	local CBPGrenade gren;
	local int minh;
	local Inventory inv;
	local int i;

	super.Event_ServerTick(owner, DeltaTime);

	splayer = SPlayer(owner);
	if (splayer == none) return;

	// check if low ammo
	if (!splayer.ReplAmmoLow)
	{
		inv = splayer.Inventory;
		while (inv != none)
		{
			if (CBPWeapon(inv) != none)
			{
				if (CBPWeapon(inv).AmmoType != none)
				{
					if (CBPWeapon(inv).AmmoType.AmmoAmount < CBPWeapon(inv).LowAmmoWaterMark)
					{
						splayer.ReplAmmoLow = true;
					}
				}
			}
			inv = inv.Inventory;
		}
	}

	// calc total health
	minh = Min(splayer.HealthHead, splayer.HealthTorso);
	minh = Min(minh, splayer.HealthLegLeft);
	splayer.ReplHealth = Clamp(minh, 0, 100);

	// calc energy
	splayer.ReplEnergy = Clamp(splayer.Energy, 0, 100);

	if (!owner.bIsAlive) return;

	for (i = 0; i < ArrayCount(default.AutoGenerateItemClass); i++)
	{
		if (default.AutoGenerateItemClass[i] == none) continue;

		pickup = CBPPickup(splayer.FindInventoryType(default.AutoGenerateItemClass[i]));
		if (pickup != none && pickup.NumCopies >= pickup.maxCopies) continue; // already full, do not generate
		gren = CBPGrenade(splayer.FindInventoryType(default.AutoGenerateItemClass[i]));
		if (gren != none && gren.AmmoType.AmmoAmount >= gren.AmmoType.MaxAmmo) continue; // already full

		splayer.AutoGenItemTime[i] += DeltaTime;
		if (splayer.AutoGenItemTime[i] >= (default.ItemGenTime[i] - (splayer.XPLevel * default.ItemGenTimeRedPerLevel[i])))
		{
			splayer.AutoGenItemTime[i] = 0.0;

			// give item
			splayer.GiveInventory(default.AutoGenerateItemClass[i]);
			splayer.PlayLogSound(Sound'LogGoalCompleted');
		}

		splayer.AutoGenItemTimePerc[i] = splayer.AutoGenItemTime[i] * 100.0 / (default.ItemGenTime[i] - (splayer.XPLevel * default.ItemGenTimeRedPerLevel[i]));
		splayer.AutoGenItemTimePerc[i] = Clamp(splayer.AutoGenItemTimePerc[i], 0, 99);
	}
}

static function Event_LevelUpReward(CBPPlayer owner)
{
	if (SPlayer(owner).XPLevel == 1) Level1Upgrades(owner);
	else if (SPlayer(owner).XPLevel == 2) Level2Upgrades(owner);
	else if (SPlayer(owner).XPLevel == 3) Level3Upgrades(owner);
	else if (SPlayer(owner).XPLevel == 4) Level4Upgrades(owner);
}

static function Level1Upgrades(CBPPlayer owner);
static function Level2Upgrades(CBPPlayer owner);
static function Level3Upgrades(CBPPlayer owner);
static function Level4Upgrades(CBPPlayer owner);

static function UpgradeSkillGroup(CBPPlayer owner, byte group)
{
	if (CBPSkillManager(owner.SkillSystem) != none)
		CBPSkillManager(owner.SkillSystem).ForceIncLevel(group);
}

static function Event_HUDDraw(CBPPlayer owner, Canvas canvas)
{
	local int X, Y, i, perct;
	local float fperc;
	local SPlayer splayer;
	local string str;

	class'PT_Shared'.static.HUDDraw(SPlayer(owner), canvas);

	splayer = SPlayer(owner);

	// draw generation of items
	for (i = 0; i < ArrayCount(default.AutoGenerateItemClass); i++)
	{
		if (default.AutoGenerateItemClass[i] != none)
		{
			X = canvas.SizeX - 16 - 44 - (1 + 44) * i;
			Y = canvas.SizeY - 16 - 44 - 16 - 44;

			class'PT_Shared'.static.DrawOutlinedRect(canvas, X, Y, 44, 44, default.BackgroundColor, default.LineSelectedColor);

			fperc = splayer.AutoGenItemTimePerc[i] / 100.0;
			fperc = FClamp(fperc, 0.0, 1.0);
			perct = fperc * 42;
			canvas.SetPos(X + 1, Y + 1 + (42 - perct));
			canvas.DrawColor = default.LineSelectedColor;
			canvas.DrawRect(Texture'Solid', 42, perct);

			canvas.DrawColor = default.TextColor;
			canvas.SetPos(X + 1, Y + 1);
			canvas.DrawTile(default.AutoGenerateItemClass[i].default.Icon, 42, 42, 0, 0, 42, 42);

			str = "";
			perct = int(fperc * 100.0);
			perct = Clamp(perct, 0, 99);
			if (perct < 10) str = "0";
			str = str $ perct $ "%";
			canvas.DrawColor = default.DarkCol;
			canvas.Font = default.TextFontBig;
			canvas.SetPos(X + 12, Y + 16);
			canvas.DrawText(str);
		}
	}
}

static function float FacingActor(Pawn A, Pawn B)
{
    local vector X,Y,Z, Dir;

    if (B == None || A == None) return -1.0;
    A.GetAxes(B.ViewRotation, X, Y, Z);
    Dir = A.Location - B.Location;
    X.Z = 0;
    Dir.Z = 0;
    return A.Normal(Dir) dot A.Normal(X);
}

static function Event_ExtHUDDraw(CBPPlayer owner, GC gc, Window win)
{
    local CBPPlayer target;
	local float x, y, w, h;
	local vector loc;
	local string str;
	local Color dcol;

	foreach owner.VisibleCollidingActors(class'CBPPlayer', target, 5000.0, owner.Location, false)
	{
	    if (class'CBPGame'.static.ArePlayersAllied(owner, target) && (FacingActor(target, owner) > 0.0))
        {
            if (!target.bIsAlive) continue;
            loc = target.Location;
            loc.Z -= target.CollisionHeight + 10.0;
            owner.rootWindow.ConvertVectorToCoordinates(loc, x, y);
			dcol = default.TextColor;
			str = GetPlayersInfo(SPlayer(target), dcol, win);
			gc.SetFont(default.TextFontBig);
			gc.SetTextColor(dcol);
			gc.GetTextExtent(0, w, h, str);
			gc.DrawText(x - w / 2, y, w, h, str);
        }
    }
}

static function string GetPlayersInfo(SPlayer other, out Color col, Window w)
{
	return "";
}

defaultproperties
{
    ItemGenTime=30.00
    ItemGenTimeRedPerLevel=4.00
    BackgroundColor=(R=40,G=40,B=40,A=0),
    BackgroundSelectedColor=(R=127,G=127,B=127,A=0),
    LineColor=(R=80,G=80,B=80,A=0),
    LineSelectedColor=(R=200,G=200,B=200,A=0),
    TextColor=(R=255,G=255,B=255,A=0),
    DarkCol=(R=0,G=255,B=0,A=0),
    textFont=Font'DeusExUI.FontMenuSmall_DS'
    TextFontBig=Font'DeusExUI.FontMenuTitle'
    UnderWaterTime=10.00
    AugManagerClass=Class'SAugmentationManager'
}
