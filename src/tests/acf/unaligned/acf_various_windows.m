clc, clear, clf ;
% get access to model
curPath = pwd() ;
cd('..\\..\\tsim\\model') ;
modelPath = pwd() ;
cd( curPath ) ;
addpath(modelPath) ;

num_of_tests = 20 ;
N = 16368 ;

f_int = 4.087e6 ;   % 4.092e6 - 5e3 Hz - lowest Doppler freq
f_doppler = 11e3 ;  % +-5 kHz max Doppler shift 

% A = 1, E = 0.5
A = 1 ; E = A^2 / 2 ;
SNR_dB = -30:1:5 ;

pll_line = repmat(18, 1, length(SNR_dB)) ;

num_of_windows = 4 ;

freq1 = zeros(length(SNR_dB), num_of_windows) ;
freq2 = zeros(length(SNR_dB), num_of_windows) ;
freq3 = zeros(length(SNR_dB), num_of_windows) ;

for jj=1:length(SNR_dB)
    
    fprintf('Actual: %.4f  dB\n', SNR_dB(jj)) ;
    
    ifsmp = get_ifsmp() ;
    ifsmp.snr_db = SNR_dB(jj) ;
    ifsmp.sats = [1 2 3 4] ;
    ifsmp.sigLengthMsec = 1 ;

    for k=1:num_of_tests

        freq = f_int + randi(f_doppler, 1, 4) ;
        fs = freq(1) ;
        
        ifsmp.vars = [E E E E] ;            % FIXME - can't be the same
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
        fourier_length = 4 * N ;
        
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
        freq1(jj, 1) = freq1(jj, 1) + round((omega0*ifsmp.fd/2/pi - fs))^2 ;

        [hamming_pole, hamming_omega0, hamming_Hjw0] = get_ar_pole(hamming_c) ;
        freq1(jj, 2) = freq1(jj, 2) + round((hamming_omega0*ifsmp.fd/2/pi - fs))^2 ;
        
        [hann_pole, hann_omega0, hann_Hjw0] = get_ar_pole(hann_c) ;
        freq1(jj, 3) = freq1(jj, 3) + round((hann_omega0*ifsmp.fd/2/pi - fs))^2 ;

        [blackman_pole, blackman_omega0, blackman_Hjw0] = get_ar_pole(blackman_c) ;
        freq1(jj, 4) = freq1(jj, 4) + round((blackman_omega0*ifsmp.fd/2/pi - fs))^2 ;

        %%%%%%%%%%%%
        % 2 
        c = ar_model(ifft(XX .^ 4) / N) ;
        hamming_c = ar_model(ifft(XX_hamming .^ 4)/N) ;
        blackman_c = ar_model(ifft(XX_blackman .^ 4)/N) ;
        hann_c = ar_model(ifft(XX_hann .^ 4) / N) ;

        [pole, omega0, Hjw0] = get_ar_pole(c) ;
        freq2(jj, 1) = freq2(jj, 1) + round((omega0*ifsmp.fd/2/pi - fs))^2 ;

        [hamming_pole, hamming_omega0, hamming_Hjw0] = get_ar_pole(hamming_c) ;
        freq2(jj, 2) = freq2(jj, 2) + round((hamming_omega0*ifsmp.fd/2/pi - fs))^2 ;
        
        [hann_pole, hann_omega0, hann_Hjw0] = get_ar_pole(hann_c) ;
        freq2(jj, 3) = freq2(jj, 3) + round((hann_omega0*ifsmp.fd/2/pi - fs))^2 ;

        [blackman_pole, blackman_omega0, blackman_Hjw0] = get_ar_pole(blackman_c) ;
        freq2(jj, 4) = freq2(jj, 4) + round((blackman_omega0*ifsmp.fd/2/pi - fs))^2 ;

        %%%%%%%%%%%%
        % 3 
        power_3 = 8 ;
        c = ar_model(ifft(XX .^ power_3) / N) ;
        hamming_c = ar_model(ifft(XX_hamming .^ power_3)/N) ;
        blackman_c = ar_model(ifft(XX_blackman .^ power_3)/N) ;
        hann_c = ar_model(ifft(XX_hann .^ power_3) / N) ;

        [pole, omega0, Hjw0] = get_ar_pole(c) ;
        freq3(jj, 1) = freq3(jj, 1) + (omega0*ifsmp.fd/2/pi - fs)^2 ;

        [hamming_pole, hamming_omega0, hamming_Hjw0] = get_ar_pole(hamming_c) ;
        freq3(jj, 2) = freq3(jj, 2) + (hamming_omega0*ifsmp.fd/2/pi - fs)^2 ;
        
        [hann_pole, hann_omega0, hann_Hjw0] = get_ar_pole(hann_c) ;
        freq3(jj, 3) = freq3(jj, 3) + (hann_omega0*ifsmp.fd/2/pi - fs)^2 ;

        [blackman_pole, blackman_omega0, blackman_Hjw0] = get_ar_pole(blackman_c) ;
        freq3(jj, 4) = freq3(jj, 4) + (blackman_omega0*ifsmp.fd/2/pi - fs)^2 ;        

    end ;
    
    freq1(jj,:) = sqrt(freq1(jj,:) / num_of_tests) ;
    freq2(jj,:) = sqrt(freq2(jj,:) / num_of_tests) ;
    freq3(jj,:) = sqrt(freq3(jj,:) / num_of_tests)  ;
    
 end ; % SNR

%SNR_dB_acf = SNR_dB ;
%save('freq_sko_ar_win', 'freq1', 'freq2', 'freq3', 'SNR_dB_acf')

freq_plot = freq3 ;

% figure(1) ,
%     subplot(3, 1, 1), semilogy(SNR_dB, freq_plot(:,1), '-go', SNR_dB, freq_plot(:,2), '-b*', ...
%             SNR_dB, freq_plot(:,3), '-r+', SNR_dB, freq_plot(:,4), '-y+') ;        
%         title('SKO') ,
%         legend('Rect', 'Hamming', 'Blackman', 'Hann') ;
%         phd_figure_style(gcf) ;
%         
%     subplot(3, 1, 2), semilogy(SNR_dB, freq2(:,1), '-go', SNR_dB, freq2(:,2), '-b*', ...
%             SNR_dB, freq2(:,3), '-r+', SNR_dB, freq2(:,4), '-y+') ;        
%         title('SKO') ,
%         legend('Rect', 'Hamming', 'Blackman', 'Hann') ;
%         phd_figure_style(gcf) ;        
% 
%     subplot(3, 1, 3), semilogy(SNR_dB, freq3(:,1), '-go', SNR_dB, freq3(:,2), '-b*', ...
%             SNR_dB, freq3(:,3), '-r+', SNR_dB, freq3(:,4), '-y+') ;        
%         title('SKO') ,
%         legend('Rect', 'Hamming', 'Blackman', 'Hann') ;
%         phd_figure_style(gcf) ;          

 save('acf_various_windows.mat', 'freq1', 'freq2', 'freq3');

    semilogy(SNR_dB, pll_line, '-m*', ...
            SNR_dB, freq_plot(:,1), '-go', SNR_dB, freq_plot(:,2), '-b*', ...
            SNR_dB, freq_plot(:,3), '-r+', SNR_dB, freq_plot(:,4), '-y+') ;        
        title('SKO') ,
        legend('PLL line', 'Rect', 'Hamming', 'Blackman', 'Hann') ;
        phd_figure_style(gcf) ;

% remove model path
rmpath(modelPath) ;