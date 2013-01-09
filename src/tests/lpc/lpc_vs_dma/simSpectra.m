clc, clear all ;
[y,sats, delays] = if_signal_model() ;
code = get_ca_code16(1023,sats(1)) ;
[freq,E,Hjw] = lpcs(y(1:16368), code(1:16368),0) ;
[p1,ca_shift] = max(E) ;
f = freq(ca_shift) ;
fprintf('freq:%8.2f\n', f*16368/2/pi ) ;

code = [code ; code] ;
code = code(1+delays(1):16368+delays(1)) ;
x = y(1:16368).*code(1:16368) ;
%x = y ;
[X,omega] = pwelch(x,1024) ;
[Y] = pwelch(y,1024) ;

% hold off, semilogy(omega,X.*conj(X), 'LineWidth',2);
% hold on,semilogy(omega(1:numel(Hjw)),Hjw.*conj(Hjw),'r-','LineWidth',2), grid on
% semilogy(omega,Y.*conj(Y),'k-','LineWidth',2)
% xlabel('Частота, рад/с','FontSize',14) ;
% legend('Спектр сигнала', 'АР оценка спектра сигнала', 'Спектр сигнала до снятия ПСП'),
% xlim([omega(1), omega(end)])