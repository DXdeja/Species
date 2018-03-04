class SHUDHitDisplay extends HUDHitDisplay;

var window bodyWin;
var SPlayer splayer;

event InitWindow()
{
	Super(HUDBaseWindow).InitWindow();

	bTickEnabled = True;

	Hide();

	player = DeusExPlayer(DeusExRootWindow(GetRootWindow()).parentPawn);
	splayer = SPlayer(player);

	SetSize(84, 106);

	CreateBodyPart(head,     Texture'HUDHitDisplay_Head',     39, 17,  4,  7);
	CreateBodyPart(torso,    Texture'HUDHitDisplay_Torso',    36, 25, 10,  23);
	CreateBodyPart(armLeft,  Texture'HUDHitDisplay_ArmLeft',  46, 27, 10,  23);
	CreateBodyPart(armRight, Texture'HUDHitDisplay_ArmRight', 26, 27, 10,  23);
	CreateBodyPart(legLeft,  Texture'HUDHitDisplay_LegLeft',  41, 44,  8,  36);
	CreateBodyPart(legRight, Texture'HUDHitDisplay_LegRight', 33, 44,  8,  36);

	bodyWin = NewChild(Class'Window');
	bodyWin.SetBackground(Texture'HUDHitDisplay_Body');
	bodyWin.SetBackgroundStyle(DSTY_Translucent);
	bodyWin.SetConfiguration(24, 15, 34, 68);
	bodyWin.SetTileColor(colArmor);
	bodyWin.Lower();

	winEnergy = CreateProgressBar(15, 20);
	winBreath = CreateProgressBar(61, 20);

	damageFlash = 0.4;  // seconds
	healFlash   = 1.0;  // seconds
}

function bool ShouldHide()
{
	if (splayer == none) return true;
	if (splayer.PlayerReplicationInfo.bIsSpectator) return true;
	if (splayer.PawnInfo != none && splayer.PawnInfo.default.bOwnHealthBar) return true;
	else return false;
}

event Tick(float deltaSeconds)
{
	if (splayer == none) return;

	if (!bVisible)
	{
		Hide();
		return;
	}

	// do not display if having own health bar
	if (ShouldHide())
	{
		if (winEnergy != none) winEnergy.Hide();
		if (winBreath != none) winBreath.Hide();
		if (bodyWin != none) bodyWin.Hide();
		if (head.partWindow != none) head.partWindow.Hide();
		if (torso.partWindow != none) torso.partWindow.Hide();
		if (armLeft.partWindow != none) armLeft.partWindow.Hide();
		if (armRight.partWindow != none) armRight.partWindow.Hide();
		if (legLeft.partWindow != none) legLeft.partWindow.Hide();
		if (legRight.partWindow != none) legRight.partWindow.Hide();
		if (armor.partWindow != none) armor.partWindow.Hide();
		Show();
	}
	else 
	{
		if (winEnergy != none) winEnergy.Show();
		if (winBreath != none) winBreath.Show();
		if (bodyWin != none) bodyWin.Show();
		if (head.partWindow != none) head.partWindow.Show();
		if (torso.partWindow != none) torso.partWindow.Show();
		if (armLeft.partWindow != none) armLeft.partWindow.Show();
		if (armRight.partWindow != none) armRight.partWindow.Show();
		if (legLeft.partWindow != none) legLeft.partWindow.Show();
		if (legRight.partWindow != none) legRight.partWindow.Show();
		if (armor.partWindow != none) armor.partWindow.Show();
		super.Tick(deltaSeconds);
	}
}

event DrawWindow(GC gc)
{
	if (!ShouldHide()) 
		super.DrawWindow(gc);
}

function DrawBackground(GC gc)
{
	if (!ShouldHide()) 
		super.DrawBackground(gc);
}

function DrawBorder(GC gc)
{
	if (!ShouldHide()) 
		super.DrawBorder(gc);
}

defaultproperties
{
}
