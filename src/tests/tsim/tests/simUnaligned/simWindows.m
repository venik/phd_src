clc, clear ;
% get access to model
curPath = pwd() ;
cd('..\\..\\model') ;
modelPath = pwd() ;
cd( curPath ) ;
addpath(modelPath) ;

N = 1024 ;
phase0 = 2*pi*(0:N-1) ;

mse = zeros(1,4) ;

R = 1000 ;
for r=1:R
    clc ;

    freq0 = 4092000-100+randi(300) ;

    x = cos(phase0(:)*freq0/16368000) ;

    x_hamming = x.*hamming(N) ;
    x_blackman = x.*blackman(N) ;
    x_hann = x.*hann(N,'periodic') ;

    X = fft(x) ;
    X_hamming = fft(x_hamming) ;
    X_blackman = fft(x_blackman) ;
    X_hann = fft(x_hann) ;

    c = ar_model( ifft(X.*conj(X))/N ) ;
    hamming_c = ar_model(ifft(X_hamming.*conj(X_hamming))/N) ;
    blackman_c = ar_model(ifft(X_blackman.*conj(X_blackman))/N) ;
    hann_c = ar_model(ifft(X_hann.*conj(X_hann))/N) ;

    [pole, omega0, Hjw0] = get_ar_pole(c) ;
    [hamming_pole, hamming_omega0, hamming_Hjw0] = get_ar_pole(hamming_c) ;
    [hann_pole, hann_omega0, hann_Hjw0] = get_ar_pole(hann_c) ;
    [blackman_pole, blackman_omega0, blackman_Hjw0] = get_ar_pole(blackman_c) ;

    fprintf('\t\tRect/\t\tHamming/\tHann/\t\tBlackman/\n') ;
    freq1 = [round(omega0/2/pi*16368000), round(hamming_omega0/2/pi*16368000), ...
        round(hann_omega0/2/pi*16368000), round(blackman_omega0/2/pi*16368000)] ;
    fprintf('\t%10d/',repmat(freq0,1,4)) ;
    fprintf('\n');
    fprintf('\t%10d/',freq1) ;
    fprintf('\n');
    fprintf('\t%10d/',freq1-freq0) ;
    fprintf('\n');
    
    mse = mse + (freq1-freq0).^2 ;
end

fprintf('Mean square error:\n') ;
fprintf('\t%10.2f/', mse/R) ;
    fprintf('\n');

% remove model path
rmpath(modelPath) ;