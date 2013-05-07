function [x,y,sats, delays, signoise] = get_if_signal(ifsmp)
N = 1023*15 ; % chips
max_delay = 20 ; % chips

% IF signal model parameters
sats = ifsmp.sats ;
vars = ifsmp.vars ;
fs = ifsmp.fs ;
fd = ifsmp.fd ;
delays = ifsmp.delays ;
snr_db = ifsmp.snr_db ;

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
