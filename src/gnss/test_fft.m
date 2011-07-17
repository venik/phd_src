clc; clear all; clf;

DumpSize = 16368*6 ;
N = 16368 ;
fs = 4.092e6-5e3 : 1e3 : 4.092e6+5e3 ;		% sampling rate 4.092 MHz
ts = 1/16.368e6 ;

model = 1;				% is it the model?
acx_res = zeros(4) ;		% [acx, ca_phase, freq, detected state]

sigma = [0.01, 0.1, 1, 1.5, 2];

detected = zeros(length(sigma), 1);

for k=1:length(sigma)
for h=1:10
	x = signal_generate(	1,	\  %PRN
					1,	\  % freq delta in Hz
					1,	\  % CA phase
					sigma(k),	\  % noise sigma
					DumpSize);
					
	acx_res = acq_fft(x,
				1,		% PRN
				4.092e6,	% freq
				0);
	if(acx_res(4) == 1)
			detected(k) = detected(k) + 1;
	end;
end;	% for h=1
end	%for k=1

% results
snr = 10 * log10(1./sigma);
probability = detected / h * 100;
for k=1:length(sigma)
	%fprintf('sigma:%f (SNR = %f)\tdetected = %d from i = %d\n', sigma(k), snr(k), detected(k), i);
	fprintf('SNR = %f \t probabilit = %3.2f\n', SNR(k), probability(k));
end	%for k=1

plot(snr, probability),
	xlabel('SNR'),
	ylabel('Probalility, %')
	title('Probability of detection');