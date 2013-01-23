% x - received signal x(n) = cos(w*(n+d))*CA(n+d)
% ca - ca code
% E - pole's energy
function [freq, Hjw] = lpcs(x, ca, phase, signoise)
N = 16368 ;
ca = repmat(ca, 2, 1) ;
x = x .* ca(phase : N + phase - 1) ;
x = x' ;

%plot(fftshift(abs(ifft(fft(x) .* conj(fft(x)))))); pause ;

rxx0 = x * x' / (length(x) - 1) ;
rxx1 = x * [x(2:end), x(1)]' / (length(x) - 1) ;
rxx2 = x * [x(3:end), x(1:2)]' / (length(x) - 1) ;

rxx = [rxx0, rxx1, rxx2] ;
Rxx = [rxx(1) rxx(2); rxx(2) rxx(1)] ;

% calculate coef
%a = pinv(Rxx) * rxx(2:3)'  ;
a = pinv(Rxx - signoise) * rxx(2:3)' ;
a = [1;-a] ;
poles = roots(a) ; 
freq = angle(poles(1)) ; 

Hjw = freqz(1,a) ;
%[E, r_freq] = max(Hjw.*conj(Hjw)) ;

fprintf('freq:%8.2f\n', freq*16368/2/pi ) ;

[X,omega] = pwelch(x, 1000) ;
hold off, semilogy(omega,X.*conj(X), 'LineWidth',2);
hold on,semilogy(omega(1:numel(Hjw)),Hjw.*conj(Hjw),'r-','LineWidth',2), grid on
legend('signal spectrum', 'LPC'),
hold off; pause;

%     Rxx = [rxx(1) rxx(2);rxx(2) rxx(1)] 
%     %b = pinv(Rxx - signoise) * rxx(2:3) ;
%     b = pinv(Rxx) * rxx(2:3) ;
%     b = [1;-b] ;
%     poles = roots(b) ;
%     freq = angle(poles(1)) ;
%     Hjw = freqz(1,b) ;
%     E = max(Hjw.*conj(Hjw)) ;    
%     %poles(1) * conj(poles(1))
    
% x = x(:) ;
% ca = ca(:) ;
% Dx = x'*x/(length(x)-1) ;
% xx = x.*conj([x(2:end);x(1)]) ;
% cc = ca.*[ca(2:end);ca(1)] ;
% XX = fft(xx) ;
% CC = fft(cc) ;
% rx1 = ifft(CC .* conj(XX))/(length(CC)-1) ;
% xx = x.*conj([x(3:end);x(1:2)]) ;
% cc = ca.*[ca(3:end);ca(1:2)] ;
% XX = fft(xx) ;
% CC = fft(cc) ;
% rx2 = ifft(CC .* conj(XX))/(length(CC)-1) ;
% E = zeros(size(rx1)) ;
% freq = zeros(size(rx1)) ;
% max_E = 0 ;
% Hjw_max = -1 ;
% for k=1:16368
%     rxx = [Dx;rx1(k);rx2(k)] ;
%     Rxx = [rxx(1) rxx(2);conj(rxx(2)) rxx(1)] ;
%     b = pinv(Rxx-eye(2)*signoise)*rxx(2:end) ;
%     b = [1;-b] ;
%     poles = roots(b) ;
%     freq(k) = angle(poles(1)) ;
%     
%     Hjw = freqz(1,b) ;
%     E(k) = max(Hjw.*conj(Hjw)) ;
%     if E(k)>max_E
%         max_E = E(k) ;
%         Hjw_max = Hjw ;
%     end
%     %E(k) = poles(1)*conj(poles(1)) ;    
% end

%plot(E) ;
%[a, b] = max(E)