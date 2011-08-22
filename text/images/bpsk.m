clc; clear all; clf;

Fs = 4;
Fd = 16;
N = 36;

bits = [1, 1, 1, -1, 1, 1, -1, 1, 1];
bits_resample = zeros(N, 1);
%resample
for k = 1:N/Fs
	for g = 1:Fd/Fs
	bits_resample( (k -1)*Fs + g) = bits(k);
	end	% for g
end	% for k

x = cos(2*pi * Fs/Fd * [0:N-1]);
x = x .* bits_resample';

plot(0:0.25:8.75, x)
	xlim([0,8.75]),
	xlabel('t',  'FontSize', 16),
	grid on;
	
print -depsc bpsk.eps

