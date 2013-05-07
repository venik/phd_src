function addLibrary(sLibName)
sFileName = mfilename('fullpath') ;
sPath = fileparts(sFileName) ;
addpath( strcat(sPath,filesep,sLibName) ) ;
