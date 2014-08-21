function [ settings ] = initSettings()

settings.IF = 4.092E6; % Hz
settings.L1Freq = 1574.42E6; % Hz
settings.samplingFreq = 5.456E6; % Hz
settings.codeFreqBase = 1.023E6; % Hz
settings.codeLength = 1023;
% settings.fileName = '101112_0928GMT_primo_fs5456_fif4092.dat';
settings.fileName = '101112_0928GMT_primo_fs5456_fif4092.dat';

settings.startTime = 0;
settings.processTime = 1000; % ms

% Acquisition
settings.fineFreq = true;
settings.ffAlg = 'tsui';

settings.acqPRNList = 31;
settings.acqSearchBand = 10E3; % Hz
settings.acqSearchStep = 50; % Hz
settings.acqThreshold = 3.7E5; %2.75E7; %

% Tracking
settings.DLL_K = 1;
settings.DLL_LBW = 5; %10; %25; %
settings.DLL_zeta = 0.7;

settings.PLL_K = 1;
settings.PLL_LBW = 20; %400; %25; %
settings.PLL_zeta = 0.7;

settings.corrSpacing = 0.25;

end

