class SDetailsScreen extends MenuUIScreenWindow;

struct ConfigImage
{
	var Texture Image;
	var string Text;
	var bool bTextOnly;
};

var const ConfigImage Weapons[3];
var const ConfigImage StartAug;
var const ConfigImage LevelUpgrades1[4];
var const ConfigImage LevelUpgrades2[4];
var const ConfigImage LevelUpgrades3[4];
var const ConfigImage LevelUpgrades4[4];
var const ConfigImage AutoGenerates[2];

function CreateControls()
{
	Super.CreateControls();
	ShowWeapons();
	ShowStartAugs();
	ShowLevel1Upgrades();
	ShowLevel2Upgrades();
	ShowLevel3Upgrades();
	ShowLevel4Upgrades();
	ShowAutoGenerates();
}

function ShowAutoGenerates()
{
	local int i;
	local int xoff, yoff;

	if (AutoGenerates[0].Text == "") return;

	xoff = 8;
	yoff = 86 + 4 * 64;
	CreateBigLabel("Auto|ngenerates:", xoff, yoff, 80, 64);

	xoff += 80;

	for (i = 0; i < ArrayCount(AutoGenerates); i++)
	{
		if (AutoGenerates[i].Text == "") continue;
		if (AutoGenerates[i].bTextOnly)
		{
			CreateLabel(AutoGenerates[i].Text, xoff, yoff);
		}
		else
		{
			DrawImage(AutoGenerates[i].Image, xoff + 8, yoff, 44, 44);
			CreateLabel(AutoGenerates[i].Text, xoff, yoff + 44);
		}
		xoff += 64;
	}
}

function ShowWeapons()
{
	local int i;
	local int xoff;

	xoff = 8;
	CreateBigLabel("Weapons:", xoff, 8, 192);

	for (i = 0; i < ArrayCount(Weapons); i++)
	{
		if (Weapons[i].Text == "") continue;
		if (Weapons[i].bTextOnly)
		{
			CreateLabel(Weapons[i].Text, xoff, 24);
		}
		else
		{
			DrawImage(Weapons[i].Image, xoff + 8, 24, 44, 44);
			CreateLabel(Weapons[i].Text, xoff, 68);
		}
		xoff += 64;
	}
}

function ShowStartAugs()
{
	local int xoff;

	if (StartAug.Text == "") return;

	xoff = 216;
	CreateBigLabel("Starting augs:", xoff, 8, 128);
	DrawImage(StartAug.Image, xoff + 48, 24, 32, 32, true);
	CreateLabel(StartAug.Text, xoff + 32, 56);
}

function ShowLevel1Upgrades()
{
	local int i, xoff, yoff;

	xoff = 8;
	yoff = 86;
	CreateBigLabel("Level 1|nupgrades:", xoff, yoff, , 64);

	xoff += 64;

	for (i = 0; i < ArrayCount(LevelUpgrades1); i++)
	{
		if (LevelUpgrades1[i].Text == "") continue;
		if (LevelUpgrades1[i].bTextOnly)
			CreateLabel(LevelUpgrades1[i].Text, xoff, yoff);
		else
		{
			DrawImage(LevelUpgrades1[i].Image, xoff + 16, yoff, 32, 32, true);
			CreateLabel(LevelUpgrades1[i].Text, xoff, yoff + 32);
		}
		xoff += 64;
	}
}

function ShowLevel2Upgrades()
{
	local int i, xoff, yoff;

	xoff = 8;
	yoff = 86 + 64;
	CreateBigLabel("Level 2|nupgrades:", xoff, yoff, , 64);

	xoff += 64;

	for (i = 0; i < ArrayCount(LevelUpgrades2); i++)
	{
		if (LevelUpgrades2[i].Text == "") continue;
		if (LevelUpgrades2[i].bTextOnly)
			CreateLabel(LevelUpgrades2[i].Text, xoff, yoff);
		else
		{
			DrawImage(LevelUpgrades2[i].Image, xoff + 16, yoff, 32, 32, true);
			CreateLabel(LevelUpgrades2[i].Text, xoff, yoff + 32);
		}
		xoff += 64;
	}
}

function ShowLevel3Upgrades()
{
	local int i, xoff, yoff;

	xoff = 8;
	yoff = 86 + 2 * 64;
	CreateBigLabel("Level 3|nupgrades:", xoff, yoff, , 64);

	xoff += 64;

	for (i = 0; i < ArrayCount(LevelUpgrades3); i++)
	{
		if (LevelUpgrades3[i].Text == "") continue;
		if (LevelUpgrades3[i].bTextOnly)
			CreateLabel(LevelUpgrades3[i].Text, xoff, yoff);
		else
		{
			DrawImage(LevelUpgrades3[i].Image, xoff + 16, yoff, 32, 32, true);
			CreateLabel(LevelUpgrades3[i].Text, xoff, yoff + 32);
		}
		xoff += 64;
	}
}

function ShowLevel4Upgrades()
{
	local int i, xoff, yoff;

	xoff = 8;
	yoff = 86 + 3 * 64;
	CreateBigLabel("Level 4|nupgrades:", xoff, yoff, , 64);

	xoff += 64;

	for (i = 0; i < ArrayCount(LevelUpgrades4); i++)
	{
		if (LevelUpgrades4[i].Text == "") continue;
		if (LevelUpgrades4[i].bTextOnly)
			CreateLabel(LevelUpgrades4[i].Text, xoff, yoff);
		else
		{
			DrawImage(LevelUpgrades4[i].Image, xoff + 16, yoff, 32, 32, true);
			CreateLabel(LevelUpgrades4[i].Text, xoff, yoff + 32);
		}
		xoff += 64;
	}
}

function CreateLabel(string text, int xpos, int ypos)
{
	local SUISmallLabel label;
	label = SUISmallLabel(winClient.NewChild(Class'SUISmallLabel'));
	label.SetPos(xpos, ypos);
	label.SetWidth(64);
	label.SetText(text);
}

function CreateBigLabel(string text, int xpos, int ypos, optional int w, optional int h)
{
	local SUIBigLabel label;
	label = SUIBigLabel(winClient.NewChild(Class'SUIBigLabel'));
	label.SetPos(xpos, ypos);
	if (h == 0) h = 14;
	if (w == 0) w = 64;
	label.SetHeight(h);
	label.SetWidth(w);
	label.SetText(text);
}

function DrawImage(Texture img, int xpos, int ypos, int xsize, int ysize, optional bool bstretch)
{
	local Window pic;

	pic = winClient.NewChild(class'Window');
	pic.SetPos(xpos, ypos);
	pic.SetSize(xsize, ysize);
	pic.SetBackgroundStyle(DSTY_Masked);
	pic.SetBackground(img);
	pic.SetBackgroundStretching(bstretch);
}

defaultproperties
{
     actionButtons(0)=(Align=HALIGN_Right,Action=AB_OK)
     ClientWidth=350
     ClientHeight=405
     bUsesHelpWindow=False
     bEscapeSavesSettings=False
     ScreenType=ST_Menu
}
