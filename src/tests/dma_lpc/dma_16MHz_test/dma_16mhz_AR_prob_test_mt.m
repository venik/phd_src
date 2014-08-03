clear all, clc;

path_gnss = '../../../gnss/' ;
path_model = '../../tsim/model/' ;
addpath(path_gnss);
addpath(path_model);

ms = 32 ;
N = 16368 ;
rays = 3 ;

ifsmp.sats = 30 ;
ifsmp.fd = 16.368e6 ;
base_freq = 4.094e6 ;

step = 100 ;
base_point = 2000 ;

tau = 16;
iteration = 8 ;
kk = 0 ;
kk_detected = 0 ;

% sig_from_file = readdump_txt('../data/flush.txt', 32*N);	% create data vector
% save('../data/flush.txt.mat', 'sig_from_file') ;

% load sig_from_file array
load('../data/flush.txt.mat') ;
array_size = length(sig_from_file) ;

% Main satellite
x_ca16 = ca_get(ifsmp.sats(1), 0) ;
x_ca16 = repmat(x_ca16, ms + 1, 1) ;

variance = 0 ;

for i = 0:5000
    
    point = base_point + i * step ;
    if (point + iteration * N > array_size)
        fprintf('end of array, iteration: %d\n', kk) ;
        break ;
    end;
    
    sig = sig_from_file(point : ms*N) ;

    sig_dma = zeros(N,1);
    for k=1:iteration
        sig_dma = sig_dma + ... 
               sig((k-1)*N + 1: k*N) .* sig((k-1)*N + 1 + tau: k*N + tau);
    end

    sig_dma = sig_dma ./ iteration;

    %Fnyq = ifsmp.fd/2 ;       % Nyquist freq
    %Fc=Fnyq/2 ;             % cut-off freq [Hz]
    %[b, a]=butter(2, Fc/Fnyq);

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
    %fprintf('sat: %02d\tE = %.2f\t pos=%d\n', ifsmp.sats(1), peak, pos) ;
    %plot(acx); return ;

    sig_cos = real(sig(1:N) .* x_ca16(pos : N + pos - 1)) ;
    %plot(sig_cos(1:100)); return;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Make me quadruple
    sig_ar = sig_cos(1:N) ;
    %sig_ar = sig_cos(1:N) .* hann(N, 'periodic') ;
    %sig_ar = sig_cos(1:N) .* hamming(length(N)) ;
    %sig_ar = sig_cos(1:N) .* blackman(length(N)) ;

    
    X = fft(sig_ar, N * 4) ;
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

    %fprintf('sat: %02d freq: %03.05f pos=%d\n', ifsmp.sats(1), freq, pos) ;
    
    if (abs(freq - base_freq) < 1e3)
        fprintf('sat: %02d freq: %03.05f pos=%d\n', ifsmp.sats(1), freq, pos) ;
        kk_detected = kk_detected + 1 ;
        variance = variance + (freq - base_freq)^2 ;
    else
        %fprintf('sat: %02d freq: %03.05f pos=%d\n', ifsmp.sats(1), freq, pos) ;
        %pause;
    end;
    
    kk = kk + 1;
    
end; % for()

variance = variance / kk_detected ;

fprintf('sat: %02d probability:%.02f var:%.02f\n', ifsmp.sats(1), 100*kk_detected / kk, variance) ;

%semilogy(abs(fft(rxx(1:N))))
%    title(sprintf('ms: %d, ACF iteration: %d estimated freq: %.0f \n', ...
%        length(sig_after_dma) / N, acf_iteration, freq)) ;
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% END
rmpath(path_gnss) ;
rmpath(path_model) ;