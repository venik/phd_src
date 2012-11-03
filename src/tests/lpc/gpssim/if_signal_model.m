function [y,sats, delays] = if_signal_model()
N = 1023 ; % chips
max_delay = 20 ; % chips
sats = [1] ;
fs = [3800,4200,4300,4500] ;
fd = 16368 ;
delays = [100,150,200,60] ;
y = zeros(N*16,1) ;
for k=1:numel(sats)
    c = cos(2*pi*fs(k)/fd*(0:(N+max_delay)*16-1))' ;
    code = get_ca_code16(N+max_delay,1) ;
    code = code(:) ;
    tx = code.*c ;
    tx = tx(1+delays(k):N*16+delays(k)) ;
    y = y + tx ;
end
snr_db = 10 ;
signoise = 10^(-snr_db/10)*var(y) ;
y = y + randn(size(y))*sqrt(signoise) ;

