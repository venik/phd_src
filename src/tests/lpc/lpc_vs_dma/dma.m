clc, clear all ;
[y,sats, delays] = if_signal_model() ;

code = get_ca_code16(1023,sats(1)) ;
code = [code ; code] ;

N = 16368 ;
tau = 33 ;
iteration = 2 ;
signal = zeros(N,1);

for k=1:iteration
    signal(1:N) = signal(1:N) + y((k-1)*N + 1: k*N) .* conj(y((k-1)*N + 1 + tau: k*N + tau));
end % for()

% get new code
ca_new_code = signal ./ iteration;
CA_NEW_CODE = fft(ca_new_code);

% generate local replica of the new code
ca_new_tmp = code(1:N) .* code(1+tau : N+tau);
CA_NEW_TMP = fft(ca_new_tmp);

% correlate
acx = ifft(CA_NEW_TMP .* conj(CA_NEW_CODE));
%acx = acx .* conj(acx);
acx = abs(acx) ;

max(sqrt(acx))

plot(acx)

%[freq,E,Hjw] = lpcs(y,code(1:16368),0) ;
%[p1,ca_shift] = max(E) ;
%f = freq(ca_shift) ;
%fprintf('freq:%8.2f\n', f*16368/2/pi ) ;