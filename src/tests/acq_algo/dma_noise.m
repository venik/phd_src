clear all; clc;

addpath('../../gnss/');

fd= 16.368e6;		% 16.368 MHz
fs = 4.092e6;
freq_delta = 0;
N = 16368;
ca_phase = 1000;

ms = 10;
DumpSize = ms*N;

% test with 1 and many sat
num_of_sat = 8;
PRN = 1:num_of_sat;
freq_delta_once = 1;
freq_delta = repmat(freq_delta_once, 1, length(PRN));
ca_phase_once = 1;
ca_phase = repmat(ca_phase, 1, length(PRN));
	
snr_range = 5:20;
predicted_var = zeros(length(snr_range), 1) ;
esimated_var = zeros(length(snr_range), 1) ;
% for compataplity between 2 version
sigma_range = 1:length(snr_range);

%sigma_range = 1:10;
%sigma_range = 1;
%predicted_var = zeros(length(sigma_range), 1) ;
%esimated_var = zeros(length(sigma_range), 1) ;

for sigma = sigma_range
	% generate signal
if 0
	% old version	
	x_ca16 = ca_get(PRN, 0) ;
	x_ca16 = repmat(x_ca16, ms + 1, 1);
	
	x = exp(j*2*pi*(fs + freq_delta)/fd*(0:length(x_ca16)-1)).' ;
	p = sum(abs(x(:)) .^ 2) / length(x(:))
	x = x .* x_ca16 ;
	x = x(ca_phase:DumpSize + ca_phase - 1);
		
	wn = (sigma/sqrt(2)) * (randn(DumpSize, 1) + j * randn(DumpSize, 1));
	signal = x + wn ;		% variance = var(x) + sigma
	%signal = x;
	
	fprintf('var(signal) = %.02f, var(x) = %.02f, var(x_ca16) = %.02f, var(wn) = %.02f \n', ...
		var(signal), var(x), var(x_ca16), var(wn));
	fprintf('mean(signal) = %.02f\n', mean(signal));
else
	snr_for_range = repmat(snr_range(sigma), 1, length(PRN));
	signal = signal_generate(PRN, freq_delta, ca_phase, snr_for_range, DumpSize, 0);
	fprintf('var(signal) = %.02f\n', var(signal));
end
	% ===================================
	
	tau = 32;
	iteration = 1;
	signal_dma = zeros(N,1);
	for k=1:iteration
		signal_dma(1:N) = signal_dma(1:N) + signal((k-1)*N + 1: k*N) .* conj(signal((k-1)*N + 1 + tau: k*N + tau));
	end
	
	%predicted_var(sigma) = 10*log10(2*(sigma^2) + (sigma^2)^2);
	% var(signal) - var(carrier * C/A)
	%esimated_var(sigma) = 10*log10(var(signal_dma) - 1);
	esimated_var(sigma) = var(signal_dma) - 1;
	noise = 1 / (10^(snr_range(sigma)/10));
	predicted_var(sigma) = noise^2 + 2*noise;
    
    if (length(sigma_range) < 2)
        fprintf('estimated var(signal_dma) = %.03f predicted var(signal_dma) = %.03f\n', ...
            esimated_var, predicted_var);
    end
	
	% get new code
	%signal_dma = signal_dma;% ./ iteration;
	%NEW_CODE = fft(signal_dma);
	
	% generate local replica of the new code
	%ca_new_tmp = x_ca16(1:N) .* x_ca16(1+tau : N+tau);
	%NEW_TMP = fft(ca_new_tmp);
	
	% correlate
	%acx = ifft(NEW_TMP .* conj(NEW_CODE));
	%acx = acx .* conj(acx); % / 4092;
	
	%[res(2), res(1)] = max(acx);
	
	%fprintf('shift_ca = [%d] corr = %.02f mean(acx) = %.02f var(acx)=%.02f \n', res(1), res(2), mean(acx), var(acx));
	%plot(acx);
	
end		% for sigma = 1

if 0
plot(sigma_range, predicted_var, '-ro', sigma_range, esimated_var, '-g*'),
	grid on,
	legend('   ', '  '),
	 xlim([sigma_range(1), sigma_range(end)]),
	 xlabel('     DMA'),
	 ylabel('     DMA ()');
else
	plot(sigma_range, predicted_var, '-ro', sigma_range, esimated_var, '-g*'),
	grid on;
	legend('Predicted variance of the noise', 'Estimated variance of the noise'),
	title(sprintf('DMA noise characteristic for %d satellites', num_of_sat)),
	xlim([sigma_range(1), sigma_range(end)]),
	xlabel('SNR'),
	ylabel('DMA noise characteristic');
end

%print -djpeg '/tmp/dma_noise.jpg'

rmpath('../../gnss/');