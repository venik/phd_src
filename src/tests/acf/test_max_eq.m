clc, clear all ;

A = 1 ; E = 0.5 ;
sigma = 20 ;
SNR = E / sigma ;
N = 16368 ;
Fs = 20 ;
phase_arg = 2*pi*1/Fs*(0:N-1) ;
s = A * cos(phase_arg) ;

num_of_tests = 1 ;

fprintf('Actual: %.4f  dB\n', SNR);

rss = zeros(N, 1) ;
rxx = zeros(N, 1) ;

%%%%%%%%%%%%%%%%%%% \
% BT
% ref Max p. 75 for BT
% BT = N/Fs
BT = N / Fs ;

est_SNR = 0 ;
est_SNR1 = 0 ;

for k=1:num_of_tests 
    x = s + sqrt(sigma)*(randn(size(s))) ;
    
    fprintf('iteration %02d\n', k) ;
    
    %%%%%%%%%%%%%%%%%%
    % ACF fft
    S = fft(s) ;
    SS = S .* conj(S) ;
    rss1 = ifft(SS) ;

    X = fft(x) ;
    XX = X.*conj(X) ;
    rxx1 = ifft(XX) ;

    rnn1 = rxx1 - rss1 ;
    
    tmp_SNR1 = sum(rss1.^2) / sum(rnn1.^2) ;
    est_SNR1 = est_SNR1 + tmp_SNR1 ;
    
    %%%%%%%%%%%%%%%%%%
    % ACF stright
    for m=1:N
        rss(m) = sum(s .* circshift(s, [1,m])) / N ;
        rxx(m) = sum(x .* circshift(x, [1,m])) / N ;
    end
    
    % ACF of the noise
    rnn = rxx - rss ;
    
    tmp_SNR = sum(rss.^2) / sum(rnn.^2) ;
    est_SNR = est_SNR + tmp_SNR ;
end

est_SNR = est_SNR / num_of_tests ;

SNR_new = 2*BT*SNR / (2+1/SNR) ;

fprintf('Max %.02f actual %.02f actual fft %.02f\n', SNR_new, est_SNR, est_SNR1) ;