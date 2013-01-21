clc, clear all ;
[y,sats, delays, fs, sigma_n] = if_signal_model(15, 1) ;

fd = 16368 ;
len = 2 ;
N = 1023 ;

% 1
c = cos(2*pi*fs(1)/fd*(0:(len*N)*16-1))' ;
%c = exp(2*j*pi*fs(1)/fd*(0:(len*N)*16-1))' ;
code1 = get_ca_code16(N, sats(1)) ;
code1 = repmat(code1, len, 1) ;
code2 = get_ca_code16(N, sats(2)) ;
code2 = repmat(code2, len, 1) ;

sig1 = code1 .* c ;
tx1 = sig1(delays(1):16368 + delays(1) - 1) ;
tx1 = tx1 .* code2(delays(2) : 16368 + delays(2) - 1) ;

% rx1
rxx110 = tx1' * tx1 ;
rxx111 = tx1' * circshift(tx1,1) ;

sig11 = sig1(delays(1):16368 + delays(1) - 1) ;

c2 = cos(2*pi*(fs(2)+900)/fd*(0:(len*N)*16-1))' ;
tx2 = code2 .* c2 ;
sig22 = tx2(delays(2):16368 + delays(2) - 1) ;

rx1x2 = sig11 .* sig22 ;

rx1x20 = rx1x2' * rx1x2;
rx1x21 = rx1x2' * circshift(rx1x2, 1) ;

rxx0 = rxx110 + rx1x20 + sigma_n^2;
rxx1 = rxx111 + rx1x21;

corr = [rxx0 rxx1 ; rxx1 rxx0] ;

[freq,E,Hjw] = lpcs(y(1:16368), code2(1:16368), delays(2), corr) ;

[p1,ca_shift] = max(E) ;
f = freq(ca_shift) ;
fprintf('freq:%8.2f\n', f*16368/2/pi ) ;

% code = [code ; code] ;
% code = code(1+delays(1):16368+delays(1)) ;
% x = y(1:16368).*code(1:16368) ;
% %x = y ;
% [X,omega] = pwelch(x,1024) ;
% [Y] = pwelch(y,1024) ;
% 
%  hold off, semilogy(omega,X.*conj(X), 'LineWidth',2);
%  hold on,semilogy(omega(1:numel(Hjw)),Hjw.*conj(Hjw),'r-','LineWidth',2), grid on
%  semilogy(omega,Y.*conj(Y),'k-','LineWidth',2)
%  xlabel('Частота, рад/с','FontSize',14) ;
%  legend('Спектр сигнала', 'АР оценка спектра сигнала', 'Спектр сигнала до снятия ПСП'),
%  xlim([omega(1), omega(end)])