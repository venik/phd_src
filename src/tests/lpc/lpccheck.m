clc, clear ;
% analysis order 
P = 4 ; % tunable parameter

N = 1024 ;
fs1 = 50 ;
fs2 = 330 ;
fd = 1000 ;
x = cos(2*pi*fs1/fd*(0:N-1)) + sin(2*pi*fs2/fd*(0:N-1)) + randn(1,N)*.1 ;
% tf: Y(z)/H(z)=1/(1-z^(-1)*b(1)-z^(-2)*b(2)...)
[b,poles] = lpcmodel(x,P) ;
fprintf('Detected frequencies list:\n') ;
for k=1:length(poles)
    fprintf('%8.3f\n',angle(poles(k))*fd/2/pi) ;
end

[H,freq]=freqz(1,b) ;
plot(freq/2/pi*fd,H.*conj(H)), grid on ;