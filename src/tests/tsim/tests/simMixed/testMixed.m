clc, clear ;
% get access to model
curPath = pwd() ;
cd('..\\..\\model') ;
modelPath = pwd() ;
cd( curPath ) ;
addpath(modelPath) ;

% get access to libraries
addLibrary('Acos') ;
addLibrary(strcat('Acos',filesep,'include')) ;

% get default parameters
init_rand(1) ;
ifsmp = get_ifsmp() ;
ifsmp.snr_db = 0 ;
ifsmp.sats = [1] ;
ifsmp.vars = [1.0 1.0 1.0 1.0 ] ;
ifsmp.fs = [4090120 4094545 4093300  4092400] ;
ifsmp.fd = 16368000 ;
ifsmp.delays = [100,150,230,10] ;
ifsmp.sigLengthMsec = 12 ;

[~, longSignal ,sats, delays, signoise] = get_gps_if_signal( ifsmp ) ;
settings = initSettings() ;
settings.IF                 = 4092000  ;   % [Hz]
settings.samplingFreq       = ifsmp.fd ;   % [Hz]
settings.codeFreqBasis      = 1023000  ;   % [Hz]
acqResults = acqusition(longSignal(:).', settings) ;

fprintf('AR frequencies:\n') ;
for n=1:numel(acqResults.carrFreq)
    fprintf('%8d ', round(acqResults.carrFreq(n))) ;
end
fprintf('\n') ;
fprintf('Peak metrics:\n') ;
for n=1:numel(acqResults.carrFreq)
    fprintf('%8f ', acqResults.peakMetric(n)) ;
end
fprintf('\n') ;

removeLibrary(strcat('Acos',filesep,'include')) ;
removeLibrary('Acos') ;

% remove model path
rmpath(modelPath) ;