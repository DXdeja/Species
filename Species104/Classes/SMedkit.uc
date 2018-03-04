class SMedkit extends CBPMedkit;

state Activated
{
	function BeginState()
	{
		local SPlayer player;
		local int heala;
		local float hdelta;
		
		Super(CBPPickup).BeginState();

		player = SPlayer(Owner);

		if (player != none) 
		{
			heala = player.CalculateSkillHealAmount(healAmount);
		}

		if (player != none && SPlayer(Player.FrobTarget) != none &&
			class'CBPGame'.static.ArePlayersAllied(player, SPlayer(Player.FrobTarget)))
		{
			// heal teammate
			player = SPlayer(Player.FrobTarget); 
		}

		if (player != none)
		{
			hdelta = float(player.HealPlayer(heala, false));
			SPlayer(Owner).PlayLogSound(sound'MedicalHiss');
			if (player != SPlayer(Owner)) player.PlayLogSound(sound'MedicalHiss');

			// Medkits kill all status effects when used in multiplayer
			player.StopPoison();
			player.ExtinguishFire();
			player.drugEffectTimer = 0;

			// reward if healed teammate
			if (hdelta > 0.0 && SPlayer(Owner) != player)
			{
				if (SGame(Level.Game) != none)
					SGame(Level.Game).GestureReward(SPlayer(Owner), player, 'Heal', FClamp((hdelta / heala), 0.0, 1.0));
			}
		}

		UseOnce();
	}
}

defaultproperties
{
    bCanDrop=False
    bOnlyOwnerSee=True
}
