function [x,y,sats, delays, signoise] = get_if_signal(ifsmp, ms, multipath)
N = 1023*16 ; % chips
%max_delay = 20 ; % chips

if nargin < 2
    ms = 1 ;
end
if nargin < 3
    multipath = 0 ;
end

% IF signal model parameters
sats = ifsmp.sats ;
vars = ifsmp.vars ;
fs = ifsmp.fs ;
fd = ifsmp.fd ;
delays = ifsmp.delays ;
snr_db = ifsmp.snr_db ;

x = zeros(N*16*ms, 1) ;
for k=1:numel(sats)
    c = sqrt(vars(k)*2)*cos(2*pi*fs(k)/fd*(0:ms*N*16-1))' ;
    code = repmat(get_ca_code16(N, sats(k)), ms, 1);
    tx = code.*c ;
    %tx = tx(1+delays(k):N*16+delays(k)) ;
    tx = circshift(tx, delays(k)) ;
    x = x + tx ;
    
    % add one more ray for main signal
    if k == 1 && multipath > 0
        for kk = 1:multipath
            E = 0.5 * rand() ;
            phase = rand() * pi - pi ;
            c = sqrt(E*2)*cos(2*pi*fs(k)/fd*(0:ms*N*16-1) + phase)' ;
            tx = code.*c ;
            delay_m = delays(k) + round(N*rand()) ;
            tx = circshift(tx, delay_m) ;
            x = x + tx ;
            fprintf('add ray %d, E=%f, delay:%d\n', kk, E, delay_m) ;
        end ; % kk
    end ; % k == 1
end
if (snr_db>=100)
    signoise = 0 ;
else
    signoise = 10^(-snr_db/10)*var(x) ;
end
%fprintf('if_signal_model: signoise:%f\n', signoise ) ;
sig = x + randn(size(x))*sqrt(signoise) ;
y = sig(1: ms*N) ;
