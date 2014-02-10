clc, clear, clf ;
% get access to model
curPath = pwd() ;
cd('..\\..\\tsim\\model') ;
modelPath = pwd() ;
cd( curPath ) ;
addpath(modelPath) ;

num_of_tests = 10 ;
N = 16368 ;

f_int = 4.087e6 ;   % 4.092e6 - 5e3 Hz - lowest Doppler freq
f_doppler = 11e3 ;  % +-5 kHz max Doppler shift 

% A = 1, E = 0.5
A = 1 ; E = A^2 / 2 ;
SNR_dB = -20:0 ;
%SNR_dB = 90:100 ;

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

        fs = 4.095333e6; %f_int + randi(f_doppler) ;
        
        ifsmp.vars = [E E E E] ;            % FIXME - can't be the same
        ifsmp.fs = [fs, f_int + randi(2 * f_doppler), f_int + randi(2 * f_doppler), f_int + randi(2 * f_doppler)] ;
        ifsmp.fd = 16.368e6 ;
        ifsmp.delays = [100, 150, 230, 10] ;
    
        [~, y ,sats, delays, signoise] = get_gps_if_signal( ifsmp ) ;
        code = get_gps_ca_code(ifsmp.sats(1), ifsmp.fd, length(y) + delays(1)) ;
        x = y.*code(1+delays(1):length(y)+delays(1)) ;
        
        fft_iter = 10 ;
        fft_array_size = floor(N/fft_iter) ;
        fft_array = 0; %zeros(fft_array_size, 1) ;
        
        fourier_length = N ;        

        for ii=0:fft_iter-1
            xx = x(ii*fft_array_size + 1 : (ii+1)*fft_array_size) ;
            XX = fft( xx .* blackman(length(xx)), fourier_length) ;
            XX2 = XX.*conj(XX) ;
            fft_array = fft_array + ifft(XX2) ;
            %fft_array(:, ii) = fft
        end
        
        % normalization
        fft_array = fft_array / fft_array(1) ;

        X = fft(fft_array, fourier_length) ;
        
        x_blackman = x.*blackman(length(x)) ;        
        X_blackman = fft(x_blackman, fourier_length) ;
    
        XX = X.*conj(X) ;
        XX_blackman = X_blackman .* conj(X_blackman) ;
 
        % gimme the fuel, quadruple
        power_3 = 8 ;
        blackman_c = ar_model(ifft(XX_blackman .^ power_3) / N) ;
        cx = ar_model(ifft(XX .^ power_3) / N ) ;
        
        [pole, omega0, Hjw0] = get_ar_pole(cx) ;
        freq3(jj, 1) = freq3(jj, 1) + round((omega0*ifsmp.fd/2/pi - fs))^2 ;

        [blackman_pole, blackman_omega0, blackman_Hjw0] = get_ar_pole(blackman_c) ;
        freq3(jj, 4) = freq3(jj, 4) + round((blackman_omega0*ifsmp.fd/2/pi - fs))^2 ;        

    end ;
    
    freq1(jj,:) = sqrt(freq1(jj,:) / num_of_tests) ;
    freq2(jj,:) = sqrt(freq2(jj,:) / num_of_tests) ;
    freq3(jj,:) = sqrt(freq3(jj,:) / num_of_tests) ;
    
 end ; % SNR

%SNR_dB_acf = SNR_dB ;
%save('freq_sko_ar_win', 'freq1', 'freq2', 'freq3', 'SNR_dB_acf')


    semilogy(SNR_dB, pll_line, '-m*', ...
            SNR_dB, freq3(:,1), SNR_dB, freq3(:,4), '-y+') ;        
        title('SKO') ,
        legend('Line', 'Split range + Hamming', 'Hamming') ;
        phd_figure_style(gcf) ;

% remove model path
rmpath(modelPath) ;