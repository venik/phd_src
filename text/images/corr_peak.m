clc; clear all; clf;

addpath('../../src/gnss/');

trace_me = 0;
N = 1023;
PRN = 1;

res = zeros(11, N);
% get the CA
ca_bits = ca_generate_bits(PRN, trace_me) ;
ca_base = [ca_bits(500:end); ca_bits(1:499)];

% not paek for 3d
ca_bits = ca_generate_bits(PRN + 1, trace_me) ;
CA_local = fft(ca_bits);
CA = fft(ca_base);

ca = ifft(CA .* conj(CA_local));		% equal to circular correlation
ca = ca .* conj(ca);
ca = sqrt(ca);
res(1, :) = ca;
res(2, :) = [ca(2:end); ca(1:1)];
res(3, :) = [ca(3:end); ca(1:2)];
res(4, :) = [ca(4:end); ca(1:3)];
res(5, :) = [ca(5:end); ca(1:4)];
res(7, :) = [ca(7:end); ca(1:6)];
res(8, :) = [ca(8:end); ca(1:7)];
res(9, :) = [ca(9:end); ca(1:8)];
res(10, :) = [ca(10:end); ca(1:9)];
res(11, :) = [ca(11:end); ca(1:10)];

% algo
ca_bits = ca_generate_bits(PRN, trace_me) ;
ca_base = [ca_bits(500:end); ca_bits(1:499)];

CA_local = fft(ca_bits);
CA = fft(ca_base);

ca = ifft(CA .* conj(CA_local));		% equal to circular correlation
ca = ca .* conj(ca);
ca = sqrt(ca);
res(6, :) = ca;

if 0
	[xx, yy] = meshgrid(1:N, 1:11);
	figure(1),
		plot3(xx, yy, res, '.-'),
		ylabel('f', 'FontSize', 16),
		ylim([1, 11]),
		xlim([1, N]);

end 	% if 1

graphics_toolkit("gnuplot");
if 1
	figure(2),
		plot(1:N, res(6, :)),
		xlim([1, N]);
		%xlabel('\tau', 'FontSize', 32),
		xlabel('{\bf{bold}}'),
		ylabel('{\iy(t)}');
end 	% if 1
		
%print -depsc corr_peak.eps
%print -djpeg corr_peak.jpeg

rmpath('../../src/gnss/');