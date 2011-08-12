%    Squared Signal-to-Noise Variance Estimator
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
% Reference: "Are C/N0 Algorithms Equivalent in All Situations?" Letizia Lo Prest et al
%	http://www.insidegnss.com/node/1826



clc; clear all; clf;

addpath('../../gnss/');

fd= 16.368e6;		% 16.368 MHz
fs = 4.092e6;
N = 16368;
PRN = 1;
DumpSize = N * 2;
freq_delta = 0;
ca_phase = 8000;

snr = -10:10;
%snr = -6;
%sigma = 1;

for k=1:length(snr)
%for k=1:length(sigma)
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
		%fprintf('real snr = %f in dB\n', snr(k));
	end; %if 1	
	% test
	lo_ca = ca_get(PRN, 0) ;
	lo_ca = repmat(lo_ca, 2, 1);
	lo_sig = exp(j*2*pi*fs/fd*(0 : 2*N-1)).';
	
	x = x(1:N);
	lo_replica = lo_ca .* lo_sig;
	
	LO_SIG = fft(lo_replica(1:N));
	X = fft(x);
	
	acx = ifft(LO_SIG .* conj(X));
	corr_res = acx .* conj(acx);
	[max_val, est_ca_phase] = max(corr_res);
	
	% SNR estimation
	for_noise = x .* lo_replica(ca_phase : ca_phase + N - 1);
	%for_noise = x .* lo_replica(est_ca_phase : est_ca_phase + N - 1);
	
	% signal power
	data = real(for_noise);
	Pd = mean(abs(data)) .^ 2;		% FIXME - why dont works
	%Pd = (sum(data(:)) / N) 
	
	% total power
	total_power = for_noise .* conj(for_noise);
	Ptot = sum(total_power) / N
	
	% estimated snr
	estimated_snr(k) = Pd / (Ptot - Pd);
	
	fprintf('snr = %f\n', estimated_snr(k));
	fprintf('snr = %f in dB real_snr = %d dB\n', 10*log10(estimated_snr(k)), snr(k));
	fprintf('C/A phase = %d real C/A phase = %d\n', ca_phase, est_ca_phase);
	estimated_snr(k)= 10*log10(estimated_snr(k));

end	% for k

plot(snr, snr, '-rx', snr, estimated_snr, '-go'),
	legend('real sigma', 'estimated sigma'),
	xlim([snr(1), snr(end)]),
	grid on;

rmpath('../../gnss/');