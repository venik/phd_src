%    Real signal complex noise (RSCN) noise estimator
%    Copyright (C) 2010 Alex Nikiforov  nikiforov.alex@rf-lab.org
%
%    This program is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.

%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.

%    You should have received a copy of the GNU General Public License
%    along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
% Reference:	Brad Badke "Carrier to-Noise Density and AI for INS/GPS Integration", InsideGNSS magazine, pp 20-29, september/october 2009.
%			http://www.insidegnss.com/node/1637
%			http://www.insidegnss.com/auto/sepoct09-gnss-sol.pdf

clc; clear all; clf;

addpath('../../gnss/');

fd= 16.368e6;		% 16.368 MHz
fs = 4.092e6;
N = 16368;
PRN = 1;
DumpSize = N * 2;
freq_delta = 0;
ca_phase = 8000;
%sigma_low = 0.1:0.1:0.9;
%sigma_high = 1:15;
%sigma = [sigma_low, sigma_high];
sigma = 5;
snr = -6:6;
estimated_sigma = zeros(length(sigma), 1);
estimated_snr = zeros(length(snr), 1);
%for k=1:length(sigma)
for k=1:length(snr)
	% make signal
	if 0
		x_ca16 = ca_get(PRN, 0) ;
		x_ca16 = repmat(x_ca16, DumpSize/N + 1, 1);
		x = cos(2*pi*(fs + freq_delta)/fd*(0:length(x_ca16)-1)).' ;
		x = x .* x_ca16 ;
		x = x(ca_phase:DumpSize + ca_phase - 1);
		wn = (sigma(k)/sqrt(2)) * (randn(DumpSize, 1) + j * randn(DumpSize, 1));
		x = x + wn ;
		
		fprintf('real snr = %f and %f in dB\n', 0.5/sigma^2, 10*log10(0.5/sigma^2));
	else
		x = signal_generate(PRN, freq_delta, ca_phase, snr(k), DumpSize, 1);
		fprintf('real snr = %f in dB\n', snr);
	end; %if 1
		
	
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
	
	% SNR estimation
	for_noise = x .* lo_replica(est_ca_phase : est_ca_phase + N - 1);
	
	%acx_real = real(for_noise);
	%Q_acc_2_real = mean(acx_real.^2);
	
	acx_imag = imag(for_noise);
	%Q_acc_2_imag = mean(acx_imag.^2);
	acx_imag = acx_imag.^2;
	Q_acc_2_imag = sum(acx_imag(1:end)) / N;
	
	total_power = for_noise .* conj(for_noise);
	total_power = sum(total_power(1:end)) / N;
	estimated_snr(k) = (total_power - 2*Q_acc_2_imag) / (2*Q_acc_2_imag);
	fprintf('snr = %f and snr = %f in dB\n', estimated_snr(k), 10*log10(estimated_snr(k)));
	estimated_snr(k)= 10*log(estimated_snr(k));

	%estimated_sigma(k) = sqrt(Q_acc_2_real + Q_acc_2_imag);
	%estimated_sigma(k) = sqrt(2*Q_acc_2_imag);
	
	%plot(corr_res);
	%fprintf('real_sigma = %f \t estimated_sigma = %f\n', sigma, estimated_sigma);
end	% for k

%plot(sigma, sigma, '-rx', sigma,estimated_sigma, '-go'),
plot(snr, snr, '-rx', snr, estimated_snr, '-go'),
	legend('real sigma', 'estimated sigma'),
	xlim([snr(1), snr(end)]),
	grid on;
%print -djpeg 'rscn_sigma.jpg';

rmpath('../../gnss/');