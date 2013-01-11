% x - received signal x(n) = cos(w*(n+d))*CA(n+d)
% ca - ca code
% E - pole's energy
function [freq,E,Hjw_max] = lpcs(x,ca,signoise)
x = x(:) ;
ca = ca(:) ;
Dx = x'*x/(length(x)-1) ;
xx = x.*conj([x(2:end);x(1)]) ;
cc = ca.*[ca(2:end);ca(1)] ;
XX = fft(xx) ;
CC = fft(cc) ;
rx1 = ifft(CC .* conj(XX))/(length(CC)-1) ;
xx = x.*conj([x(3:end);x(1:2)]) ;
cc = ca.*[ca(3:end);ca(1:2)] ;
XX = fft(xx) ;
CC = fft(cc) ;
rx2 = ifft(CC .* conj(XX))/(length(CC)-1) ;
E = zeros(size(rx1)) ;
freq = zeros(size(rx1)) ;
max_E = 0 ;
Hjw_max = -1 ;
for k=1:16368
    rxx = [Dx;rx1(k);rx2(k)] ;
    Rxx = [rxx(1) rxx(2);conj(rxx(2)) rxx(1)] ;
    b = pinv(Rxx-eye(2)*signoise)*rxx(2:end) ;
    b = [1;-b] ;
    poles = roots(b) ;
    freq(k) = angle(poles(1)) ;
    
    Hjw = freqz(1,b) ;
    E(k) = max(Hjw.*conj(Hjw)) ;
    if E(k)>max_E
        max_E = E(k) ;
        Hjw_max = Hjw ;
    end
    %E(k) = poles(1)*conj(poles(1)) ;    
end

plot(E) ;
[a, b] = max(E)