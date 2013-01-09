function [y,sats, delays] = if_signal_model(snr_db)
N = 1023 ; % chips
sats = [1] ;
fs = [3800,4200,4300,4500] ;
fd = 16368 ;
len = 5 ;
delays = [1024,150,200,60] ;
y = zeros(len*N*16, 1) ;
tx = zeros(length(y), 1) ;

c = cos(2*pi*fs(1)/fd*(0:(len*N)*16-1))' ;
%c = exp(2*j*pi*fs(1)/fd*(0:(len*N)*16-1))' ;
code = get_ca_code16(N,1) ;
code = repmat(code, len, 1) ;
% size(code)
%  size(c)
tx = code.*c ;

%sum(c(1:16368) .^ 2)

% snr_db = 30 ; 
signoise = 10^(-snr_db/10)*var(tx) ;
tx = tx + sqrt(signoise) * randn(size(y)) ;
y = tx(delays(1):end) ;
%y = tx ;

%var(y) / signoise