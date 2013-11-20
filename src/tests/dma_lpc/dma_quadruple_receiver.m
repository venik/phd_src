clear all, clc, clf;

path_gnss = '../../gnss/' ;
path_model = '../tsim/model/' ;
addpath(path_gnss);
addpath(path_model);

data_model = 0 ;
ms = 10 ;
N = 16368 ;

% get the data
if data_model == 1
    ifsmp.sats = [31, 2, 3] ;
    ifsmp.vars = [1, 1, 1] ;
    ifsmp.fs = [4.092e6, 4.095e6, 4.090e6] ;
    ifsmp.fd = 16.368e6 ;
    ifsmp.delays = [5000, 300, 100] ;
    ifsmp.snr_db = -10 ;
    
    [x, sig, sats, delays, signoise] = get_if_signal(ifsmp, ms) ;
else
    ifsmp.sats = 31 ;
    ifsmp.fd = 16.368e6 ;
    
    sig = readdump_txt('./data/flush.txt', ms*N);	% create data vector
	fprintf('Real\n');
end ; % if model

% Main satellite
x_ca16 = ca_get(ifsmp.sats(1), 0) ;
x_ca16 = repmat(x_ca16, ms + 1, 1);

tau = 64;
iteration = 8 ;
sig_dma = zeros(N,1);
for k=1:iteration
    sig_dma = sig_dma + ... 
           sig((k-1)*N + 1: k*N) .* sig((k-1)*N + 1 + tau: k*N + tau);
end

sig_dma = sig_dma ./ iteration;

Fnyq = ifsmp.fd/2 ;       % Nyquist freq
Fc=Fnyq/2 ;             % cut-off freq [Hz]
[b,a]=butter(2, Fc/Fnyq);

sig_filt_dma = filter(b, a, sig_dma) ;

%plot([sig_dma(1:100), sig_filt_dma(1:100)])

SIG_FILT_DMA = fft(sig_filt_dma);

% generate local replica of the new code
ca_new_tmp = x_ca16(1:N) .* x_ca16(1+tau : N+tau);
CA_NEW_TMP = fft(ca_new_tmp);

% correlate
acx = ifft(CA_NEW_TMP .* conj(SIG_FILT_DMA));
acx = sqrt(acx .* conj(acx));

% [acx, ca_phase]
[peak, pos] = max(acx) ;
fprintf('E = %.2f\t pos=%d\n', peak, pos) ;

%fprintf('var=%.2f std %.2f\n', var(acx), std(acx)) ;
%plot(acx); return ;

ca_dma = circshift(x_ca16(1:N), 2506) ;
%ca_dma = circshift(x_ca16(1:N), pos) ;
sig_after_dma = real(sig(1:N) .* ca_dma) ;
%plot(sig_after_dma(1:100))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make me quadruple
X = fft(sig_after_dma) ;
%X2 = zeros(4, length(X)) ;
X2(1, :) = X.*conj(X)/length(X) ;
X2(2, :) = X2(1, :).*X2(1, :)/length(X) ;
X2(3, :) = X2(2, :).*X2(2, :)/length(X) ;
X2(4, :) = X2(3, :).*X2(3, :)/length(X) ;
X2(5, :) = X2(4, :).*X2(3, :)/length(X) ;
X2(6, :) = X2(5, :).*X2(3, :)/length(X) ;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AR model
rxx = ifft(X2(4, :)) ;
b = ar_model([rxx(1); rxx(2); rxx(3)]) ;
[poles, omega0, Hjw0] = get_ar_pole(b) ;
freq = omega0*ifsmp.fd/2/pi 

pwelch(ifft(X2(6, :)), 4092) ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% END
rmpath(path_gnss);
rmpath(path_model);