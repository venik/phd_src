function [x,y,sats, delays, signoise] = get_gps_if_signal(ifsmp)
simTimeSec = ifsmp.sigLengthMsec/1e3 ; % get simulation time in sec
maxDelaySec = ifsmp.maxDelayMsec/1e3 ; % get maximum delay for sat in sec
numSamples = round(simTimeSec * ifsmp.fd) ;
maxDelaySamples = ceil(maxDelaySec * ifsmp.fd) ;

% IF signal model parameters
sats = ifsmp.sats ;
vars = ifsmp.vars ;
fs = ifsmp.fs ;
fd = ifsmp.fd ;
delays = ifsmp.delays ;
snr_db = ifsmp.snr_db ;

phasePoints = 2*pi*(0:numSamples+maxDelaySamples-1)/fd ;

x = zeros(numSamples,1) ;
for k=1:numel(sats)
    c = sqrt(vars(k)*2)*cos( phasePoints * fs(k) )' ;
    code = get_gps_ca_code(sats(k), fd, numSamples+maxDelaySamples ) ;
    code = code(:) ;
    tx = code.*c ;
    tx = tx(1+delays(k):numSamples+delays(k)) ;
    x = x + tx ;
end
if (snr_db>=100)
    signoise = 0 ;
else
    signoise = 10^(-snr_db/10)*var(x) ;
end
%fprintf('if_signal_model: signoise:%f\n', signoise ) ;
y = x + randn(size(x))*sqrt(signoise) ;
