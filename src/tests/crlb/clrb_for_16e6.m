clc; clear all;

sigma = 1 ;
Fd = 16.368e6 ;
Delta = 1/Fd ;
A = 1 ;
phi = 0 ;
N = 16368 ;
i = 1:N ;
f = 4.092e6 ;

SNR = 1/sigma^2 ;
b22_parameter = zeros(length(f), 1) ;

for ff = 1:length(f)
    phase = 2*pi*f(ff)*Delta.*i + phi ;
    B11 = sum(SNR .* (sin(phase)).^2) ;
    B22 = sum(SNR .* (2 * pi * Delta .* i * A .* cos(phase)).^2) ;
    B33 = sum(SNR .* (A*cos(phase)).^2) ;
    B12 = sum(SNR .* (2 * pi * Delta .* i * A) .* sin(phase) .* cos(phase)) ;
    B13 = sum(SNR .* A .* sin(phase) .* cos(phase)) ;
    B23 = sum(SNR .* (2*pi*Delta.*i .*(A*cos(phase)).^2)) ;
    B = [B11 B12 B13 ; B12 B22 B23 ; B13 B23 B33] ;
    B = inv(B) ;
    
    b22_parameter(ff) = B(2,2) ;
end ;

fprintf('crlb: %f\n', b22_parameter) ;