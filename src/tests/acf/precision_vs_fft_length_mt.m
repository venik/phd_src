clc, clear; %, clf ;
% get access to model
curPath = pwd() ;
cd('..\\tsim\\model') ;
modelPath = pwd() ;
cd( curPath ) ;
addpath(modelPath) ;

% test for estimate how much FFT length we should use to
% have best precision (saturated) vs best performance 

num_of_tests = 10000 ;
N = 16368 ;

A = 1 ; E = A^2 / 2 ;
SNR_dB = -30:5 ;
SNR = E ./ 10.^(SNR_dB ./ 10) ; 

fd = 16.368e6 ;
f_base = 4.092e6 ;
f_doppler = 5e3 ;

FFT_lengths = [16368, 16368*2, 16368*3, 16368*4, 16368*5, 16368*6, 16368*7] ;
FFT_length = numel(FFT_lengths) ;

freq = zeros(FFT_length, length(SNR_dB)) ;
par_FFT_lengths = repmat(FFT_lengths,length(SNR_dB),1) ;

matlabpool open 4 ;

parfor jjj=1:length(SNR_dB)
    
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
            %fourier_length = jj*N ;
            fourier_length = par_FFT_lengths(jjj,jj) ;

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

matlabpool close ;

[X,Y]=meshgrid(SNR_dB,FFT_lengths) ;
surfc(X,Y,log10(freq)), grid on,
    %xlim([SNR_dB(1) SNR_dB(end)])
    %ylim([1 FFT_length])
    xlabel('SNR','FontSize',14,'Color',[0 0 0.8]),
    ylabel('FFT length','FontSize',14,'Color',[0 0 0.8]),
    zlabel('Freq error, Hz','FontSize',14,'Color',[0 0 0.8]) ;
set(gca,'FontSize',14) ;

% save('precision_vs_fft_length_mt.mat', 'SNR_dB', 'FFT_lengths', 'freq');

% remove model path
rmpath(modelPath) ;