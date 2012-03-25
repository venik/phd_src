% x - received signal x(n) = cos(w*(n+d))*CA(n+d)
% ca - ca code
% E - pole's energy
function [freq,E] = acq_lpcs(x,ca)
x = x(:) ;
ca = ca(:) ;
Dx = x'*x/(length(x)-1) ;
xx = x.*conj([x(2:end);x(1)]) ;
cc = ca.*[ca(2:end);ca(1)] ;
XX = fft(xx) ;
CC = fft(cc) ;
rx1 = ifft(XX.*conj(CC))/(length(CC)-1) ;
xx = x.*conj([x(3:end);x(1:2)]) ;
cc = ca.*[ca(3:end);ca(1:2)] ;
XX = fft(xx) ;
CC = fft(cc) ;
rx2 = ifft(XX.*conj(CC))/(length(CC)-1) ;
E = zeros(size(rx1)) ;
freq = zeros(size(rx1)) ;
for k=1:16368
    rxx = [Dx;rx1(k);rx2(k)] ;
    Rxx = [rxx(1) rxx(2);conj(rxx(2)) rxx(1)] ;
    b = pinv(Rxx)*rxx(2:end) ;
    b = [1;-b] ;
    poles = roots(b) ;
    freq(k) = angle(poles(1)) ;
    E(k) = poles(1)*conj(poles(1)) ;
end
