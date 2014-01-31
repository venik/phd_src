clc, clear, clf ;
% get access to model
curPath = pwd() ;
cd('..\\..\\tsim\\model') ;
modelPath = pwd() ;
cd( curPath ) ;
addpath(modelPath) ;

num_of_tests = 10 ;
N = 16368 ;

fd= 16.368e6 ;		% 16.368 MHz
fs = 4.087e6 ;      % 4.092e6 - 5e3 Hz - lowest Doppler freq
f_doppler = 5e3 ;   % 5 kHz max Doppler shift 

% A = 1, E = 0.5
A = 1 ; E = A^2 / 2 ;
SNR_dB = -30:1:15 ;
%SNR_dB = 100 ;
sigma = E ./ (10 .^ (SNR_dB./10)) ;
SNR = E ./ sigma ;

phase_arg = 2*pi*(0:N-1) ;

num_of_windows = 4 ;

freq1 = zeros(length(SNR_dB), num_of_windows) ;
freq2 = zeros(length(SNR_dB), num_of_windows) ;
freq3 = zeros(length(SNR_dB), num_of_windows) ;

for jj=1:length(SNR_dB)
    
    fprintf('Actual: %.4f  dB\n', SNR_dB(jj));

    for k=1:num_of_tests
        
        freq0 = fs - randi(2 * f_doppler) ;
        x = cos(phase_arg(:)*freq0/fd) + sqrt(sigma(jj))*(randn(size(phase_arg))).' ;

        %%%%%%%%%%%%%%%%%%%
        % signal + noise
        x_hamming = x.*hamming(N) ;
        x_blackman = x.*blackman(N) ;
        x_hann = x.*hann(N, 'periodic') ;

        X = fft(x) ;
        X_hamming = fft(x_hamming) ;
        X_blackman = fft(x_blackman) ;
        X_hann = fft(x_hann) ;
    
        XX = X.*conj(X) ;
        XX_hamming = X_hamming .* conj(X_hamming) ;
        XX_blackman = X_blackman .* conj(X_blackman) ;
        XX_hann = X_hann.*conj(X_hann) ;

        %%%%%%%%%%%%
        % 1        
        c = ar_model(ifft(XX) / N) ;
        hamming_c = ar_model(ifft(X_hamming)/N) ;
        blackman_c = ar_model(ifft(XX_blackman)/N) ;
        hann_c = ar_model(ifft(XX_hann)/N) ;

        [pole, omega0, Hjw0] = get_ar_pole(c) ;
        freq1(jj, 1) = freq1(jj, 1) + round((omega0*fd/2/pi - fs))^2 ;

        [hamming_pole, hamming_omega0, hamming_Hjw0] = get_ar_pole(hamming_c) ;
        freq1(jj, 2) = freq1(jj, 2) + round((hamming_omega0*fd/2/pi - fs))^2 ;
        
        [hann_pole, hann_omega0, hann_Hjw0] = get_ar_pole(hann_c) ;
        freq1(jj, 3) = freq1(jj, 3) + round((hann_omega0*fd/2/pi - fs))^2 ;

        [blackman_pole, blackman_omega0, blackman_Hjw0] = get_ar_pole(blackman_c) ;
        freq1(jj, 4) = freq1(jj, 4) + round((blackman_omega0*fd/2/pi - fs))^2 ;

        %%%%%%%%%%%%
        % 2 
        c = ar_model(ifft(XX .^ 4) / N) ;
        hamming_c = ar_model(ifft(X_hamming .^ 4)/N) ;
        blackman_c = ar_model(ifft(XX_blackman .^ 4)/N) ;
        hann_c = ar_model(ifft(XX_hann .^ 4) / N) ;

        [pole, omega0, Hjw0] = get_ar_pole(c) ;
        freq2(jj, 1) = freq2(jj, 1) + round((omega0*fd/2/pi - fs))^2 ;

        [hamming_pole, hamming_omega0, hamming_Hjw0] = get_ar_pole(hamming_c) ;
        freq2(jj, 2) = freq2(jj, 2) + round((hamming_omega0*fd/2/pi - fs))^2 ;
        
        [hann_pole, hann_omega0, hann_Hjw0] = get_ar_pole(hann_c) ;
        freq2(jj, 3) = freq2(jj, 3) + round((hann_omega0*fd/2/pi - fs))^2 ;

        [blackman_pole, blackman_omega0, blackman_Hjw0] = get_ar_pole(blackman_c) ;
        freq2(jj, 4) = freq2(jj, 4) + round((blackman_omega0*fd/2/pi - fs))^2 ;

        %%%%%%%%%%%%
        % 2 
        c = ar_model(ifft(XX .^ 8) / N) ;
        hamming_c = ar_model(ifft(X_hamming .^ 8)/N) ;
        blackman_c = ar_model(ifft(XX_blackman .^ 8)/N) ;
        hann_c = ar_model(ifft(XX_hann .^ 8) / N) ;

        [pole, omega0, Hjw0] = get_ar_pole(c) ;
        freq3(jj, 1) = freq3(jj, 1) + round((omega0*fd/2/pi - fs))^2 ;

        [hamming_pole, hamming_omega0, hamming_Hjw0] = get_ar_pole(hamming_c) ;
        freq3(jj, 2) = freq3(jj, 2) + round((hamming_omega0*fd/2/pi - fs))^2 ;
        
        [hann_pole, hann_omega0, hann_Hjw0] = get_ar_pole(hann_c) ;
        freq3(jj, 3) = freq3(jj, 3) + round((hann_omega0*fd/2/pi - fs))^2 ;

        [blackman_pole, blackman_omega0, blackman_Hjw0] = get_ar_pole(blackman_c) ;
        freq3(jj, 4) = freq3(jj, 4) + round((blackman_omega0*fd/2/pi - fs))^2 ;        

    end ;
    
    freq1(jj,:) = sqrt(freq1(jj,:) / num_of_tests) ;
    freq2(jj,:) = sqrt(freq2(jj,:) / num_of_tests) ;
    freq3(jj,:) = sqrt(freq3(jj,:) / num_of_tests)  ;
    
 end ; % SNR

%SNR_dB_acf = SNR_dB ;
%save('freq_sko_ar_win', 'freq1', 'freq2', 'freq3', 'SNR_dB_acf')

freq_plot = freq2 ;

figure(1) ,
    hold on,
    plot(SNR_dB, freq_plot(:,1), '-go', SNR_dB, freq_plot(:,2), '-b*', ...
            SNR_dB, freq_plot(:,3), '-r+', SNR_dB, freq_plot(:,4), '-y+') ,
        
    title('SKO') ,
    legend('Rect', 'Hamming', 'Blackman', 'Hann') ;
    phd_figure_style(gcf) ;

% remove model path
rmpath(modelPath) ;