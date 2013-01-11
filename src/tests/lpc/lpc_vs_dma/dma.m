clc, clear all ;

% reference -16:5
snr_db = 2.2 ;
tries = 1 ;

% hardcoded sat 1
code = get_ca_code16(1023, 1) ;
code = [code ; code] ;

N = 16368 ;
iteration = 1 ;
signal = zeros(N,1);

% we have only cos so devide to 2, and devide 2 bcoz half E
thr = N / 2 / 2 ;

% tau = 1/freq / 1/fs
tau = 43 ;

succ = zeros(numel(snr_db), 1) ;

for kk=1:numel(snr_db)
    fprintf('snr %02.2f:\n', snr_db(kk));
    
    for kkk=1:tries
        [y,sats, delays] = if_signal_model(snr_db(kk)) ;

        for k=1:iteration
            signal(1:N) = signal(1:N) + y((k-1)*N + 1: k*N) .* conj(y((k-1)*N + 1 + tau: k*N + tau));
        end % for k

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
        
        plot(acx) ;
        
        [energy, phase] = max(acx) ;
        if energy >= thr && ((phase > 1024 - 16) && (phase < 1024 + 16))
            succ(kk) = succ(kk) + 1 ;
            % fprintf('\t\t %02d success %02d\n', kkk, succ(kk)) ;
        end % if
        
        %max(acx)
        %plot(acx)
    end % kkk
    
    succ(kk) = succ(kk) / tries ;
    
end % kk

%save('result_dma.mat', 'snr_db', 'succ') ;
%plot(snr_db, succ, '-gx') ;

