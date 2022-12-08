echo linking P:\scripts to dayz
mklink /J  "WB_DAYZFOLDER\scripts\" "P:\scripts\"

echo linking source code
mklink /J "P:\FirstMod\" "WB_SOURCEFOLDER" 
mklink /J "WB_DAYZFOLDER\FirstMod\" "WB_SOURCEFOLDER" 

echo linking packed pbos
mklink /J "P:\@FirstMod\" "WB_DAYZFOLDER\@FirstMod\" 


