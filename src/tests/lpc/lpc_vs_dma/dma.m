clc, clear all ;

snr_db = 10;

% hardcoded sat 1
code = get_ca_code16(1023, 1) ;
code = [code ; code] ;

N = 16368 ;
iteration = 1 ;
signal = zeros(N,1);

% tau = 1/freq / 1/fs
tau = 43 ;

for kk=1:numel(snr_db)
    [y,sats, delays] = if_signal_model(snr_db(kk)) ;
    
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

    % tt = signal(1:N) .* code(1024 : 16368 + 1023) ;
    % [b a] = butter(5, 0.0001) ;
    % signal = filter(b,a,signal) ;
    % plot(abs(fft(tt)))

    max(acx)
    plot(acx)
    
end


