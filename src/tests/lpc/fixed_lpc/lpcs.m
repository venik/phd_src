% x - received signal x(n) = cos(w*(n+d))*CA(n+d)
% ca - ca code
% E - pole's energy
function [omega, ca_shift, E, Hjw_max] = lpcs(x,ca,signoise)
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
Hjw_max = -1 ;

for k=1:16368
    %rxx = [Dx;rx1(k);rx2(k)] ;
    %Rxx = [rxx(1) rxx(2);conj(rxx(2)) rxx(1)] ;
    %b = pinv(Rxx-eye(2)*signoise)*rxx(2:end) ;
    b = ar_model([Dx;rx1(k);rx2(k)]) ;
    
    [pole, omega0, Hjw0] = get_ar_pole(b) ;
    if Hjw0 > Hjw_max
        Hjw_max = Hjw0 ;
        omega = omega0 ;
        ca_shift = 16368 - k ;
    end ;
        
end
