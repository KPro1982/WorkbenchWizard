Use workbench wizard to quickly install a solid scripting environment using dayz workbench.  The video tut for it is here https://youtu.be/Uipgrm2ZQQQ

I added modded apple.c to the 4_world module which provides a better way to test whether hotload is working. Hot loading is hit or miss with playerbase.  You can make changes to the code in modded apple.c to change what is displayed when you hover over an apple in your players inventory.

Workbenchwizard.exe needs to run in admin mode if you want it to create the links for you like in the video.  But if you don't want to run the exe in admin mode, which tbh is the better practice, I provided a linkall.bat file which will handle the linking (absent the cool GUI) without admin privileges.

I have also provided the source code.  So as an alternative to running workbenchwizard.exe, you can run "WorkbenchWizard.Package.ps1" by right clicking on it and selecting, run with powershell.

Also I added a standalone renaming tool that will rename the batch files so that they work with mods that you create.
