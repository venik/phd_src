function [x,y,sats, delays, signoise] = if_signal_model(snr_db)
N = 1023 ; % chips
max_delay = 20 ; % chips
sats = [1] ;
vars = [1,1,0.8,0.5] ;
fs = [3500,4200,4300,4500] ;
fd = 16368 ;
delays = [100,150,200,60] ;
x = zeros(N*16,1) ;
for k=1:numel(sats)
    c = sqrt(vars(k))*cos(2*pi*fs(k)/fd*(0:(N+max_delay)*16-1))' ;
    code = get_ca_code16(N+max_delay,sats(k)) ;
    code = code(:) ;
    tx = code.*c ;
    tx = tx(1+delays(k):N*16+delays(k)) ;
    x = x + tx ;
end
%snr_db = -10 ;
signoise = 10^(-snr_db/10)*var(x) ;
fprintf('if_signal_model: signoise:%f\n', signoise ) ;
y = x + randn(size(x))*sqrt(signoise) ;
