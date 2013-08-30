clc, clear all ;
% check equality of ACF computation algorithms

% get access to model
clc, clear all ;
curPath = pwd() ;
cd('..\\..\\model') ;
modelPath = pwd() ;
cd( curPath ) ;
addpath(modelPath) ;

% initialize nose seed
% init_rand(1) ;

N = 250 ;
freqIdx = (round(N/64)) ;%+0.1 ;
phase_arg = 2*pi*freqIdx/N*(0:N-1) ;
% get signal in time domain
s = cos(phase_arg) ;

%s = s(:).*hamming(N) ;

% compute circular ACF
r = zeros(size(s)) ;
for n=1:N
    r(n) = sum(s(:).*circshift(s(:),n-1))/N ;
end

% compute AFC using FFT
S = fft(s) ;
r_fft = ifft( S.*conj(S) )/N ;

hold off, plot(r) ;
hold on, plot(r_fft,'r-.')
phd_figure_style(gcf()) ;

% remove model path
rmpath(modelPath) ;