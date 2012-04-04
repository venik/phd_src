clc; clear all; clf;
addpath('../../gnss/');

PRN_range = 1;

debug_me = 0;

fd= 16.368e6;		% 16.368 MHz
fs = 4.092e6;
N = 16368;
iteration = 16;
DumpSize = iteration*N ;
model = 1;
		
% ========= generate =======================
if model
	PRN_mod = 1:5;
	freq_deltas = [1, 5, 10, 15, 20];
	ca_deltas = [1500, 100, 200, 500, 1];
	SNRs = [-30, -10, -10, -10, -10];

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
%lo_sig = exp(j*2*pi * fs/fd*(0 : iteration*N-1)).';
%x = x(1:iteration*N) .* lo_sig(1:iteration*N);

%x1 = zeros(N,1);
%x2 = zeros(N,1);
for k=1:2:iteration
	x1(1:N) = x( (k-1)*N + 1 : k*N);
	x2(1:N) = x( k*N + 1: (k+1)*N);
	
	X1 = fft(x1(1:N));
	X2 = fft(x2(1:N));

	x12 = ifft(X1 .* conj(X2));
	res = x12 .* conj(x12);
	res = sqrt(res);
end

res = res ./ iteration;

plot(res),
	xlim([1,N]);
	
%print -djpeg '/tmp/lpc_corr.jpg'
											
rmpath('../../gnss/');