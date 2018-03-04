class AnimVsHumDef extends Object
	abstract;

var byte ANIMAL_TEAM;
var byte HUMAN_TEAM;

var string TeamNames[2];
var class<SMenuChoice_Class> TeamMenuChoiceClasses[2];

var class<PawnType> PawnTypes[12];
var byte PawnTeams[12];
var string PawnNames[12];
var Texture PawnPortraits[12];
var string PawnText[12];
var class<SDetailsScreen> DetailsScreen[12];

var string HelpText;

static function int GetIndexOfPawnType(class<PawnType> pt)
{
	local int i;
	for (i = 0; i < ArrayCount(default.PawnTypes); i++)
		if (pt == default.PawnTypes[i]) return i;
	return 255;
}

defaultproperties
{
    HUMAN_TEAM=1
    TeamNames(0)="Animals"
    TeamNames(1)="Humans"
    TeamMenuChoiceClasses(0)=Class'SMenuChoice_Class_A'
    TeamMenuChoiceClasses(1)=Class'SMenuChoice_Class_H'
    PawnTypes(0)=Class'Animal_Karkian'
    PawnTypes(1)=Class'Animal_Gray'
    PawnTypes(2)=Class'Animal_Greasel'
    PawnTypes(3)=Class'Animal_Dog'
    PawnTypes(4)=Class'Robot_Bot2'
    PawnTypes(5)=Class'Robot_Spider'
    PawnTypes(6)=Class'Human_Soldier'
    PawnTypes(7)=Class'Human_Nurse'
    PawnTypes(8)=Class'Human_Engineer'
    PawnTypes(9)=Class'Human_SpecForce'
    PawnTypes(10)=Class'Human_Hacker'
    PawnTypes(11)=Class'Human_Flamer'
    PawnTeams(6)=1
    PawnTeams(7)=1
    PawnTeams(8)=1
    PawnTeams(9)=1
    PawnTeams(10)=1
    PawnTeams(11)=1
    PawnNames(0)="Karkian"
    PawnNames(1)="Gray"
    PawnNames(2)="Greasel"
    PawnNames(3)="Dog"
    PawnNames(4)="Robot"
    PawnNames(5)="Spider"
    PawnNames(6)="Soldier"
    PawnNames(7)="Nurse"
    PawnNames(8)="Engineer"
    PawnNames(9)="SpecialForce"
    PawnNames(10)="Hacker"
    PawnNames(11)="Flamer"
    PawnPortraits(0)=Texture'karkian'
    PawnPortraits(1)=Texture'gray'
    PawnPortraits(2)=Texture'greasel'
    PawnPortraits(3)=Texture'dog'
    PawnPortraits(4)=Texture'walkingbot'
    PawnPortraits(5)=Texture'spiderBot'
    PawnPortraits(6)=Texture'soldier'
    PawnPortraits(7)=Texture'nurse'
    PawnPortraits(8)=Texture'engineer'
    PawnPortraits(9)=Texture'specforce'
    PawnPortraits(10)=Texture'hacker'
    PawnPortraits(11)=Texture'flamer'
    PawnText(0)="KARKIAN|n|nKarkian has high amount of health. It is most efficient in large opened spaces at attacking several enemies at the same time (running and passing by them, thus performing bump attacks). Karkian accelerates slowly - that makes him weak in small rooms. Due to it's size, karkian is easy to be hit. Health can be regained by eating dead animals or humans."
    PawnText(1)="GRAY|n|nGray is a fast moving animal that has two types of attacks and radiation field around that automatically hurt humans that are close enough. Primary attack is swipe and secondary is deadly radiation spite. Grays have Vision augmentation and can see Cloaked humans. Grays regain health by being close together."
    PawnText(2)="GREASEL|n|nGreasel is small but deadly animal. Due to it's size, it is very hard to be hit. It has only one type of attack - deadly poisoned spite."
    PawnText(3)="DOG|n|nDog is a very fast moving animal with fast jumping attacks. Dog is agile and relatively small. That makes him hard to be hit with any weapon. Because dog's footsteps aren't heard, dog can be lethal performing silent kills from the back."
    PawnText(4)="ROBOT|n|nRobot can fire front-mounted Mini-Gun. It is very large thus easy to be hit, but it is packed with a lot of health. Robot has auto-regenerate feature, which turns on after not being hurt for some time. When robot is EMPed, its vision is distorted and Mini-Gun fires slowly."
    PawnText(5)="SPIDER|n|nSpider robot is smaller and weaker compared to Robot. It's task is to suck away bioeletric energy of Humans. Just like Robot, Spider has ability to auto-regenerate health. Spider can be efficient at temporary disabling auto turrets."
    PawnText(6)="SOLDIER|n|nSoldier is the most powerful human character, carrying best close combat weapon - Assault Rifle. He can get 3 type of protective augmentations thus making him very hard to kill when leveled high. Because Assault Rifle weapon can quickly run out of ammo, it is very important that Soldier has good support of Engineers and Nurses."
    PawnText(7)="NURSE|n|nNurse's primary task is heal other human characters on field."
    PawnText(8)="ENGINEER|n|nEngineer's primary task is to support other human characters with ammo and bioeletric energy."
    PawnText(9)="SPECIAL FORCE|n|nSpecial Force's responsibility is to prepare special hidden attacks, thus being eqipped with auto-generating LAMs. LAMs are deadly exploding grenades that can kill several opponents at the same time. With Cloak augmentation, Special Force can hide against animals (not robot), but Grays can see him on short distance if using Vision."
    PawnText(10)="HACKER|n|nHacker can issue EMP attacks on robots and temporary cripple them. He can also place auto shooting turrets, which are most deadly to Greasels and Dogs. Carrying only one weapon means he is voulnerable in open fights and needs steady supply of ammo."
    PawnText(11)="FLAMER|n|nFlamer can set on fire enemies using 3 different kind of weapons. He has to have good support of engineers, because he can carry only one WP rocket at any time."
    DetailsScreen(0)=Class'SDetailsScreen_Karkian'
    DetailsScreen(1)=Class'SDetailsScreen_Gray'
    DetailsScreen(2)=Class'SDetailsScreen_Greasel'
    DetailsScreen(3)=Class'SDetailsScreen_Dog'
    DetailsScreen(4)=Class'SDetailsScreen_Walkingbot'
    DetailsScreen(5)=Class'SDetailsScreen_Spider'
    DetailsScreen(6)=Class'SDetailsScreen_Soldier'
    DetailsScreen(7)=Class'SDetailsScreen_Nurse'
    DetailsScreen(8)=Class'SDetailsScreen_Engineer'
    DetailsScreen(9)=Class'SDetailsScreen_SpecForce'
    DetailsScreen(10)=Class'SDetailsScreen_Hacker'
    DetailsScreen(11)=Class'SDetailsScreen_Flamer'
    HelpText="Welcome to Animals Versus Humans DeusEx Multiplayer modification.|n|nGoal of the game is to destroy enemy's object.|n|nYou have two teams available; Humans and Animals. Animals are more primitive, easier to control and require less teamwork to perform well. If you are a beginner, it is recommended to play as Animal. Humans are weak without proper teamplay. If Humans are supported well with Engineers and Nurses, they can perform well.|n|nEach character on both sides have some unique capabilities that can be logically understandable - some Animals can eat dead bodies and regain health, Human character Hacker masters EMP and knows how to hide in front of Robots, etc."
}
