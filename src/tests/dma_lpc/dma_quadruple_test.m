clear all, clc, clf;

path_gnss = '../../gnss/' ;
path_model = '../tsim/model/' ;
addpath(path_gnss);
addpath(path_model);

fd= 16.368e6;		% 16.368 MHz
fs = 4.092e6;
N = 16368;
freq_delta = [2e3, 1e3, -1.5e3, 0.5e3];
ca_phase = [8184, 160, 320, 500];
prn = [1, 2, 3, 4] ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% prepare data

ms = 10;
DumpSize = ms*N;
snr = 1 ;

% Main satellite
x_ca16 = ca_get(prn(1), 0) ;
x_ca16 = repmat(x_ca16, ms + 1, 1);

base_sig = sin(2*pi*(fs + freq_delta(1))/fd*(0:length(x_ca16)-1)).' ;
Es = sum(base_sig .^ 2) / length(base_sig(:)) ; 
x = base_sig .* x_ca16 ;
x = x(ca_phase(1):DumpSize + ca_phase(1) - 1);

intf_error = zeros(length(x) , 1) ;

% interference
for k=2:3
    x_ca16_intf = ca_get(prn(k), 0) ;
    x_ca16_intf = repmat(x_ca16_intf, ms + 1, 1);
    base_sig_intf = 0.5 * sin(2*pi*(fs + freq_delta(k))/fd*(0:length(x_ca16)-1)).' ;
    intf = base_sig_intf .* x_ca16_intf ;
    intf_error = intf_error + intf(ca_phase(k):DumpSize + ca_phase(k) - 1);
end % k

En = Es * 10^(-snr/10) ;
wn = sqrt(En) * randn(DumpSize, 1);

sig = x + wn + intf_error ;		% variance = var(x) + sigma

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
acx = sqrt(acx .* conj(acx));

% [acx, ca_phase]
[peak, pos] = max(acx) ;
fprintf('E = %.2f\t pos=%d\n', peak, pos) ;
fprintf('var=%.2f std %.2f\n', var(acx), std(acx)) ;

plot(acx);
return ;

ca_dma = circshift(x_ca16(1:N), pos) ;
sig_after_dma = sig(1:N) .* ca_dma ;
%plot(sig_after_dma(1:100))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make me quadruple
X = fft(sig_after_dma) ;
X2 = zeros(4, length(X)) ;
X2(1, :) = X.*conj(X)/length(X) ;
X2(2, :) = X2(1, :).*X2(1, :)/length(X) ;
X2(3, :) = X2(2, :).*X2(2, :)/length(X) ;
X2(4, :) = X2(3, :).*X2(3, :)/length(X) ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AR model
freq = zeros(length(X2(:,1)), 1) ;

hold off, plot(repmat(fs + freq_delta(1), 1, length(freq))) ;

for k=1:length(freq)
    rxx = ifft(X2(k, :)) ;
    b = ar_model([rxx(1); rxx(2); rxx(3)]) ;
    [poles, omega0, Hjw0] = get_ar_pole(b) ;
    %omega = 0:0.02:pi ;
    %Hjw = 1.0./( -b(2)*exp(-2j*omega) - b(1)*exp(-1j*omega) + 1.0 ) ;
    freq(k) = omega0*fd/2/pi ;
end; % for

hold on, plot((1:k), freq, '-go') ;
title(sprintf('ОСШ: %d дБ', snr)) ;
xlabel('Оценка АКФ на шаге') ;
ylabel('Частота Гц') ;
legend('Частота сигнала', 'Оценка частоты')
phd_figure_style(gcf) ;

freq
%plot([freq, fs])
%    legend('Оценка', 'Истиное значение')
%phd_figure_style(gcf) ;
    
%fprintf('detected freq:%.2f\t CA position:%d\n', freq, pos) ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% END
rmpath(path_gnss);
rmpath(path_model);