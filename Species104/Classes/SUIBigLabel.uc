class SUIBigLabel extends MenuUILabelWindow;

event InitWindow()
{
	Super(TextWindow).InitWindow();

	SetFont(fontLabel);
	SetTextMargins(0, 0);
	SetTextAlignments(HALIGN_Center, VALIGN_Center);
	SetBaselineData(fontBaseLine, fontAcceleratorLineHeight);

	// Get a pointer to the player
	player = DeusExPlayer(GetRootWindow().parentPawn);

	StyleChanged();
}

defaultproperties
{
}
