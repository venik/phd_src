clc, clear ;
addpath('../../gnss/');

P = 2 ;        % order of LPC analysis
N = 1023*4 ;   % number of samples
fs = 4200 ;       % carrier frequency
fd = 16368 ;      % sampling frequency
snr = 0 ;     % snr
ca_error = 10 ; % ca position error
bit_edge = 0 ; % bit edge flag
PRN =1;

c = cos(2*pi*fs/fd*(0:N*16-1))' ;
if bit_edge
    c(1+ca_error:end) = -c(1+ca_error:end) ;
end
code = ca_get(PRN,0) ;
code = repmat(code,4,1) ;
tx = code.*c ;
xsigma = (tx'*tx)/numel(tx) ;
signoise = xsigma/(10^(snr/10)) ;
tx = tx + randn(size(tx))*sqrt(signoise) ;

[freq,E] = lpcs(tx(16369-ca_error:16368*2-ca_error),code(1:16368)) ;
%plot(freq*fd/2/pi), grid on ;
%plot(E),grid on ;
[~,ca_shift] = max(E) ;
f = freq(ca_shift) ;
fprintf('freq:%8.2f,  pwr:%5.2f, k:%4d\n', f*fd/2/pi, ...
     E(ca_shift), ca_shift-1 ) ;

% % receiver
% en = zeros(1024,1) ;
% for ca_error=1:1024
% rx = tx(1:16368).*[code(ca_error:16368);code(1:ca_error-1)] ;
% [b,poles] = lpcmodel(rx,2) ;
% fprintf('freq:%8.2f,  pwr:%5.2f\n',angle(poles(1))*fd/2/pi, ...
%     poles(1)*conj(poles(1)) ) ;
% en(ca_error) = poles(1)*conj(poles(1)) ;
% end

% [d,freq,E] = lpcs(tx(1+20:16368+20),code(1:16368)) ;
% fprintf('freq:%8.2f,  pwr:%5.2f, k:%4d\n',freq*fd/2/pi, ...
%     E, d ) ;


% rx_code = [code(ca_error+1:end); code(1:ca_error)] ;
% rx = tx.*rx_code ; % remove code
% [b,poles] = lpcmodel(rx,P) ;
% fprintf('Detected frequencies list:\n') ;
% for k=1:length(poles)
%     fprintf('freq:%8.2f,  pwr:%5.2f\n',angle(poles(k))*fd/2/pi, ...
%         poles(k)*conj(poles(k)) ) ;
% end
%plot(rx(1:50))

rmpath('../../gnss/');