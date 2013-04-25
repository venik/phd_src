% x - received signal x(n) = cos(w*(n+d))*CA(n+d)
% ca - ca code
% E - pole's energy
function [freq,E,Hjw_max,rxx_max] = lpcs(x,ca,signoise)
x = x(:) ;
ca = ca(:) ;
Dx = x'*x/(length(x)) ;
xx = x.*conj([x(2:end);x(1)]) ;
cc = ca.*[ca(2:end);ca(1)] ;
XX = fft(xx) ;
CC = fft(cc) ;
rx1 = ifft(XX.*conj(CC))/(length(CC)) ;
xx = x.*conj([x(3:end);x(1:2)]) ;
cc = ca.*[ca(3:end);ca(1:2)] ;
XX = fft(xx) ;
CC = fft(cc) ;
rx2 = ifft(XX.*conj(CC))/(length(CC)) ;
E = zeros(size(rx1)) ;
freq = zeros(size(rx1)) ;
max_E = 0 ;
Hjw_max = -1 ;
for k=1:16368
    if Dx>signoise
        rxx = [Dx-signoise;rx1(k);rx2(k)] ;
    else
        rxx = [Dx;rx1(k);rx2(k)] ;
    end
    Rxx = [rxx(1) rxx(2);conj(rxx(2)) rxx(1)] ;
    %b = pinv(Rxx-eye(2)*signoise)*rxx(2:end) ;
    b = pinv(Rxx)*rxx(2:end) ;
    %poles = roots([1;-b(1);-b(2)]) ;
    poles = roots([1;-b]) ;
    freq(k) = angle(poles(1)) ;
    
    %Hjw = freqz(1,b,16368) ;
    %E(k) = max(Hjw.*conj(Hjw)) ;
    Hjw_pole = 1/( -b(2)*exp(-2j*freq(k)) - b(1)*exp(-1j*freq(k)) + 1) ;
    E(k) = real(Hjw_pole*conj(Hjw_pole)) ;
    if E(k)>max_E
        max_E = E(k) ;
        Hjw_max = freqz(1,[-b(2), -b(1), 1],16368) ;
        rxx_max = rxx ;
    end
    %E(k) = poles(1)*conj(poles(1)) ;
end
