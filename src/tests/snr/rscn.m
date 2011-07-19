clc; clear all; clf;

addpath('../../gnss/');

fd= 16.368e6;		% 16.368 MHz
fs = 4.092e6;
N = 16368;
PRN = 1;
DumpSize = N * 2;
freq_delta = 0;
ca_phase = 8000;
sigma_low = 0.1:0.1:0.9;
sigma_high = 1:15;
sigma = [sigma_low, sigma_high];
estimated_sigma = zeros(length(sigma), 1);

for k=1:length(sigma)
	% make signal
	x_ca16 = ca_get(PRN, 0) ;
	x_ca16 = repmat(x_ca16, DumpSize/N + 1, 1);
	x = cos(2*pi*(fs + freq_delta)/fd*(0:length(x_ca16)-1)).' ;
	x = x .* x_ca16 ;
	x = x(ca_phase:DumpSize + ca_phase - 1);
	wn = (sigma(k)/sqrt(2)) * (randn(DumpSize, 1) + j * randn(DumpSize, 1));
	x = x + wn ;
	
	% test
	lo_ca = ca_get(PRN, 0) ;
	lo_ca = repmat(lo_ca, 2, 1);
	lo_sig = exp(j*2*pi*fs/fd*(0 : 2*N-1)).' ;
	
	x = x(1:N);
	lo_replica = lo_ca .* lo_sig;
	
	LO_SIG = fft(lo_replica(1:N));
	X = fft(x);
	
	acx = ifft(LO_SIG .* conj(X));
	corr_res = acx .* conj(acx);
	[max_val, est_ca_phase] = max(corr_res);
	
	%
	for_noise = x .* lo_replica(est_ca_phase : est_ca_phase + N - 1);
	
	acx_real = real(for_noise);
	Q_acc_2_real = mean(acx_real.^2);
	
	acx_imag = imag(for_noise);
	Q_acc_2_imag = mean(acx_imag.^2);
	
	estimated_sigma(k) = sqrt(Q_acc_2_real + Q_acc_2_imag);
	%plot(corr_res);
	%fprintf('real_sigma = %f \t estimated_sigma = %f\n', sigma, estimated_sigma);
end	% for k

plot(sigma, sigma, '-rx', sigma,estimated_sigma, '-go'),
	legend('real sigma', 'estimated sigma'),
	xlim([0, sigma(end)]),
	grid on;
print -djpeg 'rscn_sigma.jpg';

rmpath('../../gnss/');