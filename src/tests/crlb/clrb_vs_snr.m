clc; clear all;

sigma = 1 ;
%Delta = 0.008 ;
%Fd = 1/Delta ;
Fd = 16.368e6 ;
Delta = 1/Fd ;

SNR_db = -10:1:25 ;
SNR_range = 10.^(SNR_db ./ 10) ;

A = sqrt(SNR_range);
phi = 0 ;
%N = 16 ;
N = 16368 ;
i = 1:N ;
%f = 0:0.1:125 ;
f = 4.092e6 ;

SNR = 1/sigma^2 ;
b22_parameter = zeros(length(A), 1) ;

for ff = 1:length(A)
    B11 = sum(SNR .* (sin(2*pi*f*Delta.*i + phi)).^2) ;
    B22 = sum(SNR .* (2 * pi * Delta .* i .* A(ff) .* cos(2*pi*f*Delta.*i + phi)).^2) ;
    B33 = sum(SNR .* (cos(2*pi*f*Delta.*i + phi)).^2) ;
    B12 = sum(SNR .* (2 * pi * Delta .* i * A(ff)) .* cos(2*pi*f*Delta.*i + phi) .* sin(2*pi*f*Delta.*i + phi)) ;
    B13 = sum(SNR .* A(ff) .* cos(2*pi*f*Delta.*i + phi) .* sin(2*pi*f*Delta.*i + phi)) ;
    B23 = sum(SNR .* (2*pi*Delta.*i .*(A(ff)*cos(2*pi*f*Delta.*i + phi)).^2)) ;
    B = [B11 B12 B13 ; B12 B22 B23 ; B13 B23 B33] ;
    B = inv(B) ;
    
    b22_parameter(ff) = B(2,2) ;
end ;

plot(sqrt(b22_parameter))