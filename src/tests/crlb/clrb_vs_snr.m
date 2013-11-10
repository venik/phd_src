clc; clear all;

addpath('../tsim/model/');

sigma = 1 ;
Fd = 16.368e6 ;
Delta = 1/Fd ;

SNR_db = -25:1:25 ;
SNR_range = 10.^(SNR_db ./ 10) ;

E = sqrt(SNR_range);
phi = 0 ;
%N = 16 ;
N = 16368 ;
i = 1:N ;
%f = 0:0.1:125 ;
f = 4.092e6 ;

SNR = 1/sigma^2 ;
b22_parameter = zeros(length(E), 1) ;

for ff = 1:length(E)
    A = sqrt(E(ff)) ;
    
    phase = 2*pi*f*Delta.*i + phi ;
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

plot(SNR_db, sqrt(b22_parameter))
    phd_figure_style(gcf) ;


rmpath('../tsim/model/');
    