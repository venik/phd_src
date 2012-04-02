clc; clear all; clf;
addpath('../../gnss/');

PRN_range = 1;

debug_me = 0;

fd= 16.368e6;		% 16.368 MHz
fs = 4.089e6;
N = 16368;
millisecs = 5;
DumpSize = N*millisecs ;
model = 0;
		
% ========= generate =======================
if model
	PRN_mod = 1:5;
	freq_deltas = [1, 5, 10, 15, 20];
	ca_deltas = [1500, 100, 200, 500, 1 ];
	SNRs = [-10, -10, -10, -10, -10];

	x = signal_generate(
		PRN_mod,	\  %PRN
		freq_deltas,	\  % freq delta in Hz
		ca_deltas,	\  % CA phase
		SNRs,	\  % SNR
		DumpSize,
		debug_me);


	fprintf('Generated\n');
else
	%x = readdump_txt('./data/flush.txt', DumpSize);	% create data vector
	x = readdump_bin_2bsm('../../gnss/data/flush.bin', DumpSize);
	fprintf('Real\n');
end
% ========= generate =======================		
lo_sig = exp(j*2*pi * fs/fd*(0 : 10*N-1)).';

%x = x(1:millisecs*N) .* lo_sig(1:millisecs*N);

iteration = 2;
x1 = zeros(N,1);
x2 = zeros(N,1);
for k=1:iteration
	x1(1:N) = x1(1:N) .+ x((k-1)*N + 1: k*N);
	x2(1:N) = x2(1:N) .+ x(k*N + 1: (k+1)*N);
end

x1 = x1 ./ iteration;
x2 = x2 ./ iteration;

X1 = fft(x1(1:N));
X2 = fft(x2(1:N));

x12 = ifft(X1 .* conj(X2));
res = x12 .* conj(x12);
res = sqrt(res);

plot(res);
							
rmpath('../../gnss/');