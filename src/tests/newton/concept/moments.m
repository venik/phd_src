clc, clear all ;
N = 16368 ;
n2 = 10 ; % !!!
fsig = 3000 ;
x = cos(2*pi*fsig/16368*(0:N-1)) + randn(1,N)*sqrt(n2) ;

mean = var(x) ;
sigma = sqrt(1/N * sum((x-mean) .^ 2)) ;
sig = abs(var(x) - sigma) ;


fprintf('Noise Enr: %f\n', sigma) ;
fprintf('Signl Enr: %f\n', sig) ;