clc, clear all ;
% get access to model
curPath = pwd() ;
cd('..\\..\\..\\model') ;
modelPath = pwd() ;
cd( curPath );
addpath(modelPath) ;

% ADD CODE HERE
totalNumTests = 500 ;
freqList = zeros(totalNumTests,1) ;
for testNum=1:totalNumTests
    % get received signal
    init_rand(testNum) ;
    % get default parameters
    ifsmp = get_ifsmp() ;
    % tune model
    ifsmp.snr_db = -20 ;
    ifsmp.fs(1) = 4150 ;
    ifsmp.sats = 1 ;
    code_error = 0 ;
    [~,y,sats, delays, signoise] = get_if_signal( ifsmp ) ;
    code_off = delays(1) + code_error ;
    code1 = get_ca_code16(1023*2+20,sats(1)) ;
    x = y.*code1(1+code_off:16368*2+code_off) ;

    msSamples = 16368 ;
    X = fft(x(1:msSamples)) ;
    x2 = ifft(X.*conj(X).*X.*conj(X).*X.*conj(X).*X.*conj(X)) ;
    r0 = x2(1) ;
    r1 = x2(2) ;
    r2 = x2(3) ;

    b = ar_model([r0; r1; r2]) ;
    [poles, omega0, Hjw0] = get_ar_pole(b) ;
    %fprintf('Freq: %6.2f, Hjw0: %5.2fdB\n',omega0/2/pi*ifsmp.fd, 10*log10(Hjw0*conj(Hjw0))) ;
    freqList(testNum) = omega0/2/pi*ifsmp.fd ;
end
clf; plot(freqList), hold on, plot([1 numel(freqList)], [ifsmp.fs(1) ifsmp.fs(1)],'k-.')
strSats = sprintf('%d',ifsmp.sats) ;
title(sprintf('SNR: %5.2fdB, Satellites: %s', ifsmp.snr_db, strSats),'FontSize',14) ;
set(gca,'FontSize',14);

% remove model path
rmpath(modelPath) ;