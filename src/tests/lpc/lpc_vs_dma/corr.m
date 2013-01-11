clc, clear all ;

N = 16368 ;
fd = 16368 ;

% reference -16:5
snr_db = -30:1:6 ;
tries = 1000 ;

% hardcoded sat 1
code = get_ca_code16(1023, 1) ;

% c = exp(2*j*pi*3800/fd*(0:N-1))' ;
c = cos(2*pi*3800/fd*(0:N-1))' ;
CA = fft(code(1:N) .* c);

% we have only cos so devide to 2, and devide 2 bcoz half E
thr = N / 2 / 2 ;

succ = zeros(numel(snr_db), 1) ;

for kk=1:numel(snr_db)
    fprintf('snr %02.2f:\n', snr_db(kk));
    
    for kkk=1:tries
        [y,sats, delays] = if_signal_model(snr_db(kk)) ;
        Y = fft(y(1:N));

        % correlate
        acx = ifft(CA .* conj(Y));
        %acx = acx .* conj(acx);
        acx = abs(acx) ;

        [energy, phase] = max(acx) ;
        if energy >= thr && ((phase > 1024 - 16) && (phase < 1024 + 16))
            succ(kk) = succ(kk) + 1 ;
            % fprintf('\t\t %02d success %02d\n', kkk, succ(kk)) ;
        end % if
        
        %max(acx)
        plot(acx)
    end % kkk
    
    succ(kk) = succ(kk) / tries ;

end % kk

save('result_corr.mat', 'snr_db', 'succ') ;
plot(snr_db, succ) ;