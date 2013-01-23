clc, clear all ;
[y,sats, delays, fs, sigma_n] = if_signal_model(15, 1) ;

fd = 16368 ;
len = 2 ;
N = 1023 ;

% 1
c = cos(2*pi*fs(1)/fd*(0:(len*N)*16-1))' ;
c2 = cos(2*pi*(fs(2))/fd*(0:(len*N)*16-1))' ; 

%c = exp(2*j*pi*fs(1)/fd*(0:(len*N)*16-1))' ;
code1 = get_ca_code16(N, sats(1)) ;
code1 = repmat(code1, len, 1) ;
code2 = get_ca_code16(N, sats(2)) ;
code2 = repmat(code2, len, 1) ;

sig1 = code1 .* c ;
tx1 = sig1(delays(1):16368 + delays(1) - 1) ;
tx1 = tx1 .* code2(delays(2) : 16368 + delays(2) - 1) ;

% rx1
rxx110 = tx1' * tx1 / (length(tx1) - 1) ;
rxx111 = tx1' * circshift(tx1,1) / (length(tx1) - 1) ;

%rx1x2
sig11 = sig1(delays(1):16368 + delays(1) - 1) ; %sat 1

tx2 = code2 .* c2 ;         %sat 2
sig22 = tx2(delays(2):16368 + delays(2) - 1) ;

rx1x2 = sig11 .* sig22 ;

rx1x20 = rx1x2' * rx1x2 / (length(rx1x2) - 1) ;
rx1x21 = rx1x2' * circshift(rx1x2, 1) / (length(rx1x2) - 1) ;

rxx0 = rxx110 + 2*rx1x20 + sigma_n^2;
rxx1 = rxx111 + 2*rx1x21;

corr = [rxx0 rxx1 ; rxx1 rxx0] ;

[freq, Hjw] = lpcs(y(1:16368), code2, delays(2), corr) ;
%size(E)
%[p1,ca_shift] = max(Hjw .* conj(Hjw)) ;
%f = freq(ca_shift) ;
%fprintf('freq:%8.2f\n', freq*16368/2/pi ) ;

x = y(1:16368).*code2(delays(2):16368 + delays(2) - 1) ;
[X,omega] = pwelch(x, 1000) ;

plot(omega, conj(X) .* X), title('here'); pause ;

hold off, semilogy(omega,X.*conj(X), 'LineWidth',2);
hold on,semilogy(omega(1:numel(Hjw)),Hjw.*conj(Hjw),'r-','LineWidth',2), grid on
legend('signal spectrum', 'LPC')
hold off ;