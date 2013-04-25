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
% get default parameters
ifsmp = get_ifsmp() ;
% tune model
ifsmp.snr_db = 0 ;
ifsmp.fs(1) = 3800 ;
ifsmp.sats = [1,2,3,4] ;
code_error = 0 ;
[~,y,sats, delays, signoise] = get_if_signal( ifsmp ) ;
code_off = delays(1) + code_error ;
code1 = get_ca_code16(1023*2+20,sats(1)) ;
x = y.*code1(1+code_off:16368*2+code_off) ;

VisualizeRxx = 1 ;
if VisualizeRxx
    rxxRange = 0:30 ;
    hold off,plot(rxxRange, get_rxx(x(1:16368*2), rxxRange ),'b-^') ;
     hold on,plot(rxxRange, ifsmp.vars(1)*cos(2*pi*ifsmp.fs(1)/ifsmp.fd*rxxRange),'r-') ;
     grid on ;
     return ;
end

rxx = get_rxx(x(1:16368*2), [0 1 2] ) ;
r4 = get_rxx(x(1:16368*2), 22 ) ;

I0 = 0 ;
I1 = 0 ;
I2 = 0 ;
gamma = 0.5 ;
Interf = zeros(3,1) ;

IdealI = [rxx(1)-ifsmp.vars(1), rxx(2)-ifsmp.vars(1)*cos(2*pi*ifsmp.fs(1)/ifsmp.fd), rxx(3)-ifsmp.vars(1)*cos(2*pi*ifsmp.fs(1)*2/ifsmp.fd)] ;
fprintf('Ideal I0=%8.4f\n', IdealI(1)) ;
fprintf('Ideal I1=%8.4f\n', IdealI(2)) ;
fprintf('Ideal I2=%8.4f\n', IdealI(3)) ;
fprintf('Ideal r4=%8.4f\n', ifsmp.vars(1)*cos(2*pi*22*ifsmp.fs(1)/ifsmp.fd)) ;
for turboIter=1:5
    % get frequency using AR
    b = ar_model(rxx(:)-Interf) ;
    [poles, omega0, Hjw0] = get_ar_pole(b) ;
    
    % get I0, I1, I2
    %initialFreq = omega0/2/pi*ifsmp.fd ;
    %[preciseFreq, gamma] = newton_solver2(x(1:16368*2), initialFreq, gamma, ifsmp.fd, 12, 13, 3 ) ;
    %preciseFreq = 3800; gamma = 1 ;
    %fprintf('preciseFreq: %6.2f\n', preciseFreq) ;
    %omega0 = 2*pi*preciseFreq/ifsmp.fd ;
    
    gamma = r4/cos(omega0*22) ;
    I0 = rxx(1)-gamma ;
    I1 = rxx(2)-gamma*cos(omega0) ;
    I2 = rxx(3)-gamma*cos(2*omega0) ;
    
    fprintf('Gamma:%6.2f, f=%6.2f, Hjw0=%8.5f, \n', gamma, omega0/2/pi*ifsmp.fd, Hjw0*conj(Hjw0)) ;
    fprintf('%8.4f %8.4f %8.4f\n', Interf(1),Interf(2),Interf(3) ) ;
    
    % modify rxx
    Interf = Interf + ([I0; I1; I2]-Interf)*0.1 ; 
end

% remove model path
rmpath(modelPath) ;