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
a2 = 1:-0.025:0.1 ;
sigma = 0 ;
tau_s2 = 2400 ;
tau = 64 ;
sig_length = 2*N-1 ;
times = 1000 ;

c1 = get_ca_code16( 1023, 1) ;
c2 = get_ca_code16( 1023, 2) ;

c1 = repmat(c1, 2, 1) ;
c2 = repmat(c2, 2, 1) ;

res_a1a2 = zeros(length(a2), 1) ;
match = zeros(length(a2), 1) ;

for kk=1:length(a2)
    
    fprintf('%d from %d\n', kk, length(a2));
    
    for jj=1:times
        s1 = a1*exp(1j*2*pi*f1/fs*(0:sig_length)) ;
        s2 = a2(kk)*exp(1j*2*pi*f2/fs*(0:sig_length)) ;

        s1 = c1.*s1.' ;
        s2 = s2.*c2.' ;
        s1 = s1(:) ;
        s2 = s2(:) ;

        tau_s2 = round(rand() * 16368 + 8) ;
        
        % adjust corner cases
        if (tau_s2 < 9)
            tau_s2 = tau_s2 + 8;
        elseif (tau_s2 > (16368-8))
            tau_s2 = tau_s2 - 8;
        end;
        
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

        if((res_pos > tau_s2 + 8) || (res_pos < tau_s2 - 8))
            %fprintf('%0.2f: miss real tau:%d est tau:%d\n', a2(kk), tau_s2, res_pos) ;
            res_a1a2(kk) = 0 ;
        else
            match(kk) = match(kk) + 1 ;
            res_a1a2(kk) = res_a1a2(kk) + 10*log10(res_val / std(res)) ;
        end; % if 
    end % jj
    
    res_a1a2(kk) = res_a1a2(kk) / times ;
    match(kk) = match(kk) / times ;
end % kk=1:length(a2)

base_line = repmat(7, 1, length(res_a1a2));
a2_dB = 10*log10(a2./a1) ;

figure(1),
    semilogy(a2_dB, 1 - match, '-kx'),
    ylabel('Âåðîÿòíîñòü îøèáêè'),
    xlabel('ÎÑØ äÁ', 'FontSize', 18),
    phd_figure_style(gcf) ;

figure(2)
semilogy(a2_dB, res_a1a2, '-kx', a2_dB, base_line, '-ko'),
    h_legend = legend('1', '2') ;
    set(h_legend, 'FontSize', 18),
    xlabel('ÎÑØ äÁ', 'FontSize', 18),
    ylabel('Ìàêñ/ÑÊÎ äÁ', 'FontSize', 18),
    phd_figure_style(gcf) ;

%plot(res)

% remove model path
%rmpath(modelPath) ;