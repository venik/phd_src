clc, clear all ;

[y,sats, delays, signoise] = if_signal_model() ;

code = get_ca_code16(1023+20,sats(1)) ;
[freq,E,Hjw_max, poles] = lpcs_deep(y,code(1+200:16368+200), signoise) ;

% get frequency
[p1,ca_shift] = max(E) ;
f = freq(ca_shift) ;
fprintf('freq:%8.2f\n', f*16368/2/pi ) ;

%plot(real(poles.*conj(poles)))
plot(E)
