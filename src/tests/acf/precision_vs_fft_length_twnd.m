clc, clear; %, clf ;
% get access to model
curPath = pwd() ;
cd('..\\tsim\\model') ;
modelPath = pwd() ;
cd( curPath ) ;
addpath(modelPath) ;

% test for estimate how much FFT length we should use to
% have best precision (saturated) vs best performance 

num_of_tests = 1000 ;
N = 16368 ;

A = 1 ; E = A^2 / 2 ;
SNR_dB = -12 ;
SNR = E / 10^(SNR_dB / 10) ; 

fd = 16.368e6 ;
f_base = 4.092e6 ;
f_doppler = 5e3 ;

FFT_length = 13 ;

freq = zeros(FFT_length, 5) ;

power_3 = 8 ;
%matlabpool open 6 ;

%parfor jjj=1:length(SNR_dB)
    
    fprintf('Actual SNR: %d dB noise energy: %.2f\n', SNR_dB, SNR) ;

    for jj=1:FFT_length

        fprintf('FFT length: %d\n', jj) ;  

        for k=1:num_of_tests

            % uniform distribution of freq
            delta = -1 + 2 * rand() ;

            f = f_base + f_doppler * delta ;
            phase = 2*pi*f / fd * (1:N-1) ;
            noise = sqrt(SNR) * randn(length(phase), 1) ;

            %fprintf('\t delta freq: %.2f\n', f_doppler * delta) ;

            s = cos(phase).' ;
            x = s + noise;

            % plot(x(1:50)) ;

            % interpolation
                fourier_length = N+(jj-1)*N/4 ;

                X = fft(x, fourier_length) ;
            XX = X.*conj(X) ;
            c = ar_model(ifft(XX .^ power_3) / N) ;
            [pole, omega0, Hjw0] = get_ar_pole(c) ;
            freq(jj, 1) = freq(jj, 1) + (omega0*fd/2/pi - f)^2 ;
            
            x_hamming = x.*hamming(length(x)) ;
            X_hamming = fft(x_hamming, fourier_length) ;
            XX_hamming = X_hamming.*conj(X_hamming) ;
            c = ar_model(ifft(XX_hamming .^ power_3) / N) ;
            [pole_hamming, omega0_hamming, Hjw0_hamming] = get_ar_pole(c) ;
            freq(jj, 2) = freq(jj, 2) + (omega0_hamming*fd/2/pi - f)^2 ;
            
            x_blackman = x.*blackman(length(x)) ;
            X_blackman = fft(x_blackman, fourier_length) ;
            XX_blackman = X_blackman.*conj(X_blackman) ;
            c = ar_model(ifft(XX_blackman .^ power_3) / N) ;
            [pole_blackman, omega0_blackman, Hjw0_blackman] = get_ar_pole(c) ;
            freq(jj, 3) = freq(jj, 3) + (omega0_blackman*fd/2/pi - f)^2 ;
            
            x_hann = x.*hann(length(x),'periodic') ;
            X_hann = fft(x_hann, fourier_length) ;
            XX_hann = X_hann.*conj(X_hann) ;
            c = ar_model(ifft(XX_hann .^ power_3) / N) ;
            [pole_hann, omega0_hann, Hjw0_hann] = get_ar_pole(c) ;
            freq(jj, 4) = freq(jj, 4) + (omega0_hann*fd/2/pi - f)^2 ;

            % 1st stage
            x_hamming1 = x.*hamming(length(x)) ;
            X_hamming1 = fft(x_hamming1, fourier_length) ;
            XX_hamming1 = X_hamming1.*conj(X_hamming1) ;
            x_hamming_acf1 = ifft(XX_hamming1) ;
            % 2nd stage 
            hwnd = zeros(fourier_length,1) ;
            hwnd(1:fourier_length/3) = hamming(fourier_length/3) ;
            x_hamming2 = x_hamming_acf1.*hwnd ;
            X_hamming2 = fft(x_hamming2, fourier_length) ;
            XX_hamming2 = X_hamming2.*conj(X_hamming2) ;
            x_hamming_acf2 = ifft(XX_hamming2) ;
            % 3nd stage 
            hwnd = zeros(fourier_length,1) ;
            hwnd(1:round(fourier_length/1.5)) = hamming(round(fourier_length/1.5)) ;
            x_hamming3 = x_hamming_acf2.*hwnd ;
            X_hamming3 = fft(x_hamming3, fourier_length) ;
            XX_hamming3 = X_hamming3.*conj(X_hamming3) ;
            x_hamming_acf3 = ifft(XX_hamming3) ;
            
            c = ar_model(x_hamming_acf3/N) ;
            [pole_thamming, omega0_thamming, Hjw0_thamming] = get_ar_pole(c) ;
            freq(jj, 5) = freq(jj, 5) + (omega0_thamming*fd/2/pi - f)^2 ;
            
        end % k

        freq(jj,:) = sqrt(freq(jj, :) / num_of_tests) ;
        %freq(jj,2) = sqrt(freq(jj, 2) / num_of_tests) ;

    end ; % for jj
%end ; % jjj

%matlabpool close ;

save('fft_length_twnd_12dB.mat','freq') ;

hold off, plot(1:0.25:FFT_length/4+0.75, freq(:,1),'b-') ;
hold on, plot(1:0.25:FFT_length/4+0.75,freq(:,2),'r-') ;
hold on, plot(1:0.25:FFT_length/4+0.75,freq(:,3),'m-') ;
hold on, plot(1:0.25:FFT_length/4+0.75,freq(:,4),'k-') ;
hold on, plot(1:0.25:FFT_length/4+0.75,freq(:,5),'y-') ;
legend('square', 'hamming', 'blackman', 'hann','t-hamming') ;
xlabel('FFT size, (xN)') ;
title(sprintf('%5.2fdB', SNR_dB)) ;
grid on ;

phd_figure_style(gcf) ;

% remove model path
rmpath(modelPath) ;