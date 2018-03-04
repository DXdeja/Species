class PT_Shared extends Object
	abstract;

var Color BackgroundColor;
var Color BackgroundSelectedColor;
var Color LineColor;
var Color LineSelectedColor;
var Color TextColor;
var Font TextFont;
var Font GPicFont;
var Color GestureBackgroundColor;

var float GestureAmountForLevelUp[5];

static function GestureReward(SPlayer owner, SPlayer other, name gesture_type, float amount)
{
	owner.GestureLevel += amount;
	if (owner.GestureLevel >= default.GestureAmountForLevelUp[owner.XPLevel])
	{
		owner.GestureLevel -= default.GestureAmountForLevelUp[owner.XPLevel];
		owner.PlayerReplicationInfo.Score += 1 + owner.XPLevel;
		if (owner.XPLevel == 4) return; // no more upgrades
		owner.XPLevel++;
		owner.PlayerReplicationInfo.Streak = owner.XPLevel;
		owner.PlayLogSound(Sound'LogSkillPoints');
		owner.ClientMessage("Level upgraded to: " $ owner.XPLevel);
		owner.PawnInfo.static.Event_LevelUpReward(owner);
	}
}

static function string GetObjectHealth(CBPPlayer owner, bool sameteam)
{
	local string str;
	local SObject sobj;

	foreach owner.AllActors(class'SObject', sobj)
		if ((sameteam && owner.PlayerReplicationInfo.Team == sobj.Team) ||
			(!sameteam && owner.PlayerReplicationInfo.Team != sobj.Team)) 
	{

		str = string(float(sobj.HitPoints) * 100.0 / float(sobj.default.HitPoints));
		str = Left(str, InStr(str, ".") + 2) $ "%";
		return str;
	}

	return "";
}

static function HUDDraw(SPlayer splayer, Canvas canvas)
{
	local int X, Y, i;

	// draw level
	X = 16;
	Y = canvas.SizeY - 80;
	canvas.SetPos(X, Y);

	canvas.Font = default.TextFont;
	canvas.DrawColor = default.TextColor;
	canvas.DrawText("Level: " $ splayer.XPLevel);
	canvas.SetPos(X, Y + 10);
	canvas.DrawText("XP charge: " $ int((splayer.GestureLevel * 100.0 / default.GestureAmountForLevelUp[splayer.XPLevel])) $ "%");

	Y -= 12;
	
	for (i = 0; i < 4; i++)
	{
		if (i < splayer.XPLevel)
			DrawOutlinedRect(canvas, X, Y, 8, 8 * (i + 1), default.BackgroundSelectedColor, default.LineSelectedColor);
		else
			DrawOutlinedRect(canvas, X, Y, 8, 8 * (i + 1), default.BackgroundColor, default.LineColor);

		X += 12;
		Y -= 8;
	}

	// draw health of friendly & enemy object
	if (canvas.SizeY <= 1000) Y = 128;
	else Y = 256;
	X = 16;
	canvas.DrawColor = default.TextColor;
	canvas.SetPos(X, Y);
	canvas.DrawText("Friendly object health: " $ GetObjectHealth(splayer, true));
	canvas.SetPos(X, Y + 12);
	canvas.DrawText("Enemy object health: " $ GetObjectHealth(splayer, false));
}

static function DrawOutlinedRect(Canvas canvas, int x, int y, int w, int h, Color fillcol, Color outlinecol)
{
	canvas.SetPos(x, y);
	canvas.DrawColor = fillcol;
	canvas.DrawRect(Texture'Solid', w, h);
	canvas.DrawColor = outlinecol;
	canvas.SetPos(x, y);
	canvas.DrawRect(Texture'Solid', 1, h);
	canvas.SetPos(X, Y);
	canvas.DrawRect(Texture'Solid', w, 1);
	canvas.SetPos(X + w - 1, Y);
	canvas.DrawRect(Texture'Solid', 1, h);
	canvas.SetPos(X, Y + h - 1);
	canvas.DrawRect(Texture'Solid', w, 1);
}

static function HUDDrawGesturePic(Canvas canvas, int Xoff, Texture pic, string picstr)
{
	local int Y;
	local float w, h;

	Y = canvas.SizeY - 64 - 16 - 2 - 12;
	DrawOutlinedRect(canvas, Xoff, Y, 66, 66, default.GestureBackgroundColor, default.LineColor);
	canvas.SetPos(Xoff + 1, Y + 1);
	canvas.DrawTile(pic, 64, 64, 0, 0, 128, 128);
	canvas.Font = default.GPicFont;
	canvas.DrawColor = default.TextColor;
	canvas.TextSize(picstr, w, h);
	canvas.SetPos(Xoff + 33 - w / 2, Y + 54);
	canvas.DrawText(picstr);
}

static function HUDDrawGestureText(Canvas canvas, int Xoff, string text)
{
	local int Y;
	local float w, h;

	Y = canvas.SizeY - 16 - 10;
	canvas.Font = default.TextFont;
	canvas.DrawColor = default.TextColor;
	canvas.TextSize(text, w, h);
	canvas.SetPos(Xoff + 33 - w / 2, Y);
	canvas.DrawText(text);
}

static function Color GetColorScaled(float percent)
{
	local float mult;
	local Color col;

	if (percent > 0.80)
	{
		col.r = 0;
		col.g = 255;
		col.b = 0;
	}
	else if (percent > 0.40)
	{
		mult = (percent-0.40)/(0.80-0.40);
		col.r = 255 + (0-255)*mult;
		col.g = 255;
		col.b = 0;
	}
	else if (percent > 0.10)
	{
		mult = (percent-0.10)/(0.40-0.10);
		col.r = 255;
		col.g = 0 + (255-0)*mult;
		col.b = 0;
	}
	else if (percent > 0)
	{
		col.r = 255;
		col.g = 0;
		col.b = 0;
	}
	else
	{
		col.r = 0;
		col.g = 0;
		col.b = 0;
	}

	return col;

}

static function HUDDrawHealth(SPlayer owner, Canvas canvas, Texture h, Texture full, float maxhealth)
{
	canvas.SetPos(16, 16);
	canvas.DrawColor = default.TextColor;
	canvas.DrawTile(h, 96, 96, 0, 0, 128, 128);
	canvas.DrawColor = GetColorScaled(float(owner.HealthTorso) / maxhealth);
	canvas.SetPos(16, 16);
	canvas.DrawTile(full, 96, 96, 0, 0, 128, 128);
}

defaultproperties
{
    BackgroundColor=(R=40,G=40,B=40,A=0),
    BackgroundSelectedColor=(R=127,G=127,B=127,A=0),
    LineColor=(R=80,G=80,B=80,A=0),
    LineSelectedColor=(R=200,G=200,B=200,A=0),
    TextColor=(R=255,G=255,B=255,A=0),
    textFont=Font'DeusExUI.FontMenuSmall_DS'
    GPicFont=Font'DeusExUI.FontTiny'
    GestureBackgroundColor=(R=5,G=5,B=5,A=0),
    GestureAmountForLevelUp(0)=1.00
    GestureAmountForLevelUp(1)=1.25
    GestureAmountForLevelUp(2)=1.75
    GestureAmountForLevelUp(3)=2.50
    GestureAmountForLevelUp(4)=3.50
}
