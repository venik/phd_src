clear all, clc;

addpath('../../gnss/');
addpath('../tsim/model/');

fd= 16.368e6;		% 16.368 MHz
fs = 4.092e6;
N = 16368;
freq_delta = [2e3, 1e3, -1.5e3, 0.5e3];
ca_phase = [1, 160, 320, 500];
prn = [1, 2, 3, 4] ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% prepare data

ms = 10;
DumpSize = ms*N;
snr = -30:2:-8 ;
times = 1000 ;

% Main satellite
x_ca16 = ca_get(prn(1), 0) ;
x_ca16 = repmat(x_ca16, ms + 1, 1);

base_sig = sin(2*pi*(fs + freq_delta(1))/fd*(0:length(x_ca16)-1)).' ;
Es = sum(base_sig .^ 2) / length(base_sig(:)) ; 
x = base_sig .* x_ca16 ;
x = x(ca_phase(1):DumpSize + ca_phase(1) - 1);

thr = Es/2 ;        % Pfalse = Pmiss

intf_error = zeros(length(x) , 1) ;

% interference
for k=2:-1
    x_ca16_intf = ca_get(prn(k), 0) ;
    x_ca16_intf = repmat(x_ca16_intf, ms + 1, 1);
    base_sig_intf = 0.5 * sin(2*pi*(fs + freq_delta(k))/fd*(0:length(x_ca16)-1)).' ;
    intf = base_sig_intf .* x_ca16_intf ;
    intf_error = intf_error + intf(ca_phase(k):DumpSize + ca_phase(k) - 1);
end % k

corr_miss = zeros(length(snr), 1) ;
corr_false = zeros(length(snr), 1) ;
dma_miss = zeros(length(snr), 1) ;
dma_false = zeros(length(snr), 1) ;

init_rand(1) ;

for kk=1:length(snr)
    fprintf('current SNR:%d\n', snr(kk)); 
    
    En = Es * 10^(-snr(kk)/10) ;
    
    for dd=1:times
        wn = sqrt(En) * randn(DumpSize, 1);

        sig = x + wn + 0*intf_error ;		% variance = var(x) + sigma

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Correlator
        
        acx_corr_sig = sum(sig(1:N) .* (base_sig(1:N) .* x_ca16(1:N))) / N ;
        % miss
        if abs(acx_corr_sig) <= thr
            corr_miss(kk) = corr_miss(kk) + 1 ;
        end ;
            
        acx_corr_noise = sum(wn(1:N) .* (base_sig(1:N) .* x_ca16(1:N))) / N ;
        % false
        if abs(acx_corr_noise) > thr
            corr_false(kk) = corr_false(kk) + 1 ;
        end ;

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % DMA

        tau = 64;
        iteration = 1;
        sig_dma = zeros(N,1);
        noise_dma = zeros(N,1);

        for k=1:iteration
            sig_dma = sig_dma + ... 
                   sig((k-1)*N + 1: k*N) .* sig((k-1)*N + 1 + tau: k*N + tau);
               
            noise_dma = noise_dma + ... 
                   wn((k-1)*N + 1: k*N) .* wn((k-1)*N + 1 + tau: k*N + tau);
        end

        sig_dma = sig_dma ./ iteration ;
        noise_dma = noise_dma ./ iteration ;

        Fnyq = fd/2 ;               % Nyquist freq
        Fc=Fnyq/2 ;                 % cut-off freq [Hz]
        [b,a]=butter(2, Fc/Fnyq);

        ca_new_tmp = x_ca16(1:N) .* x_ca16(1+tau : N+tau);

        
        sig_filt_dma = filter(b, a, sig_dma) ;
        noise_filt_dma = filter(b, a, noise_dma) ;

        acx_dma_sig = sum(sig_filt_dma(1:N) .* ca_new_tmp(1:N)) / N ;
        % miss
        if abs(acx_dma_sig) <= thr
            dma_miss(kk) = dma_miss(kk) + 1 ;
        end ;
        
        acx_dma_noise = sum(noise_filt_dma(1:N) .* ca_new_tmp(1:N)) / N ;
        % false
        if abs(acx_dma_noise) > thr
            dma_false(kk) = dma_false(kk) + 1 ;
        end ;

    end ;
    
    corr_false(kk) = corr_false(kk) / times ;
    corr_miss(kk) = corr_miss(kk) / times ;
    dma_false(kk) = dma_false(kk) / times ;
    dma_miss(kk) = dma_miss(kk) / times ;
    
    fprintf('snr = %d\n', snr(kk)) ;
    fprintf('CORR:\tMiss:%.3f\tFalse:%.3f\n', corr_miss(kk), corr_false(kk)) ;
    fprintf('DMA:\tMiss:%.3f\tFalse:%.3f\n', dma_miss(kk), dma_false(kk)) ;
    
end % for kk=1:length(snr)

figure(1),
    plot(snr, corr_false, snr, dma_false),
    legend('Correlator', 'DMA'),
    title('False detection') ,
    xlabel('SNR dB'),
    ylabel('Probability'),
    phd_figure_style(gcf) ;

figure(2),
    plot(snr, corr_miss, snr, dma_miss),
    legend('Correlator', 'DMA'),
    title('Miss signal') ,
    xlabel('SNR dB'),
    ylabel('Probability'),
    phd_figure_style(gcf) ;