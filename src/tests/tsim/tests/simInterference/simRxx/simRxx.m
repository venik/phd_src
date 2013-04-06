clc, clear all ;
% get access to model
curPath = pwd() ;
cd('..\\..\\..\\model') ;
modelPath = pwd() ;
cd( curPath );
addpath(modelPath) ;

% ADD CODE HERE
% get received signal
[x1,y1] = if_signal_model( 1,5 ) ;
[x,y,sats, delays, signoise] = if_signal_model( [1 2 3],10 ) ;
% remove code from first sattelite
code_off = delays(1) ;
code1 = get_ca_code16(1023*2+20,sats(1)) ;
x1 = x1.*code1(1+delays(1):16368*2+delays(1)) ;
x = y.*code1(1+code_off:16368*2+code_off) ;

tau_range = 0:1:30 ;
rx1 = zeros(size(tau_range)) ;
rxx = zeros(size(tau_range)) ;
n = 1 ;
for tau = tau_range
 
    rx1(n) = x1(1:16368)'*x1(1+tau:16368+tau)/16368 ;
    rxx(n) = x(1:16368)'*x(1+tau:16368+tau)/16368 ;

    n = n + 1 ;
    
end

figure(1) ;
hold off, plot(tau_range,rxx,'k-+','LineWidth',2) ;
hold on, plot(tau_range,rxx-rx1,'b-o','LineWidth',2) ;
hold on, plot(tau_range,rx1,'r-.','LineWidth',2) ;
grid on ;

legend('Rx2(\tau) = Rx1(\tau)+I(\tau)','I(\tau)','Ideal Rx1(\tau) for 1 source') ;

% remove model path
rmpath(modelPath) ;