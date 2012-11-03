clc, clear all ;
[y,sats, delays] = if_signal_model() ;
code = get_ca_code16(1023+20,sats(1)) ;
[freq,E,Hjw] = lpcs(y,code(1:16368),0) ;
[p1,ca_shift] = max(E) ;
f = freq(ca_shift) ;
fprintf('freq:%8.2f\n', f*16368/2/pi ) ;
code = code(1+delays(1):16368+delays(1)) ;
x = y.*code ;
%x = y ;
[X,omega] = pwelch(x,1024) ;
[Y] = pwelch(y,1024) ;
hold off, semilogy(omega,X.*conj(X), 'LineWidth',2);
hold on,semilogy(omega(1:numel(Hjw)),Hjw.*conj(Hjw),'r-','LineWidth',2), grid on
semilogy(omega,Y.*conj(Y),'k-','LineWidth',2)
xlabel('Frequency, rad/s','FontSize',14) ;
