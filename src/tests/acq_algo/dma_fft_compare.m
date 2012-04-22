clear all; clc;

addpath('../../gnss/');

fd = 16.368e6;		% 16.368 MHz
fs = 4.092e6;
N = 16368;
ca_phase = 1000;

tau = 32;

ms = 5;
DumpSize = ms*N;

% test with 1 and many sat
num_of_sat = 1;
PRN = 1:num_of_sat;
freq_delta_once = 1;
freq_delta = repmat(freq_delta_once, 1, length(PRN));
ca_phase_once = 1;
ca_phase = repmat(ca_phase, 1, length(PRN));
	
%snr_range = 5:20;
snr_range = 5:6;
predicted_var = zeros(length(snr_range), 1) ;
esimated_var = zeros(length(snr_range), 1) ;

snr_fft = zeros(length(snr_range), 1);
snr_dma = zeros(length(snr_range), 1) ;

for sigma = 1:length(snr_range)
	% generate signal
if 1
	% old version	
	x_ca16 = ca_get(PRN, 0) ;
	x_ca16 = repmat(x_ca16, ms + 1, 1);
	
	x = exp(j*2*pi*(fs + freq_delta)/fd*(0:length(x_ca16)-1)).' ;
	p = sum(abs(x(:)) .^ 2) / length(x(:)) ;
	x = x .* x_ca16 ;
	x = x(ca_phase:DumpSize + ca_phase - 1);
		
	wn = (sigma/sqrt(2)) * (randn(DumpSize, 1) + j * randn(DumpSize, 1));
	%signal = x + wn ;		% variance = var(x) + sigma
	signal = x;
	
	%fprintf('var(signal) = %.02f, var(x) = %.02f, var(x_ca16) = %.02f, var(wn) = %.02f \n', ...
	%	var(signal), var(x), var(x_ca16), var(wn));
	%fprintf('mean(signal) = %.02f\n', mean(signal));
else
	snr_for_range = repmat(snr_range(sigma), 1, length(PRN));
	signal = signal_generate(PRN, freq_delta, ca_phase, snr_for_range, DumpSize, 0);
	%fprintf('var(signal) = %.02f\n', var(signal));
end
	% ===================================

    % Noise estimation
    signal_noise = zeros(N,1);
	signal_noise(1:N) = signal(1: N) .* conj(signal(1 + tau: N + tau));
	esimated_var(sigma) = 10*log10(1 / (var(signal_noise) - 1));
	noise = 1 / (10^(snr_range(sigma)/10));
    predicted_var(sigma) = 10*log10(1 / ((noise + num_of_sat)^2 - 1));
    
    if (length(snr_range) < 2)
        fprintf('estimated var(signal_dma) = %.03f predicted var(signal_dma) = %.03f\n', ...
            esimated_var, predicted_var);
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % For noise
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    lo_sig = exp(j*2*pi * fs/fd)*(0:2*N-1).';
   	ca = ca_get(PRN(1), 0) ;
   	ca = repmat(ca, 2, 1);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % FFT signal
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	CA = fft(lo_sig(1:N) .* ca(1:N));
  	x = signal(1:N) ;
    X = fft(x);
	acx_f = ifft(CA .* conj(X));		% equal to circular correlation
	acx_f = sqrt(acx_f .* conj(acx_f));
    %var_f = var(acx_f);
    [max_f, pos_f] = max(acx_f);
    
    fprintf('fft sig: max = %f phase_ca = %d\n', max_f, pos_f);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % FFT noise
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    x = wn(1:N) ;
    X = fft(x) ;
    acx_f = ifft(CA .* conj(X));		% equal to circular correlation
	acx_f = sqrt(acx_f .* conj(acx_f));
    var_f = var(acx_f);
    fprintf('fft noise: var = %f\n', var_f) ;
    fprintf('fft: Eps / Epn = %f\n', max_f^2/var_f) ;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % DMA signal
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	iteration = 1;
    signal_dma = zeros(N,1);
    % increase SNR
	for k=1:iteration
		signal_dma(1:N) = signal_dma(1:N) + signal((k-1)*N + 1: k*N) .* conj(signal((k-1)*N + 1 + tau: k*N + tau));
    end
    % get new code
	signal_dma = signal_dma ./ iteration;
    NEW_CODE = fft(signal_dma);
	% generate local replica of the new code
	ca_new_tmp = ca(1:N) .* ca(1 + tau : N + tau);
	NEW_TMP = fft(ca_new_tmp);
	% correlate
	acx_d = ifft(NEW_TMP .* conj(NEW_CODE));
	acx_d = sqrt(acx_d .* conj(acx_d));
	[max_d, pos_d] = max(acx_d);

    fprintf('dma sig: max = %f phase_ca = %d\n', max_d, pos_d);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % FFT noise
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    iteration = 1;
    signal_dma = zeros(N,1);
    % increase SNR
	for k=1:iteration
		signal_dma(1:N) = signal_dma(1:N) + wn((k-1)*N + 1: k*N) .* conj(signal((k-1)*N + 1 + tau: k*N + tau));
    end
    % get new code
	signal_dma = signal_dma ./ iteration;
    NEW_CODE = fft(signal_dma);
	% generate local replica of the new code
	ca_new_tmp = ca(1:N) .* ca(1 + tau : N + tau);
	NEW_TMP = fft(ca_new_tmp);
	% correlate
	acx_d = ifft(NEW_TMP .* conj(NEW_CODE));
	acx_d = sqrt(acx_d .* conj(acx_d));
    var_d = var(acx_d);

    fprintf('dma noise: var = %f\n', var_d) ;
    fprintf('dma: Edmas / Edman = %f\n', max_d^2/var_d) ;
    
    %plot(acx_d), pause;
	
end		% for sigma = 1

if 0
figure(1),
    plot(snr_range, predicted_var, '-ro', snr_range, esimated_var, '-g*'),
    grid on,
    legend('Predicted variance of the noise', 'Estimated variance of the noise', ...
            'Location', 'SouthEast'),
    title(sprintf('DMA SNR characteristic for %d satellites', num_of_sat)),
    xlim([snr_range(1), snr_range(end)]),
    xlabel('SNR'),
    ylabel('DMA SNR characteristic');

figure(2), plot(snr_range, snr_fft, '-rx', snr_range, snr_dma, '-g*'),
    grid on,
    legend('FFT', 'DMA', 'Location', 'SouthEast'),
    title('SNR after correlator in FFT and DMA algorithm'),
    xlabel('SNR before correlator'),
    ylabel('SNR after correlator');
end

%print -djpeg '/tmp/dma_noise.jpg'

rmpath('../../gnss/');