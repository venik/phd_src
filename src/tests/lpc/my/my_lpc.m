clc, clear all, clf ;

f = 10 ;
fd = 100 ;
N = 10000 ;

x = sin(2*pi*f / fd * [0:N-1]) ;

%spec = fft(x);
%plot(spec .* conj(spec))
%plot(x)

rxx0 = x * x' / (length(x) - 1) ;
rxx1 = x * [x(2:end), x(1)]' / (length(x) - 1) ;
rxx2 = x * [x(3:end), x(1:2)]' / (length(x) - 1) ;

rxx = [rxx0, rxx1, rxx2] 

Rxx = [rxx(1) , rxx(2); rxx(2), rxx(1)]

% calculate coef
a = pinv(Rxx) * rxx(2:3)' 
a = [1;-a] 
poles = roots(a) 
freq = angle(poles(1)) 
    
Hjw = freqz(1,a) ;
[X,omega] = pwelch(x, 1000) ;

hold off, semilogy(omega,X.*conj(X), 'LineWidth',2);
hold on,semilogy(omega(1:numel(Hjw)),Hjw.*conj(Hjw),'r-','LineWidth',2), grid on
legend('signal spectrum', 'LPC')