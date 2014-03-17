clc; clear all ;

clc, clear, clf ;
% get access to model
curPath = pwd() ;
cd('..\\tsim\\model') ;
modelPath = pwd() ;
cd( curPath ) ;
addpath(modelPath) ;

vars = [0.5 0.5] ;
sats = [1 2] ;
delays = [2000 8184] ;
fs = [4.091e6 4.095e6] ;
fd = 16.368e6 ;
ms = 2 ;
N = 16368 ;
tau = 128 ;

x = zeros(N*16*ms, 1) ;
s = zeros(N*16*ms, length(sats)) ;
code = zeros(N*16*ms, length(sats)) ;
for k=1:numel(sats)
    c = sqrt(vars(k)*2)*cos(2*pi*fs(k)/fd*(0:ms*N*16-1))' ;
    code(:, k) = repmat(get_ca_code16(N, sats(k)), ms, 1);
    s(:, k) = code(:, k) .* c ;
    %tx = tx(1+delays(k):N*16+delays(k)) ;
    tx = circshift(s(:, k), delays(k)) ;
    x = x + s(:, k) ;
end ;

x_dma = x(1:N) .* x(tau + 1:N + tau) ;
Fnyq = fd/2 ;       % Nyquist freq
Fc=Fnyq/2 ;             % cut-off freq [Hz]
[b,a]=butter(2, Fc/Fnyq);

x_filt_dma = filter(b, a, x_dma) ;

code_dma = code(1:N, 2) .* code(tau+1:N+tau, 2) ;

X_FILT_DMA = fft(x_filt_dma) ;
CODE_DMA = fft(code_dma) ;

res = ifft(CODE_DMA .* conj(X_FILT_DMA)) / N ;

plot(res .* conj(res)) ;

% remove model path
rmpath(modelPath) ;