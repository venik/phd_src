clc; clear all; clf;

addpath('../../src/gnss/');

trace_me = 0;

DumpSize = 16368 ;
N = 16368 ;
fs = 4.092e6-5e3 : 1e3 : 4.092e6+5e3 ;		% sampling rate 4.092 MHz
fd = 16.368e6;
ts = 1/fd ;

time_offs = 8000;

x = signal_generate(	1,	\  %PRN
				1,	\  % freq delta in Hz
				time_offs,	\  % CA phase
				10,	\  % snr, dB
				DumpSize);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
X = fft(x);
ca_base = ca_get(1, trace_me);		% generate C/A code

res = zeros(length(fs), N);

for k = 1:length(fs)
	fprintf('stage %d\n', k);
	
	lo_sig = exp(j*2*pi * (fs(k)/fd)*(0:N-1)).';
	CA = fft(lo_sig .* ca_base);

	ca = ifft(CA .* conj(X));		% equal to circular correlation
	ca = ca .* conj(ca);
	ca = sqrt(ca);
	
	res(k, :) = ca;
end % for k = 1:length(FR)

res = res';

if 1
	[xx, yy] = meshgrid(fs, 1:N);
	figure(1),
		clf,
		xlabel('f'),
		ylabel('C/A'),
		ylim([fs(1), fs(end)]),
		xlim([1, N]),
		surf(xx, yy, res, res);
end 	% if 1
graphics_toolkit("gnuplot");
if 1
	plot(1:N, res(:, 6));
		xlabel("Фаза ПСП"),
		xlim([1, N]),
end 	% if 1
		
%print -depsc corr_peak.eps
%print -djpeg corr_peak.jpeg

rmpath('../../src/gnss/');