% get access to model
clc, clear all, clf ;
curPath = pwd() ;
cd('..\\tsim\\model') ;
modelPath = pwd() ;
cd( curPath ) ;
addpath(modelPath) ;

%init_rand(1) ;

% A = 1, E = 0.5
% [0:0.05:30] => 1/20 * [0:1:600] => Fs = 20 Hz, N = 600
A = 1 ; E = 0.5 ;
sigma = 16 ;
SNR = E / sigma ;
N = 600 ;
Fs = 20 ;
phase_arg = 2*pi*1/Fs*(0:N-1) ;
s = A * cos(phase_arg) ;
x = s + sqrt(sigma)*(randn(size(s))) ;

X = fft(x) ; 

X2 = zeros(4, length(X)) ;
X2(1, :) = X.*conj(X)/length(X) ;
X2(2, :) = X2(1, :).*X2(1, :)/length(X) ;
X2(3, :) = X2(2, :).*X2(2, :)/length(X) ;
X2(4, :) = X2(3, :).*X2(3, :)/length(X) ;

sig = zeros(length(X2(:,1)), length(X)) ;   

% BT
% ref Max p. 75 for BT
% BT = N/Fs
BT = N / Fs ;

sig(1, :) = ifft(X2(1, :)) ;
sig(2, :) = ifft(X2(2, :)) ;
sig(3, :) = ifft(X2(3, :)) ;
sig(4, :) = ifft(X2(4, :)) ;

% Max eq. p 194
% G = 2BT / (2 + 1/sigma_noise)
G = 2 * BT / (2 + 1/SNR ) ;

% Amplitude after k - iteration
% Amplitude(k) = A^(2^k)/(2^(2^k - 1))
k = 1 ;
Ak = A^(2^k)/(2^(2^k - 1)) ;
Ek = Ak^2 / 2;

% E after 1 iteration
est_sig_e = var(sig(k,2:end)) ;

noise_max = Ek / G ;
fprintf('Noise MAX: %.7f\n', noise_max) ;

% Calculate real noise
tt = Ak * cos(phase_arg) ;
real_noise = sig(k, 2:end) - tt(2:end) ;
real_noise_var = var(real_noise) ; 
SNR_est = (est_sig_e - real_noise_var) / real_noise_var ; 

fprintf('Noise real: %.7f\n', real_noise_var) ;
fprintf('Theoretical gain %.2f Real gain: %.2f\n', ...
        G, (est_sig_e - real_noise_var) / E) ;

plot(   2:120, sig(k, 2:120), ...
        2:120, tt(2:120)) ,
    legend('Signal', 'r_{xx}')
    xlabel('n') ;
    ylabel('r_{xx}(n)') ;
    phd_figure_style(gcf) ;


% remove model path
rmpath(modelPath) ;