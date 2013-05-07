function removeLibrary(sLibName)
sFileName = mfilename('fullpath') ;
sPath = fileparts(sFileName) ;
rmpath( strcat(sPath,filesep,sLibName) ) ;
