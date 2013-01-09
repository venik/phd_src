clc, clear all ;
[y,sats, delays] = if_signal_model() ;

code = get_ca_code16(1023, sats(1)) ;
code = [code ; code] ;

N = 16368 ;
fd = 16368 ;

% c = exp(2*j*pi*3800/fd*(0:N-1))' ;
c = cos(2*pi*3800/fd*(0:N-1))' ;

CA = fft(code(1:N) .* c);
Y = fft(y(1:N));

% correlate
acx = ifft(CA .* conj(Y));
%acx = acx .* conj(acx);
acx = abs(acx) ;

max(acx)

plot(acx)

%[freq,E,Hjw] = lpcs(y,code(1:16368),0) ;
%[p1,ca_shift] = max(E) ;
%f = freq(ca_shift) ;
%fprintf('freq:%8.2f\n', f*16368/2/pi ) ;