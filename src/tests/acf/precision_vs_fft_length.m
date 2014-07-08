clc, clear; %, clf ;
% get access to model
curPath = pwd() ;
cd('..\\tsim\\model') ;
modelPath = pwd() ;
cd( curPath ) ;
addpath(modelPath) ;

% test for estimate how much FFT length we should use to
% have best precision (saturated) vs best performance 

num_of_tests = 100 ;
N = 16368 ;

A = 1 ; E = A^2 / 2 ;
SNR_dB = -10:5 ;
SNR = E ./ 10.^(SNR_dB ./ 10) ; 

fd = 16.368e6 ;
f_base = 4.092e6 ;
f_doppler = 5e3 ;

FFT_length = 6 ;

freq = zeros(FFT_length, length(SNR_dB)) ;

for jjj=1:length(SNR_dB)
    
    fprintf('Actual SNR: %d dB noise energy: %.2f\n', SNR_dB(jjj), SNR(jjj)) ;

    for jj=1:FFT_length

        fprintf('FFT length: %d\n', jj) ;  

        for k=1:num_of_tests

            % uniform distribution of freq
            delta = -1 + 2 * rand() ;

            f = f_base + f_doppler * delta ;
            phase = 2*pi*f / fd * (1:N-1) ;
            noise = sqrt(SNR(jjj)) * randn(length(phase), 1) ;

            %fprintf('\t delta freq: %.2f\n', f_doppler * delta) ;

            s = cos(phase).' ;
            x = s + noise;

            % plot(x(1:50)) ;

            % interpolation
            fourier_length = jj*N ;

            X = fft(x, fourier_length) ;
            XX = X.*conj(X) ;

            power_3 = 8 ;
            c = ar_model(ifft(XX .^ power_3) / N) ;

            [pole, omega0, Hjw0] = get_ar_pole(c) ;

            freq(jj, jjj) = freq(jj, jjj) + (omega0*fd/2/pi - f)^2 ;
        end % k

        freq(jj,jjj) = sqrt(freq(jj, jjj) / num_of_tests) ;

    end ; % for jj
end ; % jjj

surf(log10(freq)), grid on,
    %xlim([SNR_dB(1) SNR_dB(end)])
    %ylim([1 FFT_length])
    xlabel('SNR'),
    ylabel('FFT length'),
    zlabel('Freq error, Hz');

% remove model path
rmpath(modelPath) ;