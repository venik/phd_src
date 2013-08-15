% get access to model
clc, clear all ;
curPath = pwd() ;
cd('..\\..\\model') ;
modelPath = pwd() ;
cd( curPath ) ;
addpath(modelPath) ;


init_rand(1) ;
phase_arg = 2*pi*0.3*(0:999) ;
s = 1*cos(phase_arg) ;
x = s + 8*randn(size(s)) ;

X = fft(x) ; 

X2 = X.*conj(X)/length(X) ;
X4 = X2.*X2/length(X) ;
X8 = X4.*X4/length(X) ;
X16 = X8.*X8/length(X) ;
plot(X16) ;
xlabel('Частота') ;
ylabel('Квадрат модуля спектра') ;
phd_figure_style(gcf) ;

% remove model path
rmpath(modelPath) ;