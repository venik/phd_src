clc, clear all ;

init_rand( 1 ) ;

[y, sats, delays, signoise] = if_signal_model() ;

qy = quantize_max2769_3bit( y ) ;
code = get_ca_code16(1023,sats(1)) ;

[freq,E,Hjw_max] = lpcs(qy,code(1:16368), 0 ) ;

% get frequency
[p1,ca_shift] = max(E) ;
f = freq(ca_shift) ;
fprintf('ca_shift:%d\n', 16368-ca_shift+1 ) ;
fprintf('freq:%8.2f\n', f*16368/2/pi ) ;

%plot(real(poles.*conj(poles)))
%plot(E)

hold off ;
plot(Hjw_max.*conj(Hjw_max)) ;
%yc = y.*code(1+ca_shift-1:length(y)+ca_shift-1) ;
%YC = fft(yc) ;
%plot(YC.*conj(YC))
