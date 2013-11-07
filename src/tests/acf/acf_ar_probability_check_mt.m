% get access to model
clc, clear all%, clf ;
curPath = pwd() ;
cd('..\\tsim\\model') ;
modelPath = pwd() ;
cd( curPath ) ;
addpath(modelPath) ;

% get access to multithread
matlabpool open 4 ;

%init_rand(1) ;

num_of_tests = 1000000 ;
pll_line = 18 ; % Hz

fd= 16.368e6 ;		% 16.368 MHz
fs = 4.092e6 ;

% A = 1, E = 0.5
% [0:0.05:30] => 1/20 * [0:1:600] => Fs = 20 Hz, N = 600
A = 1 ; E = A^2 / 2 ;
SNR_dB = -30:2:20 ;
%SNR_dB = 100 ;
sigma = E ./ (10 .^ (SNR_dB./10)) ;
SNR = E ./ sigma ;
N = 16368 ;
phase_arg = 2*pi*1*fs/fd*(0:N-1) ;
s = A * cos(phase_arg) ;

freq1 = zeros(num_of_tests, length(SNR_dB)) ;
freq2 = zeros(num_of_tests, length(SNR_dB)) ;
freq3 = zeros(num_of_tests, length(SNR_dB)) ;
freq1_match = zeros(length(SNR_dB), 1) ;
freq2_match = zeros(length(SNR_dB), 1) ;
freq3_match = zeros(length(SNR_dB), 1) ;

parfor jj=1:length(SNR_dB)
    
    fprintf('Actual: %.4f  dB\n', SNR_dB(jj)) ;

    for k=1:num_of_tests
        x = s + sqrt(sigma(jj))*(randn(size(s))) ;

        %%%%%%%%%%%%%%%%%%%
        % signal + noise
        X = fft(x) ;
        XX = X.*conj(X) ;
        rxx1 = ifft(XX) ;
        rxx2 = ifft(XX .^ 4) ;
        rxx3 = ifft(XX .^ 8) ;

        %%%%%%%%%%%%
        % 1    
        b1 = ar_model([rxx1(1); rxx1(2); rxx1(3)]) ;
        [poles1, omega0_1, Hjw0_1] = get_ar_pole(b1) ;
        freq1(k,jj) = omega0_1*fd/2/pi ;

        if (abs(freq1(k,jj)-fs) <= pll_line)
            freq1_match(jj) = freq1_match(jj) + 1;
        end ;      

        %%%%%%%%%%%%
        % 2    
        b2 = ar_model([rxx2(1); rxx2(2); rxx2(3)]) ;
        [poles2, omega0_2, Hjw0_2] = get_ar_pole(b2) ;
        freq2(k,jj) = omega0_2*fd/2/pi ;

        if (abs(freq2(k,jj)-fs) <= pll_line)
            freq2_match(jj) = freq2_match(jj) + 1;
        end ;    

        %%%%%%%%%%%%
        % 3    
        b3 = ar_model([rxx3(1); rxx3(2); rxx3(3)]) ;
        [poles3, omega0_3, Hjw0_3] = get_ar_pole(b3) ;
        freq3(k,jj) = omega0_3*fd/2/pi ;

        if (abs(freq3(k,jj)-fs) <= pll_line)
            freq3_match(jj) = freq3_match(jj) + 1;
        end ;

        %fprintf('Estimated freq: %.4f Hz\n', freq3(k));
    end ;
    
    freq1_match(jj) = freq1_match(jj) / num_of_tests ;
    freq2_match(jj) = freq2_match(jj) / num_of_tests ;
    freq3_match(jj) = freq3_match(jj) / num_of_tests ;
    
 end ; % SNR
    
%fprintf('freq1: probability: %.2f\n', freq1_match / num_of_tests * 100 ) ;
%fprintf('freq2: probability: %.2f\n', freq2_match / num_of_tests * 100 ) ;
%fprintf('freq3: probability: %.2f\n', freq3_match / num_of_tests * 100 ) ;

figure(1) ,
    semilogy(SNR_dB, freq1_match, '-go', SNR_dB, freq2_match, '-b*', SNR_dB, freq3_match, '-r+') ,
    title('Probability') ,
    legend('1', '2', '3') ;
    phd_figure_style(gcf) ;

matlabpool close ;

% remove model path
rmpath(modelPath) ;

