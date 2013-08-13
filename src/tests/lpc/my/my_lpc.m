clc, clear all, clf ;

f = 30 ;
fd = 100 ;
N = 1000 ;

sigma = 5 ;
noise = sqrt(sigma) * randn(1,N) ;
sig = sin(2*pi*f / fd * [0:N-1]) ;

x = sig + noise ;  

%spec = fft(x);
%plot(spec .* conj(spec))
%plot(x)

rxx0 = x * x' / (length(x) - 1) ;
rxx1 = x * [x(2:end), x(1)]' / (length(x) - 1) ;
rxx2 = x * [x(3:end), x(1:2)]' / (length(x) - 1) ;

rxx = [rxx0, rxx1, rxx2];

Rxx = [rxx(1) , rxx(2); rxx(2), rxx(1)] ;

% calculate coef
a = pinv(Rxx) * rxx(2:3)'  ;
a = [1;-a] ;
poles = roots(a) ;
freq = angle(poles(1)) ;
    
fprintf('Error estimation %.02f\n', 0.36635/(0.5/sigma)^0.31 ) ;
fprintf('est freq: %.02f\t true freq: %d\n', freq*fd/2/pi, f) ;
    
Hjw = freqz(1,a) ;
[X,omega] = pwelch(x, 1000) ;

hold off, semilogy(omega,X.*conj(X), 'LineWidth',2);
hold on,semilogy(omega(1:numel(Hjw)),Hjw.*conj(Hjw),'r-','LineWidth',2), grid on
legend('Welch spectrum estimation', '2rd order AR model')