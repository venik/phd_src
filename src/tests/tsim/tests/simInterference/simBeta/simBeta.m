clc, clear all ;
% get access to model
curPath = pwd() ;
cd('..\\..\\..\\model') ;
modelPath = pwd() ;
cd( curPath );
addpath(modelPath) ;

% ADD CODE HERE

freqList = zeros(100,1) ;
for testNum=1:100
    % get received signal
    init_rand(testNum) ;
    % get default parameters
    ifsmp = get_ifsmp() ;
    % tune model
    ifsmp.snr_db = -5 ;
    ifsmp.fs(1) = 4000 ;
    ifsmp.sats = [1,2,3,4,5,6] ;
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
    signalEnergy = sum(IdealSignal.*conj(IdealSignal))/numel(IdealSignal) ;
    noiseEnergy = sum((x-IdealSignal).*conj(x-IdealSignal))/numel(IdealSignal) ;
    Snrdb = 10*log10(signalEnergy/noiseEnergy) ;
    disp(ifsmp) ;
    fprintf('actual SNR: %6.2fdB\n', Snrdb ) ;

    rxxRange = 20:140 ;
    rxx = get_rxx(x(1:16368*2), rxxRange ) ;
    hold off,plot(rxxRange, rxx ,'b-^') ;
     hold on,plot(rxxRange, ifsmp.vars(1)*cos(2*pi*ifsmp.fs(1)/ifsmp.fd*rxxRange),'r-') ;
     grid on ;

    r0 = sum(rxx.*conj(rxx))/numel(rxx) ;
    r1 = sum(rxx(1:end-1).*conj(rxx(2:end)))/(numel(rxx)-1) ;
    r2 = sum(rxx(1:end-2).*conj(rxx(3:end)))/(numel(rxx)-2) ;

    b = ar_model([r0; r1; r2]) ;
    [poles, omega0, Hjw0] = get_ar_pole(b) ;

    fprintf('Freq: %6.2f, Hjw0: %5.2fdB\n',omega0/2/pi*ifsmp.fd, 10*log10(Hjw0*conj(Hjw0))) ;
    freqList(testNum) = omega0/2/pi*ifsmp.fd ;

end
clf; plot(freqList), hold on, plot([1 numel(freqList)], [ifsmp.fs(1) ifsmp.fs(1)],'k-.')
% remove model path
rmpath(modelPath) ;
