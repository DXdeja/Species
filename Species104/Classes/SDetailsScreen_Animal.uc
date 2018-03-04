class SDetailsScreen_Animal extends SDetailsScreen;

function DrawImage(Texture img, int xpos, int ypos, int xsize, int ysize, optional bool bstretch)
{
	// always stretch
	super.DrawImage(img, xpos, ypos, xsize, ysize, true);
}

defaultproperties
{
}
