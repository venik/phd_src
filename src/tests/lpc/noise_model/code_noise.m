clc, clear all ;
prn1 = 13 ;
prn2 = 1 ;
varx1 = 1 ;
varx2 = 2 ;
fs1 = 3850 ;
fd = 16368 ;
N = 1023 ; % chips
max_delay = 20 ; % chips

c = get_ca_code16(1023,prn2) ;
n = randn(numel(c), 1) ;

cn = c .* n ;
CN = fft(cn) ;

cn = ifft(CN .* conj(CN)) ./ 16 / 1023;
%cn = ifft(fft(n) .* conj(fft(n))) ;

% check for delta func
bt = [ cn(round(numel(cn) / 2) : end) ; cn(1:round(numel(cn) / 2) - 1)] ;

plot(-fd/2:fd/2-1, bt(1:end))
    title('¿ ‘ n(t)C(t)'),
    xlim([-fd/2 fd/2-1]),
    xlabel('\tau'),
    ylabel('r_n(\tau)') ;