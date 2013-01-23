clc, clear all ;
prn1 = 13 ;
prn2 = 1 ;
varx1 = 1 ;
varx2 = 2 ;
fs1 = 3850 ;
fd = 16368 ;
N = 1023 ; % chips
max_delay = 20 ; % chips

pts1 = [] ;
pts2 = [] ;
pts3 = [] ;

c = get_ca_code16(N+max_delay,prn2) ;
n = randn(numel(c), 1) ;

cn = c .* n ;
CN = fft(cn) ;

cn = ifft(CN .* conj(CN)) ;
%cn = ifft(fft(n) .* conj(fft(n))) ;

cn = cn .* conj(cn) ;

% check for delta func
plot(cn(1:end)) ;