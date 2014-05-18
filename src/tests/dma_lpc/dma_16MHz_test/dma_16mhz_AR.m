clear all, clc, clf;

path_gnss = '../../../gnss/' ;
path_model = '../../tsim/model/' ;
addpath(path_gnss);
addpath(path_model);

data_model = 0 ;
ms = 9 ;
N = 16368 ;
rays = 3 ;

ifsmp.sats = [32 2, 4] ;
ifsmp.delays = [5687, 300, 100] ;
ifsmp.fd = 16.368e6 ;

% get the data
if data_model == 1
    ifsmp.vars = [1, 1, 1] ;
    ifsmp.fs = [4.0923e6, 4.095e6, 4.090e6] ;
    ifsmp.fd = 16.368e6 ;
    ifsmp.snr_db = -20 ;
    
    [x, sig, sats, delays, signoise] = get_if_signal(ifsmp, ms, rays) ;
    fprintf('Model\n');
else    
    %sig_from_file = readdump_txt('../data/flush.txt', 20*N);	% create data vector
    %save('../data/flush.txt.mat', 'sig_from_file') ;
    load('../data/flush.txt.mat') ;
    sig = sig_from_file(2000:ms*N) ;
	fprintf('Real signal\n');
end ; % if model

% Main satellite
x_ca16 = ca_get(ifsmp.sats(1), 0) ;
x_ca16 = repmat(x_ca16, ms + 1, 1);

tau = 16;
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

%sig_filt_dma = filter(b, a, sig_dma) ;
sig_filt_dma = sig_dma ;

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
fprintf('sat: %02d\tE = %.2f\t pos=%d\n', ifsmp.sats(1), peak, pos) ;
%plot(acx); return ;

sig_cos = real(sig(1:N) .* x_ca16(pos : N + pos - 1)) ;
%plot(sig_cos(1:100)); return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make me quadruple
X = fft(sig_cos(1:N), N*4) ;
XX(1, :) = X.*conj(X) ;
XX8 = XX .^ 8 ./ 10e50 ;
rxx = ifft(XX8) ;
%plot(rxx(1:100)); return ;
%plot(abs(XX8)); return ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AR model
b = ar_model([rxx(1); rxx(2); rxx(3)]) ;
[poles, omega0, Hjw0] = get_ar_pole(b) ;
freq = ifsmp.fd * omega0 / (2*pi) ;

fprintf('freq:%03.05f\n', freq);

%semilogy(abs(fft(rxx(1:N))))
%    title(sprintf('ms: %d, ACF iteration: %d estimated freq: %.0f \n', ...
%        length(sig_after_dma) / N, acf_iteration, freq)) ;
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% END
rmpath(path_gnss);
rmpath(path_model);