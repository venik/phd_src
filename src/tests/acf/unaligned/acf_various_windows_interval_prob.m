clc, clear ;
% get access to model
curPath = pwd() ;
cd('..\\..\\tsim\\model') ;
modelPath = pwd() ;
cd( curPath ) ;
addpath(modelPath) ;

num_of_tests = 50000 ;
N = 16368 ;

f_int = 4.087e6 ;   % 4.092e6 - 5e3 Hz - lowest Doppler freq
f_doppler = 10e3 ;  % +-5 kHz max Doppler shift 

% A = 1, E = 0.5
A = 1 ; E = A^2 / 2 ;
SNR_dB = -30:1:5 ;

pll_line = repmat(18, 1, length(SNR_dB)) ;

num_of_windows = 4 ;

freq1 = zeros(length(SNR_dB), num_of_windows) ;
freq2 = zeros(length(SNR_dB), num_of_windows) ;
freq3 = zeros(length(SNR_dB), num_of_windows) ;

Prob18_1 = zeros(length(SNR_dB), num_of_windows) ;
Prob18_2 = zeros(length(SNR_dB), num_of_windows) ;
Prob18_3 = zeros(length(SNR_dB), num_of_windows) ;

Prob40_1 = zeros(length(SNR_dB), num_of_windows) ;
Prob40_2 = zeros(length(SNR_dB), num_of_windows) ;
Prob40_3 = zeros(length(SNR_dB), num_of_windows) ;

matlabpool open 2 ;

parfor jj=1:length(SNR_dB)
    
    fprintf('Actual: %.4f  dB\n', SNR_dB(jj)) ;
    
    ifsmp = get_ifsmp() ;
    ifsmp.snr_db = SNR_dB(jj) ;
    ifsmp.sats = [1] ;
    ifsmp.sigLengthMsec = 1 ;
       
    freq_1 = zeros(4, 1);
    freq_2 = zeros(4, 1);
    freq_3 = zeros(4, 1);
    
    Prob18_p1 = zeros(4, 1) ;
    Prob18_p2 = zeros(4, 1) ;
    Prob18_p3 = zeros(4, 1) ;
    
    Prob40_p1 = zeros(4, 1) ;
    Prob40_p2 = zeros(4, 1) ;
    Prob40_p3 = zeros(4, 1) ;
    
    for k=1:num_of_tests

        freq = f_int + randi(f_doppler, 1, 4) ;
        fs = freq(1) ;
        
        E_intf = randi(E * 1000, 1, 4) / 1000 ;
        
        ifsmp.vars = [E E_intf(2) E_intf(3) E_intf(4)] ;            % FIXME - can't be the same
        ifsmp.fs = [fs  freq(2)  freq(3)  freq(4)] ;
        ifsmp.fd = 16.368e6 ;
        ifsmp.delays = [100, 150, 230, 10] ;
    
        [~, y ,sats, delays, signoise] = get_gps_if_signal( ifsmp ) ;
        code = get_gps_ca_code(ifsmp.sats(1), ifsmp.fd, length(y) + delays(1)) ;
        x = y.*code(1+delays(1):length(y)+delays(1)) ;
        
        %x = x(1:ceil(N)) ;
        
        %%%%%%%%%%%%%%%%%%%
        % signal + noise
        x_hamming = x.*hamming(length(x)) ;
        x_blackman = x.*blackman(length(x)) ;
        x_hann = x.*hann(length(x), 'periodic') ;

        % interpolation
        fourier_length = 8 * N ;
        
        X = fft(x, fourier_length) ;
        X_hamming = fft(x_hamming, fourier_length) ;
        X_blackman = fft(x_blackman, fourier_length) ;
        X_hann = fft(x_hann, fourier_length) ;
    
        XX = X.*conj(X) ;
        XX_hamming = X_hamming .* conj(X_hamming) ;
        XX_blackman = X_blackman .* conj(X_blackman) ;
        XX_hann = X_hann.*conj(X_hann) ;

        %%%%%%%%%%%%
        % 1        
        c = ar_model(ifft(XX) / N) ;
        hamming_c = ar_model(ifft(XX_hamming)/N) ;
        blackman_c = ar_model(ifft(XX_blackman)/N) ;
        hann_c = ar_model(ifft(XX_hann)/N) ;

        [pole, omega0, Hjw0] = get_ar_pole(c) ;
        freq_1(1) = freq_1(1) + ((omega0*ifsmp.fd/2/pi - fs))^2 ;
        freq_error = abs(omega0*ifsmp.fd/2/pi - fs) ;
        if freq_error<18
            Prob18_p1(1) = Prob18_p1(1) + 1 ;
        end
        if freq_error<40
            Prob40_p1(1) = Prob40_p1(1) + 1 ;
        end

        [hamming_pole, hamming_omega0, hamming_Hjw0] = get_ar_pole(hamming_c) ;
        freq_1(2) = freq_1(2) + ((hamming_omega0*ifsmp.fd/2/pi - fs))^2 ;
        freq_error = abs(hamming_omega0*ifsmp.fd/2/pi - fs) ;
        if freq_error<18
            Prob18_p1(2) = Prob18_p1(2) + 1 ;
        end
        if freq_error<40
            Prob40_p1(2) = Prob40_p1(2) + 1 ;
        end
        
        [hann_pole, hann_omega0, hann_Hjw0] = get_ar_pole(hann_c) ;
        freq_1(3) = freq_1(3) + ((hann_omega0*ifsmp.fd/2/pi - fs))^2 ;
        freq_error = abs(hann_omega0*ifsmp.fd/2/pi - fs) ;
        if freq_error<18
            Prob18_p1(3) = Prob18_p1(3) + 1 ;
        end
        if freq_error<40
            Prob40_p1(3) = Prob40_p1(3) + 1 ;
        end

        [blackman_pole, blackman_omega0, blackman_Hjw0] = get_ar_pole(blackman_c) ;
        freq_1(4) = freq_1(4) + ((blackman_omega0*ifsmp.fd/2/pi - fs))^2 ;
        freq_error = abs(blackman_omega0*ifsmp.fd/2/pi - fs) ;
        if freq_error<18
            Prob18_p1(4) = Prob18_p1(4) + 1 ;
        end
        if freq_error<40
            Prob40_p1(4) = Prob40_p1(4) + 1 ;
        end

        %%%%%%%%%%%%
        % 2 
        c = ar_model(ifft(XX .^ 4) / N) ;
        hamming_c = ar_model(ifft(XX_hamming .^ 4)/N) ;
        blackman_c = ar_model(ifft(XX_blackman .^ 4)/N) ;
        hann_c = ar_model(ifft(XX_hann .^ 4) / N) ;

        [pole, omega0, Hjw0] = get_ar_pole(c) ;
        freq_2(1) = freq_2(1) + ((omega0*ifsmp.fd/2/pi - fs))^2 ;
        freq_error = abs(omega0*ifsmp.fd/2/pi - fs) ;
        if freq_error<18
            Prob18_p2(1) = Prob18_p2(1) + 1 ;
        end
        if freq_error<40
            Prob40_p2(1) = Prob40_p2(1) + 1 ;
        end

        [hamming_pole, hamming_omega0, hamming_Hjw0] = get_ar_pole(hamming_c) ;
        freq_2(2) = freq_2(2) + ((hamming_omega0*ifsmp.fd/2/pi - fs))^2 ;
        freq_error = abs(hamming_omega0*ifsmp.fd/2/pi - fs) ;
        if freq_error<18
            Prob18_p2(2) = Prob18_p2(2) + 1 ;
        end
        if freq_error<40
            Prob40_p2(2) = Prob40_p2(2) + 1 ;
        end
        
        [hann_pole, hann_omega0, hann_Hjw0] = get_ar_pole(hann_c) ;
        freq_2(3) = freq_2(3) + ((hann_omega0*ifsmp.fd/2/pi - fs))^2 ;
        freq_error = abs(hann_omega0*ifsmp.fd/2/pi - fs) ;
        if freq_error<18
            Prob18_p2(3) = Prob18_p2(3) + 1 ;
        end
        if freq_error<40
            Prob40_p2(3) = Prob40_p2(3) + 1 ;
        end

        [blackman_pole, blackman_omega0, blackman_Hjw0] = get_ar_pole(blackman_c) ;
        freq_2(4) = freq_2(4) + ((blackman_omega0*ifsmp.fd/2/pi - fs))^2 ;
        freq_error = abs(blackman_omega0*ifsmp.fd/2/pi - fs) ;
        if freq_error<18
            Prob18_p2(4) = Prob18_p2(4) + 1 ;
        end
        if freq_error<40
            Prob40_p2(4) = Prob40_p2(4) + 1 ;
        end

        %%%%%%%%%%%%
        % 3 
        power_3 = 8 ;
        c = ar_model(ifft(XX .^ power_3) / N) ;
        hamming_c = ar_model(ifft(XX_hamming .^ power_3) / N) ;
        blackman_c = ar_model(ifft(XX_blackman .^ power_3) / N) ;
        hann_c = ar_model(ifft(XX_hann .^ power_3) / N) ;

        [pole, omega0, Hjw0] = get_ar_pole(c) ;
        freq_3(1) = freq_3(1) + (omega0*ifsmp.fd/2/pi - fs)^2 ;
        freq_error = abs(omega0*ifsmp.fd/2/pi - fs) ;
        if freq_error<18
            Prob18_p3(1) = Prob18_p3(1) + 1 ;
        end
        if freq_error<40
            Prob40_p3(1) = Prob40_p3(1) + 1 ;
        end

        [hamming_pole, hamming_omega0, hamming_Hjw0] = get_ar_pole(hamming_c) ;
        freq_3(2) = freq_3(2) + (hamming_omega0*ifsmp.fd/2/pi - fs)^2 ;
        freq_error = abs(hamming_omega0*ifsmp.fd/2/pi - fs) ;
        if freq_error<18
            Prob18_p3(2) = Prob18_p3(2) + 1 ;
        end
        if freq_error<40
            Prob40_p3(2) = Prob40_p3(2) + 1 ;
        end
        
        [hann_pole, hann_omega0, hann_Hjw0] = get_ar_pole(hann_c) ;
        freq_3(3) = freq_3(3) + (hann_omega0*ifsmp.fd/2/pi - fs)^2 ;
        freq_error = abs(hann_omega0*ifsmp.fd/2/pi - fs) ;
        if freq_error<18
            Prob18_p3(3) = Prob18_p3(3) + 1 ;
        end
        if freq_error<40
            Prob40_p3(3) = Prob40_p3(3) + 1 ;
        end

        [blackman_pole, blackman_omega0, blackman_Hjw0] = get_ar_pole(blackman_c) ;
        freq_3(4) = freq_3(4) + (blackman_omega0*ifsmp.fd/2/pi - fs)^2 ;        
        freq_error = abs(blackman_omega0*ifsmp.fd/2/pi - fs) ;
        if freq_error<18
            Prob18_p3(4) = Prob18_p3(4) + 1 ;
        end
        if freq_error<40
            Prob40_p3(4) = Prob40_p3(4) + 1 ;
        end

    end ;
    
    freq1(jj,:) = sqrt(freq_1(:) / num_of_tests) ;
    freq2(jj,:) = sqrt(freq_2(:) / num_of_tests) ;
    freq3(jj,:) = sqrt(freq_3(:) / num_of_tests)  ;
    
    Prob18_1(jj,:) = Prob18_p1(:)/num_of_tests ;
    Prob18_2(jj,:) = Prob18_p2(:)/num_of_tests ;
    Prob18_3(jj,:) = Prob18_p3(:)/num_of_tests ;

    Prob40_1(jj,:) = Prob40_p1(:)/num_of_tests ;
    Prob40_2(jj,:) = Prob40_p2(:)/num_of_tests ;
    Prob40_3(jj,:) = Prob40_p3(:)/num_of_tests ;
    
 end ; % SNR

 matlabpool close ;
 
SNR_dB_acf = SNR_dB ;
freq_plot = freq3 ;    

save('acf_various_windows.mat', 'SNR_dB', 'freq1', 'freq2', 'freq3');
save('acf_various_windows_prob_8N.mat', 'SNR_dB', ...
    'Prob18_1', 'Prob18_2', 'Prob18_3','Prob40_1', 'Prob40_2', 'Prob40_3') ;

%     semilogy(SNR_dB, pll_line, '-m*', ...
%             SNR_dB, freq_plot(:,1), '-go', SNR_dB, freq_plot(:,2), '-b*', ...
%             SNR_dB, freq_plot(:,3), '-r+', SNR_dB, freq_plot(:,4), '-y+') ;        
hold off, plot(SNR_dB, Prob40_1(:,1)) ;
hold on, plot(SNR_dB, Prob40_1(:,2)) ;
hold on, plot(SNR_dB, Prob40_1(:,3)) ;
hold on, plot(SNR_dB, Prob40_1(:,4)) ;
        title('SKO') ,
        legend('PLL line', 'Rect', 'Hamming', 'Blackman', 'Hann') ;
        phd_figure_style(gcf) ;

% remove model path
rmpath(modelPath) ;