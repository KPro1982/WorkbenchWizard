#--------------------------------------------
# Declare Global Variables and Functions here
#--------------------------------------------
$CommandlineMessage = ""


function Get-ScriptDirectory
{
<#
	.SYNOPSIS
		Get-ScriptDirectory returns the proper location of the script.

	.OUTPUTS
		System.String
	
	.NOTES
		Returns the correct path within a packaged executable.
#>
	[OutputType([string])]
	param ()
	if ($null -ne $hostinvocation)
	{
		Split-Path $hostinvocation.MyCommand.path
	}
	else
	{
		Split-Path $script:MyInvocation.MyCommand.Path
	}
}



function Get-Settings
{
	[CmdletBinding()]
	[OutputType([hashtable])]
	param
	(
		$settingname
	)
	
	$ksettingpath = Get-ScriptDirectory
	$ksettingpath = $ksettingpath + "\" + $settingname
	$hashtable = @{ }
	try
	{
		$json = Get-Content $ksettingpath | Out-String
	}
	catch
	{	
		Return $hashtable
	}
	(ConvertFrom-Json $json).psobject.properties | Foreach { $hashtable[$_.Name] = $_.Value }
	
	
	Return $hashtable
}
function Set-Settings
{
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory = $true)]
		[string]$settingname,
		[Parameter(Mandatory = $true)]
		[string]$key,
		[Parameter(Mandatory = $true)]
		[AllowEmptyString()]
		[string]$value
	)
	
	$hashtable = Get-Settings($settingname)
	$ksettingpath = Get-ScriptDirectory
	$ksettingpath = $ksettingpath + "\" + $settingname
	$hashtable[$key] = $value
	
	$hashtable | ConvertTo-Json | Set-Content $ksettingpath
}

function Read-ModParam
{
	[CmdletBinding()]
	[OutputType([string])]
	param
	(
		[Parameter(Mandatory = $true)]
		[string]$key
	)
	
	$hashtable = Get-Settings -settingname "ModSettings.json"
	$value = $hashtable[$key]
	return $value
}
function Write-ModParam
{
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory = $true)]
		[ValidateNotNullOrEmpty()]
		[string]$key,
		[Parameter(Mandatory = $true)]
		[AllowEmptyString()]
		[string]$value,
		[switch]$Append
	)
	
	if ($Append)
	{
		$oldvalue = Read-ModParam -settingname "ModSettings.json" -key $key
		$value = $oldvalue + ';' + $value
	}
	Set-Settings -settingname "ModSettings.json" -key $key -value $value
}
function Read-GlobalParam
{
	[CmdletBinding()]
	[OutputType([string])]
	param
	(
		[Parameter(Mandatory = $true)]
		[string]$key
	)
	
	$hashtable = Get-Settings -settingname "GlobalSettings.json"
	$value = $hashtable[$key]
	return $value
}
function Write-GlobalParam
{
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory = $true,
				   Position = 1)]
		[ValidateNotNullOrEmpty()]
		[string]$key,
		[Parameter(Mandatory = $true,
				   Position = 2)]
		[AllowEmptyString()]
		[string]$value
	)
	
	Set-Settings -settingname "GlobalSettings.json" -key $key -value $value
}

function Write-TempParam
{
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory = $true,
				   Position = 1)]
		[ValidateNotNullOrEmpty()]
		[string]$key,
		[Parameter(Mandatory = $true,
				   Position = 2)]
		[string]$value
	)
	
	Set-Settings -settingname "Temp.json" -key $key -value $value
}
function Read-TempParam
{
	[CmdletBinding()]
	[OutputType([string])]
	param
	(
		[Parameter(Mandatory = $true)]
		[string]$key
	)
	
	$hashtable = Get-Settings -settingname "Temp.json"
	$value = $hashtable[$key]
	return $value
}

function Get-KAddons
{
	[CmdletBinding()]
	[OutputType([string])]
	param ()
	
	$addonsfolder = Read-GlobalParam -key "AddonsFolder"
	$modname = Read-ModParam -key "ModName"
	$packedmodname = '@' + $modname
	$modlist = Read-GlobalParam -key "PackedModFolder"
	$modlist = Add-Folder -Source $modlist -Folder $packedmodname
	$modlist += ';'
	$addonsstr = Read-ModParam -key "AdditionalMPMods"
	if ($addonsstr)
	{
		$addons = $addonsstr.Split(";")
		$addons | foreach {
			$mod = $_
			$modlist = $modlist + $addonsfolder + '\' + $mod.Trim() + ';'
			
		}
	}
	$modlist = $modlist.TrimEnd(';')
	Return $modlist
}

function Start-kServer
{
	param
	(
		[switch]$CommandLine
	)
	
	$modlist = Get-kAddons
	$gamef = Read-GlobalParam -key "GameFolder"
	$serverDZ = $gamef + "\serverDZ.cfg"
	$mods = "`"-mod=" + $modlist + "`""
	$command = $gamef + "\DayZDiag_x64.exe"
	$params = $mods, '-filePatching', '-server', '-config=serverDZ.cfg', '-profiles=S:\Steam\steamapps\common\DayZ\profiles'
	
	if ($commandline)
	{
		return $command + " " + $params
	}
	else
	{
		Set-Folder -key "GameFolder"
		& $command @params
	}
	
	
}

function Start-kMPGame
{
	param
	(
		[switch]$CommandLine
	)
	
	$modlist = Get-KAddons
	$gamef = Read-GlobalParam ("GameFolder")
	$command = $gamef + "\DayZDiag_x64.exe"
	$mods = "`"-mod=" + $modlist + "`""
	$params = $mods, '-filePatching', '-connect=127.0.0.1', '-port=2302'
	
	if ($commandline)
	{
		return $command + " " + $params
	}
	else
	{
		Set-Folder -key "GameFolder"
		& $command @params
	}
	
}


function Start-kWorkbench
{
	[CmdletBinding()]
	param
	(
		[switch]$Commandline = $false
	)
	
	$modlist = Get-KAddons
	$workbenchf = Read-GlobalParam -key WorkbenchFolder
	$workbenchf = Read-GlobalParam -key WorkbenchFolder
	$command = Add-Folder -Source $workbenchf -Folder "workbenchApp.exe"
	# $mods = "`"-mod=" + $modlist + "`""
	$params = "S:\Steam\steamapps\common\DayZ\Mod-Source\FirstMod\Workbench\dayz.gproj"
	$command = Add-Folder -Source $workbenchf -Folder "workbenchApp.exe"
	
	if ($commandline)
	{
		 return $command + " " + $params

	}
	else
	{
		
		$curmodfolder = Read-GlobalParam -key "CurrentModFolder"
		$modworkbenchfolder = Add-Folder -Source $curmodfolder -Folder "Workbench"
		Set-Location $modworkbenchfolder
		& $command @params

	}
	
}

function Start-Build
{
	[CmdletBinding()]
	param
	(
		[switch]$Commandline = $false
	)
	
	
	# $params = "-P", "-Z", "-O", "-E=dayz", "-K", "+M=P:\PackedMods\@FirstMod", "S:\Steam\steamapps\common\DayZ\Mod-Source\FirstMod\Scripts"
	$command = "pboProject.exe"
	
	$paramsetting = Read-GlobalParam -key "PboProjectParams"
	$paramsetting += " +M=P:\PackedMods\@FirstMod"
	$paramsetting += " S:\Steam\steamapps\common\DayZ\Mod-Source\FirstMod\Scripts"
	
	$params = $paramsetting.Split(',')

	if ($commandline)
	{
		return $command + " " + $params
	}
	else
	{
		Set-Location "P:"
		Start-Process "pboProject.exe" -ArgumentList $params
	}
}
function Get-PackedMod
{
	[OutputType([string])]
	param ()
	
	[CmdletBinding()]

	
	$modname = "`@" + $lblModName.Text
	$packedmodfolder = Read-GlobalParam -key "PackedModFolder"
	$packedmodfolder = Add-Folder -Source $packedmodfolder -Folder $modname
	
	return $packedmodfolder
}


function Stop-kDayz
{
	taskkill /im DayZDiag_x64.exe /F /FI "STATUS eq RUNNING"
}

function Read-SteamCommon
{
	[CmdletBinding()]
	[OutputType([string])]
	param ()
	
	$regpath = (Get-ItemProperty -Path 'Registry::HKEY_CURRENT_USER\Software\Bohemia Interactive\Dayz Tools').path
	$commonpath = $regpath.Split('\')
	$finalpath = $commonpath[0]
	for ($i = 1; $i -lt $commonpath.Length - 1; $i++)
	{
		$finalpath += '\' + $commonpath[$i]
	}
	return $finalpath
}


function Assert-Mikero
{
	[CmdletBinding()]
	[OutputType([bool])]
	param
	(
		[Parameter(Mandatory = $false)]
		[ref]$outpath
	)
	
	# "C:\Program Files (x86)\Mikero\DePboTools"
	
	
	
	$testpath = "C:\Program Files (x86)\Mikero\DePboTools"
	if (Test-Path -Path $testpath)
	{
		if ($outpath)
		{
			$outpath.Value = $testpath
		}
		return $true
	}
	else
	{
		return $false
	}
}

<#
	.SYNOPSIS
		Test whether DayzFolder Exists
	
	.DESCRIPTION
		A detailed description of the Assert-DayzFolder function.
	
	.PARAMETER dayzfolderpath
		A description of the dayzfolderpath parameter.
	
	.EXAMPLE
		PS C:\> Assert-DayzFolder
	
	.NOTES
		Additional information about the function.
#>
function Assert-DayzFolder
{
	[CmdletBinding()]
	[OutputType([bool])]
	param
	(
		[Parameter(Mandatory = $false)]
		[ref]$outpath
	)
	
	$common = Read-SteamCommon
	$testpath = $common + "\DayZ"
	if (Test-Path -Path $testpath)
	{
		if($outpath)
		{
			$outpath.Value = $testpath
		}

		return $true
	}
	else
	{
		return $false
	}
}
function Assert-ToolsFolder
{
	[CmdletBinding()]
	[OutputType([bool])]
	param
	(
		[Parameter(Mandatory = $false)]
		[ref]$outpath
	)

	$common = Read-SteamCommon
	$testpath = Add-Folder -Source $common -Folder "\DayZ Tools\Bin\"

	if (Test-Path -Path $testpath)
	{
		if ($outpath)
		{
			$outpath.Value = $testpath
		}
		return $true
	}
	else
	{
		return $false
	}
}

function Assert-ServerFolder
{
	[CmdletBinding()]
	[OutputType([bool])]
	param
	(
		[Parameter(Mandatory = $false)]
		[ref]$outpath
	)
	
	$common = Read-SteamCommon
	$testpath = $common + "\DayZServer"
	if (Test-Path -Path $testpath)
	{
		if ($outpath)
		{
			$outpath.Value = $testpath
		}
		return $true
	}
	else
	{
		return $false
	}
}
function Assert-WorkbenchFolder
{
	[CmdletBinding()]
	[OutputType([bool])]
	param
	(
		[Parameter(Mandatory = $true)]
		[ref]$outpath
	)
	
	$common = Read-SteamCommon
	$testpath = $common + "\DayZ Tools\Bin\Workbench"
	if (Test-Path -Path $testpath)
	{
		if ($outpath)
		{
			$outpath.Value = $testpath
		}
		return $true
	}
	else
	{
		return $false
	}
}
function Assert-ProjectDrive
{
	[CmdletBinding()]
	[OutputType([bool])]
	param
	(
		[Parameter(Mandatory = $false)]
		[ref]$outpath
	)
	


	if (Measure-Pdrive)
	{
		if ($outpath)
		{
			$outpath.Value = $testpath
		}
		return $true
	}
	else
	{
		return $false
	}
}

function Measure-Pdrive
{
	[CmdletBinding()]
	[OutputType([bool])]
	param ()
	
	#TODO: Place script here
	
	$fsize = (Get-ChildItem "P:\DZ" | Measure-Object -Property Length -sum)
	$fsize = ((Get-ChildItem P:\DZ -Recurse | Measure-Object -Property Length -Sum -ErrorAction Stop).Sum / 1GB)
	$ret = ($fsize -gt 18)
	return ($fsize -gt 18)
}


function Link-Scripts
{
	[CmdletBinding()]
	param ()
	
	#TODO: Place script here
	# Link mklink /J  "S:\Steam\steamapps\common\DayZ\scripts\" "P:\scripts\"
	

	
	$link = Read-GlobalParam -key "GameFolder"
	$link  = Add-Folder -Source $link  -Folder "Scripts"
	
	$target= "P:\Scripts"
	
	New-Item -ItemType SymbolicLink -Path $link -Target $target
	
	
}

function Link-Source
{
	[CmdletBinding()]
	param ()
	
	#TODO: Place script here
	# mklink /J "P:\FirstMod\" "S:\Steam\steamapps\common\DayZ\Mod-Source\FirstMod\" 
		

	$link = "P:\FirstMod"	
	$target = Read-GlobalParam -key "ModSourceFolder"
	New-Item -ItemType SymbolicLink -Path $link -Target $target
	
	$link = Read-GlobalParam -key "GameFolder"
	$link = Add-Folder -Source $link -Folder "FirstMod"
	New-Item -ItemType SymbolicLink -Path $link -Target $target
	

}
function Link-Packed
{
	[CmdletBinding()]
	param ()
	
	#TODO: Place script here
	# mklink /J "S:\Steam\steamapps\common\DayZ\@FirstMod\"  "P:\PackedMods\@FirstMod\" 
	
	

	$packedfolder = "@FirstMod"
	
	$link = Read-GlobalParam -key "GameFolder"
	$link = Add-Folder -Source $link -Folder $packedfolder
	
	$target = Read-GlobalParam -key "PackedModFolder"

	New-Item -ItemType SymbolicLink -Path $link -Target $target

	$link = "P:\@FirstMod"
	
	New-Item -ItemType SymbolicLink -Path $link -Target $target
	
}

# Safely add new folder to path
function Add-Folder
{
	[CmdletBinding()]
	[OutputType([string])]
	param
	(
		[Parameter(Mandatory = $true)]
		[string]$Source,
		[Parameter(Mandatory = $true)]
		[string]$Folder
	)
	
	# check for terminal \
	$Source = $Source.TrimEnd('\')
	$Folder = $Folder.TrimStart('\')
	
	$newfolder = $Source + "\" + $Folder
	
	return $newfolder
}
function Assert-EndSlash
{
	[CmdletBinding()]
	[OutputType([string])]
	param
	(
		[Parameter(Mandatory = $true)]
		[string]$Path
	)
	
	#TODO: Place script here
	
	$Path.TrimEnd('\')
	$Path += "\"
	
	return $Path
}

#

function Set-Folder
{
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory = $true)]
		[string]$key
	)
	
	$foldername = Read-GlobalParam -key $key
	Set-Location -Path $foldername
	
}
function Set-CommandlineMessage
{
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory = $false)]
		[string]$Message,
		[switch]$Clear
	)
	
	#TODO: Place script here
	if (-not $Clear)
	{
		Write-TempParam -key "Commandline" -value $Message
	}
	else
	{
		$Message = ""
		Write-TempParam -key "Commandline" -value $Message
		
	}
	
}
function Get-CommandlineMessage
{
	[CmdletBinding()]
	[OutputType([string])]
	param ()
	
	#TODO: Place script here
	return Read-TempParam -key "Commandline"
}

function Write-BatchFiles
{
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory = $true)]
		[string]$Folder
	)
	

	$targetfiles = Get-ChildItem $Folder  *.* -File -rec
	
	foreach ($file in $targetfiles)
	{
		if ($file.Extension -eq ".bat")
		{
			# WB_WORKBENCHFOLDER
			$workbenchexe = ""
			Assert-WorkbenchFolder -outpath ([ref]$workbenchexe)
			(Get-Content $file.PSPath) |
			Foreach-Object { $_ -replace "WB_WORKBENCHFOLDER", $workbenchexe } |
			Set-Content $file.PSPath
			
			# WB_ADDONBUILDER
			$addonbuilder = ""
			$addonbuilder = Read-SteamCommon
			$addonbuilder = Add-Folder -Source $addonbuilder -Folder "DayZ Tools\Bin\AddonBuilder"
			(Get-Content $file.PSPath) |
			Foreach-Object { $_ -replace "WB_ADDONBUILDERFOLDER", $addonbuilder } |
			Set-Content $file.PSPath
			
			# WB_PACKEDMOD
			$packmod = Read-GlobalParam -key "PackedModFolder"
			(Get-Content $file.PSPath) |
			Foreach-Object { $_ -replace "WB_PACKEDMOD", $packmod } |
			Set-Content $file.PSPath
			
			# WB_DAYZFOLDER
			$dayzf = ""
			Assert-DayzFolder -outpath ([ref]$dayzf)
			(Get-Content $file.PSPath) |
			Foreach-Object { $_ -replace "WB_DAYZFOLDER", $dayzf } |
			Set-Content $file.PSPath
			
			# WB_PROFILES
			$dzprofies = ""
			Assert-DayzFolder -outpath ([ref]$dzprofies)
			$dzprofies = Add-Folder -Source $dzprofies -Folder "Profiles"
			(Get-Content $file.PSPath) |
			Foreach-Object { $_ -replace "WB_PROFILES", $dzprofies } |
			Set-Content $file.PSPath
			
			# WB_SOURCEFOLDER
			$sourcefolder = Read-GlobalParam -key "ModSourceFolder"
			(Get-Content $file.PSPath) |
			Foreach-Object { $_ -replace "WB_SOURCEFOLDER", $sourcefolder } |
			Set-Content $file.PSPath
			
		}
		
	}
}



