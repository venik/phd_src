clear all, clc, clf;

addpath('../../gnss/');
addpath('../tsim/model/');

fd= 16.368e6;		% 16.368 MHz
fs = 4.092e6;
freq_delta = 0;
N = 16368;
ca_phase = 8184;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% prepare data

ms = 10;
DumpSize = ms*N;
snr = -15 ;

x_ca16 = ca_get(1, 0) ;
x_ca16 = repmat(x_ca16, ms + 1, 1);

base_sig = sin(2*pi*(fs + freq_delta)/fd*(0:length(x_ca16)-1)).' ;
Es = sum(base_sig .^ 2) / length(base_sig(:)) ; 
x = base_sig .* x_ca16 ;
x = x(ca_phase:DumpSize + ca_phase - 1);

En = Es * 10^(-snr/10) ;
wn = sqrt(En) * randn(DumpSize, 1);

sig = x + wn ;		% variance = var(x) + sigma

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DMA

tau = 64;
iteration = 1;
sig_dma = zeros(N,1);
for k=1:iteration
    sig_dma = sig_dma + ... 
           sig((k-1)*N + 1: k*N) .* sig((k-1)*N + 1 + tau: k*N + tau);
end

sig_dma = sig_dma ./ iteration;

Fnyq = fd/2 ;       % Nyquist freq
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
acx = acx .* conj(acx);

% [acx, ca_phase]
[peak, pos] = max(sqrt(acx)) ;

%fprintf('E = %.2f\t pos=%d\n', peak, pos);
%plot(acx);


ca_dma = circshift(x_ca16(1:N), pos) ;
sig_after_dma = sig(1:N) .* ca_dma ;
%plot(sig_after_dma(1:100))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make me quadruple
X = fft(sig_after_dma) ;  
X2 = X.*conj(X)/length(X) ;
X4 = X2.*X2/length(X) ;
X8 = X4.*X4/length(X) ;
X16 = X8.*X8/length(X) ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AR model
rxx = ifft(X16) ;
b = ar_model([rxx(1); rxx(2); rxx(3)]) ;
[poles, omega0, Hjw0] = get_ar_pole(b) ;
omega = 0:0.02:pi ;
Hjw = 1.0./( -b(2)*exp(-2j*omega) - b(1)*exp(-1j*omega) + 1.0 ) ;

freq = omega0*fd/2/pi ;

hold off, pwelch(base_sig, 4096) ;
hold on, pwelch(sig, 4096) ;
hold on, pwelch(sig_after_dma, 4096) ;
hold on, plot(omega/pi,10*log10(Hjw.*conj(Hjw)),'-.') ;

ylabel('Спектральная плотность dB/rad/отсчет') ;
xlabel('Нормализованная частота \pi/rad/отсчет') ;
title('')
legend( 'СПМ исходного сигнала', ...
        'СПМ входного сигнала', ...
        'СПМ сигнала после снятия ПСП', ...
        'Частотный отклик АР-модели') ;
phd_figure_style(gcf) ;
    
fprintf('snr:%d dB\t detected freq:%.2f\t CA position:%d\n', ...
        snr, freq, pos) ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% END
rmpath('../../gnss/');
rmpath('../tsim/model/');