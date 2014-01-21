clc, clear ;
% get access to model
curPath = pwd() ;
cd('..\\..\\model') ;
modelPath = pwd() ;
cd( curPath ) ;
addpath(modelPath) ;

N = 1024 ;
phase0 = 2*pi*(0:N-1) ;
x = cos(phase0(:)*4092300/16368000) ;
x = x.*hann(N,'periodic') ;

lin_rxx = zeros(N,1) ;
circ_rxx = zeros(N,1) ;
for n=1:N
    lin_rxx(n) = x(1:end-(n-1)).'*x(1+(n-1):end)/(N-(n-1)) ;
    circ_rxx(n) = x.'*circshift(x,n-1)/N ;
end

lin_c = ar_model(lin_rxx) ;
circ_c = ar_model(circ_rxx) ;

[lin_pole, lin_omega0, lin_Hjw0] = get_ar_pole(lin_c) ;
[circ_pole, circ_omega0, circ_Hjw0] = get_ar_pole(circ_c) ;

[round(lin_omega0/2/pi*16368000), round(circ_omega0/2/pi*16368000)]

% remove model path
rmpath(modelPath) ;