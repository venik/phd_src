clc, clear all ;
% get access to model
curPath = pwd() ;
cd('..\\..\\..\\model') ;
modelPath = pwd() ;
cd( curPath );
addpath(modelPath) ;

% ADD CODE HERE
totalNumTests = 1000 ;
freqList = zeros(totalNumTests,1) ;
signalEnergy = 0 ;
noiseEnergy = 0 ;
% get default parameters
ifsmp = get_ifsmp() ;
ifsmp.snr_db = -16 ;
ifsmp.sats = [1,2,3] ;
ifsmp.fs(1) = 4150 ;
Snrdb = ifsmp.snr_db ;
for testNum=1:totalNumTests
    % get received signal
    init_rand(testNum) ;
    % tune model
    code_error = 0 ;
    [~,y,sats, delays, signoise] = get_if_signal( ifsmp ) ;
    code_off = delays(1) + code_error ;
    code1 = get_ca_code16(1023*2+20,sats(1)) ;
    x = y.*code1(1+code_off:16368*2+code_off) ;

    % get ideal signal
    IdealIfsmp = ifsmp ;
    IdealIfsmp.sats = 1 ;
    IdealIfsmp.snr_db = 110 ;
    IdealSignal = get_if_signal( IdealIfsmp ) ;
    IdealSignal = IdealSignal.*code1(1+code_off:16368*2+code_off) ;

    % get snr
    if testNum<5
        signalEnergy = signalEnergy + sum(IdealSignal.*conj(IdealSignal))/numel(IdealSignal) ;
        noiseEnergy = noiseEnergy + sum((x-IdealSignal).*conj(x-IdealSignal))/numel(IdealSignal) ;
    end
    if testNum==5
        Snrdb = 10*log10(signalEnergy/noiseEnergy) ;
        disp(ifsmp) ;
        fprintf('actual SNR: %6.2fdB\n', Snrdb ) ;
    end

    msSamples = 16368 ;
    X = fft(x(1:msSamples)) ;
    x1 = ifft(X.*conj(X)).*hamming(msSamples) ;
    X1 = fft(x1) ;
    x2 = ifft(X1.*conj(X1)).*hamming(msSamples) ;
    X2 = fft(x2) ;
    x3 = ifft(X2.*conj(X2)) ;
    
    r0 = x3(1) ;
    r1 = x3(2) ;
    r2 = x3(3) ;

    b = ar_model([r0; r1; r2]) ;
    [poles, omega0, Hjw0] = get_ar_pole(b) ;
    %fprintf('Freq: %6.2f, Hjw0: %5.2fdB\n',omega0/2/pi*ifsmp.fd, 10*log10(Hjw0*conj(Hjw0))) ;
    freqList(testNum) = omega0/2/pi*ifsmp.fd ;
end
clf; plot(freqList), hold on, plot([1 numel(freqList)], [ifsmp.fs(1) ifsmp.fs(1)],'k-.')
strSats = sprintf('%d,',ifsmp.sats) ;
title(sprintf('SNR: %5.2fdB, Satellites: %s', Snrdb, strSats),'FontSize',14) ;
set(gca,'FontSize',14);

% remove model path
rmpath(modelPath) ;