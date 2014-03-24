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
exp1 = exp(1j*2*pi*f1/fs*(0:2*N-1)) ;
s1 = a1*exp1;
s2 = a2*exp(1j*2*pi*f2/fs*(0:2*N-1)) ;

s1 = c1.*s1.' ;
s2 = s2.*c2.' ;
s1 = s1(:) ;
s2 = s2(:) ;

s2 = circshift(s2, tau_s2) ;
noise = sqrt(sigma) * randn(length(s1), 1) ;

x = s1 + s2 +  noise ;

%%%%%%%%%%%%%%%%
% clean up noise
%x_new = x.* conj(c1 .* exp1.');
x_new = x.* conj(exp1.');
plot(abs(fft(x_new)))
return
%%%%%%%%%%%%%%%%%%%%%%
% 4.092 - 1.023 ~ 3Mhz
% 3/16.368 = 0.1833
F = [0 0.1 0.183 1] ;
A = [0 0 1 1] ;
b = firls(100, F, A);

if 0
    for i=1:2:4, 
       plot([F(i) F(i+1)],[A(i) A(i+1)],'--go'), hold on
    end
    [H,f] = freqz(b,1,512,2);
    plot(f,abs(H), '-rx'), grid on, hold off
    legend('Ideal','firls Design');
end

%x_new_filt = filter(b, 1, x_new) ;
x_new_restore = x_new_filt.* conj(c1 .* exp1.');

s2_new = x_new_restore .* circshift(c2, tau_s2) ;

plot(abs(fft(s2_new)))
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%hist(abs(noise), 100),
%    title(sprintf('tau_s2 = %d', tau_s2));

% remove model path
rmpath(modelPath) ;