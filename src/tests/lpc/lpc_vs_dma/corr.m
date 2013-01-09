clc, clear all ;

N = 16368 ;
fd = 16368 ;

snr_db = 30 ;
acx = zeros(numel(snr_db), 1) ;

% hardcoded sat 1
code = get_ca_code16(1023, 1) ;

% c = exp(2*j*pi*3800/fd*(0:N-1))' ;
c = cos(2*pi*3800/fd*(0:N-1))' ;
CA = fft(code(1:N) .* c);

for kk=1:numel(snr_db)
    [y,sats, delays] = if_signal_model(snr_db(kk)) ;
    Y = fft(y(1:N));

    % correlate
    acx = ifft(CA .* conj(Y));
    %acx = acx .* conj(acx);
    acx = abs(acx) ;

    max(acx)

    plot(acx)
end