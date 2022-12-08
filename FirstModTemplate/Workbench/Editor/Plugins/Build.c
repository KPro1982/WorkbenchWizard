

[WorkbenchPluginAttribute("Launch and Build Diag Server", "Launches Server", "Ctrl+F6", "", {"ResourceManager", "ScriptEditor"})]
class LaunchBuildServer: DayZProjectManager
{
	override void Run()
	{
		RunDayZBat(string.Format("P:\\%1\\Workbench\\Batchfiles\\Exit.bat", ModName), true);
		RunDayZBat(string.Format("P:\\%1\\Workbench\\Batchfiles\\ZBinarizeDeploy.bat", ModName), true);
		RunDayZBat(string.Format("P:\\%1\\Workbench\\Batchfiles\\LaunchServer.bat", ModName));
		RunDayZBat(string.Format("P:\\%1\\Workbench\\Batchfiles\\LaunchLocalMP.bat", ModName));
	}
}

[WorkbenchPluginAttribute("Quick Kill", "Kills Server & Game", "F8", "", {"ResourceManager", "ScriptEditor"})]
class QuickKill: DayZProjectManager
{
	override void Run()
	{
		RunDayZBat(string.Format("P:\\%1\\Workbench\\Batchfiles\\Exit.bat", ModName), true);
	}
}
