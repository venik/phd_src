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
a2 = 1:-0.1:0.1 ;
%a2 = 0.4;
sigma = 0 ;
tau_s2 = 2400 ;
tau = 64 ;
sig_length = 2*N-1 ;

c1 = get_ca_code16( 1023, 1) ;
c2 = get_ca_code16( 1023, 2) ;

c1 = repmat(c1, 2, 1) ;
c2 = repmat(c2, 2, 1) ;

res_a1a2 = zeros(length(a2), 1) ;

for kk=1:length(a2)
    s1 = a1*exp(1j*2*pi*f1/fs*(0:sig_length)) ;
    s2 = a2(kk)*exp(1j*2*pi*f2/fs*(0:sig_length)) ;

    s1 = c1.*s1.' ;
    s2 = s2.*c2.' ;
    s1 = s1(:) ;
    s2 = s2(:) ;

    s2 = circshift(s2, tau_s2) ;
    noise = sqrt(sigma) * randn(length(s1), 1) ;

    x = s1 + s2 +  noise ;

    xx = x(1:N) .* conj(x(tau : tau + N - 1)) ;
    XX = fft(xx) ;

    c2_new = c2(1:N) .* c2( 1 + tau : N + tau) ;
    C2_NEW = fft(c2_new) ;

    res = ifft(XX .* conj(C2_NEW)) ;
    res = res .* conj(res) ;
    
    [res_val, res_pos] = max(res) ;
    
    if((res_pos > 2400 + 8) || (res_pos < 2400 - 8))
        % fprintf('%0.2f: miss\n', a2(kk)) ;
        res_a1a2(kk) = 0 ;
    else
        res_a1a2(kk) = 10*log10(res_val / std(res)) ;
    end; % if 
    
end % kk=1:length(a2)

base_line = repmat(7, 1, length(res_a1a2));
a2_dB = 10*log10(1./a2) ;

plot(a2_dB, res_a1a2, '-rx', a2_dB, base_line),
    legend('max / std', '7dB line') ;
    xlabel('A1/A2 dB')

%plot(res)

% remove model path
rmpath(modelPath) ;