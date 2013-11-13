% get access to model
clc, clear all, clf ;
curPath = pwd() ;
cd('..\\tsim\\model') ;
modelPath = pwd() ;
cd( curPath ) ;
addpath(modelPath) ;

%init_rand(1) ;

num_of_tests = 1000 ;

% A = 1, E = 0.5
% [0:0.05:30] => 1/20 * [0:1:600] => Fs = 20 Hz, N = 600
A = 1 ; E = A^2 / 2 ;
SNR_dB = -30 ;
sigma = E / (10 ^ (SNR_dB/10)) ;
SNR = E / sigma ;
N = 16368 ;
Fs = 4 ;
phase_arg = 2*pi*1/Fs*(0:N-1) ;
s = A * cos(phase_arg) ;

%%%%%%%%%%%%%%%%%%%
% BT
% ref Max p. 75 for BT
% BT = N/Fs
BT = N / Fs ;

est_SNR1 = 0 ;
est_SNR2 = 0 ;
est_SNR3 = 0 ;

fprintf('Actual: %.4f  dB\n', SNR_dB);

for k=1:num_of_tests 
    x = s + sqrt(sigma)*(randn(size(s))) ;

    %%%%%%%%%%%%%%%%%%%
    % signal
    S = fft(s) ;
    SS = S .* conj(S) ;
    rss1 = ifft(SS) ;
    rss2 = ifft(SS .^ 4) ;
    rss3 = ifft(SS .^ 8) ;

    %%%%%%%%%%%%%%%%%%%
    % signal + noise
    X = fft(x) ;
    XX = X.*conj(X) ;
    rxx1 = ifft(XX) ;
    rxx2 = ifft(XX .^ 4) ;
    rxx3 = ifft(XX .^ 8) ;

    % ACF of the noise
    rnn1 = rxx1 - rss1 ;
    rnn2 = rxx2 - rss2 ;
    rnn3 = rxx3 - rss3 ;

    tmp_SNR1 = sum(rss1.^2) / sum(rnn1.^2) ;
    est_SNR1 = est_SNR1 + tmp_SNR1 ;
    
    tmp_SNR2 = sum(rss2.^2) / sum(rnn2.^2) ;
    est_SNR2 = est_SNR2 + tmp_SNR2 ;
    
    tmp_SNR3 = sum(rss3.^2) / sum(rnn3.^2) ;
    est_SNR3 = est_SNR3 + tmp_SNR3 ;
    
    %fprintf('Real gain %.3f\n', tmp_SNR / E) ;

end ;

est_SNR1 = est_SNR1 / num_of_tests ;
est_SNR2 = est_SNR2 / num_of_tests ;
est_SNR3 = est_SNR3 / num_of_tests ;

% Max eq. p 194
G1 = 2 * BT * SNR / (2 + 1/SNR ) ;
G2 = 2 * BT * est_SNR1 / (2 + 1/est_SNR1 ) ;
G3 = 2 * BT * est_SNR2 / (2 + 1/est_SNR2 ) ;
fprintf('Theoretical gain 1: %.3f 2: %.3f 2: %.3f\n', G1, G2, G3) ;

%est_SNR1_dB = 10*log10(est_SNR1 / SNR) ;
%est_SNR2_dB = 10*log10(est_SNR2 / SNR) ;
%est_SNR3_dB = 10*log10(est_SNR3 / SNR) ;

%est_SNR1_dB = 10*log10(est_SNR1) ;
%est_SNR2_dB = 10*log10(est_SNR2) ;
%est_SNR3_dB = 10*log10(est_SNR3) ;

fprintf('dB scale ==> after 1: %.3f after 2: %.3f  after 3: %.3f\n', est_SNR1, est_SNR2, est_SNR3) ;

% remove model path
rmpath(modelPath) ;