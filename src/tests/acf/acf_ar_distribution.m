% get access to model
clc, clear all%, clf ;
curPath = pwd() ;
cd('..\\tsim\\model') ;
modelPath = pwd() ;
cd( curPath ) ;
addpath(modelPath) ;

%init_rand(1) ;

num_of_tests = 100 ;

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

fd= 16.368e6;		% 16.368 MHz

%%%%%%%%%%%%%%%%%%%
% BT
% ref Max p. 75 for BT
% BT = N/Fs
BT = N / Fs ;

fprintf('Actual: %.4f  dB\n', SNR_dB);

freq3 = zeros(num_of_tests, 1) ;

for k=1:num_of_tests 
    x = s + sqrt(sigma)*(randn(size(s))) ;

    %%%%%%%%%%%%%%%%%%%
    % signal + noise
    X = fft(x) ;
    XX = X.*conj(X) ;
    rxx3 = ifft(XX .^ 8) ;
    
    %%%%%%%%%%%%
    % 3    
    b3 = ar_model([rxx3(1); rxx3(2); rxx3(3)]) ;
    [poles3, omega0_3, Hjw0_3] = get_ar_pole(b3) ;
    freq3(k) = omega0_3*fd/2/pi ;
    
    %fprintf('Estimated freq: %.4f  dB\n', freq3);
end ;

hist(freq3)

% remove model path
rmpath(modelPath) ;