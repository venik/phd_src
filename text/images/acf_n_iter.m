% get access to model
clc, clear all, clf ;
curPath = pwd() ;
cd('..\\..\\src\\tests\tsim\\model') ;
modelPath = pwd() ;
cd( curPath ) ;
addpath(modelPath) ;


init_rand(1) ;
phase_arg = 2*pi*(0:0.05:30) ;
s = 1*cos(phase_arg) ;
sigma = 16 ;
x = s + sqrt(sigma)*(randn(size(s))) ;

X = fft(x) ; 

X2 = zeros(4, length(X)) ;
X2(1, :) = X.*conj(X)/length(X) ;
X2(2, :) = X2(1, :).*X2(1, :)/length(X) ;
X2(3, :) = X2(2, :).*X2(2, :)/length(X) ;
X2(4, :) = X2(3, :).*X2(3, :)/length(X) ;

sig = zeros(length(X2(:,1)), length(X)) ;   

sig(1, :) = ifft(X2(1, :)) ;
sig(2, :) = ifft(X2(2, :)) ;
sig(3, :) = ifft(X2(3, :)) ;
sig(4, :) = ifft(X2(4, :)) ;


plot((sig(1,(2:120)))) ;
    xlabel('n') ;
    ylabel('r_{xx}(n)') ;
    phd_figure_style(gcf) ;

var(s)
var(sig(1,:))    
    
% remove model path
rmpath(modelPath) ;