Mission CreateCustomMission(string path)
{
	return new MissionGameplay();
}

void main()
{
	PlayerBase player;
	ItemBase item;

	// Create player
	player = PlayerBase.Cast((GetGame().CreatePlayer(NULL, "SurvivorF_Linda", "2200 10 2200", 0, "NONE")));

	// Spawn a black t-shirt
	item = player.GetInventory().CreateInInventory("TShirt_Black");

	// Spawn an apple in the t-shirt, don't redefine 'item' so we can still spawn other items in the t-shirt
	item.GetInventory().CreateInInventory("Apple");

	// Select player the client will be controlling
	GetGame().SelectPlayer(NULL, player);
}