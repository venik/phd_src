clc, clear, clf ;
% get access to model
curPath = pwd() ;
cd('..\\tsim\\model') ;
modelPath = pwd() ;
cd( curPath ) ;
addpath(modelPath) ;

N = 16368 ;
fs = 16.368e6 ;

f1 = 4.092e6;
f2 = 4.095e6;
a1 = 1 ;
a2 = 1 ;
sigma = 0 ;
tau_s2 = 24 ;
tau = 64 ;

c1 = get_ca_code16( 1023, 1) ;
c2 = get_ca_code16( 1023, 2) ;

c1 = repmat(c1, 2, 1) ;
c2 = repmat(c2, 2, 1) ;
s1 = a1*exp(1j*2*pi*f1/fs*(0:2*N-1)) ;
s2 = a2*exp(1j*2*pi*f2/fs*(0:2*N-1)) ;

s1 = c1.*s1.' ;
s2 = s2.*c2.' ;
s1 = s1(:) ;
s2 = s2(:) ;

s2 = circshift(s2, tau_s2) ;
noise = sqrt(sigma) * randn(length(s1), 1) ;

x = s1 + s2 +  noise ;

xx = x(1:N) .* conj(x(tau : tau + N - 1)) ;
s1s2 = s1(1:N) .* conj(s2(tau : tau + N - 1)) ;
s2s1 = s2(1:N) .* conj(s1(tau : tau + N - 1)) ;
s1s1 = s1(1:N) .* conj(s1(tau : tau + N - 1)) ;
s2s2 = s2(1:N) .* conj(s2(tau : tau + N - 1)) ;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
colormap(gray),
subplot(3,1,1), hold on, plot(1:N, abs(fft(xx)), 'k'), title('1', 'FontSize', 18) ,
    plot(1023, 1:100:2200, '--kx', N-1023, 1:100:2200, '--kx') ,
    xlim([1 16368]),
    h_legend = legend('1.1', '1.2');
    set(h_legend, 'FontSize', 18),
    grid on,
    hold off,


%subplot(3,1,2), hold on, plot(1:N, abs(fft(xx .* c1(1:N))), '-r'), title('xx') ,
subplot(3,1,2), hold on, plot(1:N, abs(fft(s1s2)), 'k'), title('2', 'FontSize', 18) ,
    plot(1023, 1:100:2200, '--kx', N-1023, 1:100:2200, '--kx') ,
    xlim([1 16368]),
    h_legend = legend('2.1', '2.2');
    set(h_legend, 'FontSize', 18),
    grid on,
    hold off,


subplot(3,1,3), hold on, plot(1:N, abs(fft(s2s2 + s1s1)), 'k'), title('3', 'FontSize', 18) ,
    plot(1023, 1:100:2200, '--kx', N-1023, 1:100:2200, '--kx') ,
    xlim([1 16368]),
    h_legend = legend('3.1', '3.2');
    set(h_legend, 'FontSize', 18),
    grid on,
    hold off,

% remove model path
rmpath(modelPath) ;