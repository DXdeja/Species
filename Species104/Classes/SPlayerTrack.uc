class SPlayerTrack extends CBPPlayerTrack;

function HandlePlayerCloak(DeusExPlayer OtherPlayer, float DeltaTime)
{
   local SPlayer MyPlayer;
   local bool bAllied;
   local bool bIamRobot;

   MyPlayer = SPlayer(GetPlayerPawn());
   if (class<PT_Robot>(MyPlayer.PawnInfo) != none) bIamRobot = true;

   TimeSinceCloak += DeltaTime;

   if (OtherPlayer == None)
      return;

   if (MyPlayer == None)
      return;

   if (bIamRobot)
   {    
   		if (SPlayer(OtherPlayer).bRadarTransOn) OtherPlayer.Style = STY_Translucent;
		else 
		{
			OtherPlayer.Style = OtherPlayer.default.Style;
		}
   }
   else
   {
		if (SPlayer(OtherPlayer).bCloakOn) OtherPlayer.Style = STY_Translucent;
		else 
		{
			OtherPlayer.Style = OtherPlayer.default.Style;
		}
   }

   if (OtherPlayer.Style != STY_Translucent)
   {
      TimeSinceCloak = 0;
	  OtherPlayer.ScaleGlow = 1.0;
      //OtherPlayer.CreateShadow();
      //if (OtherPlayer.IsA('JCDentonMale'))
      //{
      //   OtherPlayer.MultiSkins[6] = OtherPlayer.Default.MultiSkins[6];
      //   OtherPlayer.MultiSkins[7] = OtherPlayer.Default.MultiSkins[7];
      //}
      return;
   }

   if (OtherPlayer == MyPlayer)
      return;

   //if (OtherPlayer.IsA('JCDentonMale'))
   //{
   //   OtherPlayer.MultiSkins[6] = Texture'BlackMaskTex';
   //   OtherPlayer.MultiSkins[7] = Texture'BlackMaskTex';
   //}
   
   bAllied = False;

   if (MyPlayer.GameReplicationInfo.bTeamGame && class'CBPGame'.static.ArePlayersAllied(OtherPlayer,MyPlayer))
      bAllied = True;

   //OtherPlayer.KillShadow();

   if (!bAllied)
   {
      //DEUS_EX AMSD Do a gradual cloak fade.
      OtherPlayer.ScaleGlow = OtherPlayer.Default.ScaleGlow * (0.01 / TimeSinceCloak);
      if (OtherPlayer.ScaleGlow <= 0.02)
         OtherPlayer.ScaleGlow = 0;
   }
   else
      OtherPlayer.ScaleGlow = 0.25;

   return;
}

defaultproperties
{
}
