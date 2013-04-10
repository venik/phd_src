function [x,y,sats, delays, signoise] = if_signal_model(sats,snr_db)
N = 1023*2 ; % chips
max_delay = 20 ; % chips
%sats = [1,2] ;
vars = [1,1,1,1] ;
fs = [4000,3200,4000,3800] ;
fd = 16368 ;
delays = [100,150,200,60] ;
x = zeros(N*16,1) ;
for k=1:numel(sats)
    c = sqrt(vars(k)*2)*cos(2*pi*fs(k)/fd*(0:(N+max_delay)*16-1))' ;
    code = get_ca_code16(N+max_delay,sats(k)) ;
    code = code(:) ;
    tx = code.*c ;
    tx = tx(1+delays(k):N*16+delays(k)) ;
    x = x + tx ;
end
if (snr_db>=100)
    signoise = 0 ;
else
    signoise = 10^(-snr_db/10)*var(x) ;
end
%fprintf('if_signal_model: signoise:%f\n', signoise ) ;
y = x + randn(size(x))*sqrt(signoise) ;
