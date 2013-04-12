clc, clear all ;
% get access to model
curPath = pwd() ;
cd('..\\..\\..\\model') ;
modelPath = pwd() ;
cd( curPath );
addpath(modelPath) ;

% ADD CODE HERE
% get received signal
init_rand(1) ;
N = 100 ;
signalFreq = zeros(N,1) ;
preciseFreq = zeros(N,1) ;
precisePower = zeros(N,1) ;
code_error = 0 ;
ifsmp = get_ifsmp() ;
ifsmp.snr_db = -5 ;
for n= 1:N
    signalFreq(n) = 3750+rand()*500 ;
    ifsmp.fs(1) = signalFreq(n) ;
    [~,y,sats, delays, signoise] = get_if_signal( ifsmp ) ;
    % remove code from first sattelite
    code_off = delays(1) + code_error ;
    code1 = get_ca_code16(1023*2+20,sats(1)) ;
    x = y.*code1(1+code_off:16368*2+code_off) ;

    % get precise frequency and power
    initialFreq = 4000.0 ;
    [preciseFreq(n), precisePower(n)] = newton2_staged_detector(x, initialFreq, ifsmp.fd ) ;
    
    %fprintf('Frequency: %5.2f\n', preciseFreq ) ;
    %fprintf('Power:     %5.2f\n', precisePower ) ;
end

%hold off, plot(signalFreq,'Color',[0.7 0.7 0.7]) ;
hold off, plot(preciseFreq-signalFreq,'Color',[0.6 0 0]), grid on ;
%hold off, plot(precisePower-ifsmp.vars(1),'Color',[0.6 0 0]), grid on ;

% remove model path
rmpath(modelPath) ;