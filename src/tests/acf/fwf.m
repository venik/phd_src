% make Fourier matrix
clc, clear all%, clf ;
curPath = pwd() ;
cd('..\\tsim\\model') ;
modelPath = pwd() ;
cd( curPath ) ;
addpath(modelPath) ;

N = 32 ;
F = zeros(N) ;
for m=1:N
    for n=1:N
        F(m,n) = exp(-1j*2*pi/N*(m-1)*(n-1)) ;
    end
end
W = F*diag(hamming(N))*F' ;
hold off, plot(fftshift(real(W(5,:)))) ;
hold on, plot(fftshift(imag(W(5,:))),'m-.') ;

phd_figure_style(gcf)

% remove model path
rmpath(modelPath) ;