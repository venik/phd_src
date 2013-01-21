function [y, sats, delays, fs, sigma_noise] = if_signal_model(snr_db, A2)
N = 1023 ; % chips
sats = [1, 10] ;
fs = [3800,1000,4300,4500] ;
fd = 16368 ;
len = 5 ;
delays = [1024,1000,200,60] ;
y = zeros(len*N*16, 1) ;
tx = zeros(length(y), 1) ;

% 1
c = cos(2*pi*fs(1)/fd*(0:(len*N)*16-1))' ;
%c = exp(2*j*pi*fs(1)/fd*(0:(len*N)*16-1))' ;
code = get_ca_code16(N, sats(1)) ;
code = repmat(code, len, 1) ;
tx = code.*c ;
tx1 = tx(delays(1):end) ;

% 2
c = A2*cos(2*pi*fs(2)/fd*(0:(len*N)*16-1))' ;
c = exp(2*j*pi*fs(1)/fd*(0:(len*N)*16-1))' ;
code = get_ca_code16(N, sats(2)) ;
code = repmat(code, len, 1) ;
tx = code.*c ;
tx2 = tx(delays(2):end) ;

%sum(c(1:16368) .^ 2)

% snr_db = 30 ; 
signoise = 10^(-snr_db/10)*var(tx) ;
sigma_noise = sqrt(signoise) ;
y = tx1 + tx2(1:end-delays(1) + delays(2)) + sigma_noise * randn(size(tx1)) ;
y = y(1:16*N) ;
%y = tx ;

%var(y) / signoise
fprintf('N = %f\n', signoise) ;
fprintf('E = %f\n', var(tx)) ;