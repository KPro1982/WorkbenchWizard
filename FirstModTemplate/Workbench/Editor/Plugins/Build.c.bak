[WorkbenchPluginAttribute("Build Mod", "Builds current mod", "", "", {"ResourceManager", "ScriptEditor"})]
class BuildMod: DayZProjectManager
{
	override void Run()
	{
		RunDayZBatList({
			string.Format("P:\\%1\\Workbench\\Batchfiles\\Exit.bat", ModName), 
			string.Format("P:\\%1\\Workbench\\Batchfiles\\ZBinarizeDeploy.bat", ModName)
		});
	}
}


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


[WorkbenchPluginAttribute("Standard Launch and Build", "Launches Standard Server", "", "", {"ResourceManager", "ScriptEditor"})]
class StandardLaunchBuildServer: DayZProjectManager
{
	override void Run()
	{
		RunDayZBat(string.Format("P:\\%1\\Workbench\\Batchfiles\\Exit.bat", ModName), true);
		RunDayZBat(string.Format("P:\\%1\\Workbench\\Batchfiles\\ZBinarizeDeploy.bat", ModName), true);
		RunDayZBat(string.Format("P:\\%1\\Workbench\\Batchfiles\\LaunchStandardServer.bat", ModName));
		RunDayZBat(string.Format("P:\\%1\\Workbench\\Batchfiles\\LaunchStandardLocalMP.bat", ModName));
	}
}
