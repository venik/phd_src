clc; clear all; clf;

addpath('../../gnss/');

PRN = 19 ;
N=16368;
snr =  15;
DumpSize = N * 200;

x = signal_generate(	1,	\  %PRN
				1,	\  % freq delta in Hz
				1,	\  % CA phase
				snr,	\  
				DumpSize);

iteration = 50;

WBP = zeros(iteration, 1);
NBP = zeros(iteration, 1);

for k=0 : iteration-1
	x_lo = x(k*N + 1 : (k+1) * N);
	WBP(k+1) = sum( x_lo .* conj(x_lo));
	NBP(k+1) = sum(real(x_lo))^2 + sum(imag(x_lo))^2;
end	% for k

mu = 1/iteration * sum(NBP ./ WBP);
r = 1/0.01 * (mu -1)/(2-mu)
				
rmpath('../../gnss/');