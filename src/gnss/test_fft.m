clc; clear all; clf;

DumpSize = 16368*1 ;
N = 16368 ;
fs = 4.092e6-5e3 : 1e3 : 4.092e6+5e3 ;		% sampling rate 4.092 MHz
ts = 1/16.368e6 ;

model = 1;				% is it the model?
acx_res = zeros(4) ;		% [acx, ca_phase, freq, detected state]

%sigma = [0.01, 0.1, 1, 1.5, 2];
sigma = 0.01:0.1:2;
snr = 10 * log10(1./sigma);

detected = zeros(length(sigma), 1);
probability = zeros(length(sigma), 1);

fd = fopen('./results/test_fft.res', 'w+', 'ieee-le');

for k=1:length(sigma)
%for h=1:10
for h=1:1000
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

	% dump it
	probability(k) = detected(k) / h * 100;
	str = sprintf("%1.2f     %3.2f\n", snr(k), probability(k));
	fwrite(fd, str);
end	%for k=1

% results
probability = detected / h * 100;
for k=1:length(sigma)
	%fprintf('sigma:%f (SNR = %f)\tdetected = %d from i = %d\n', sigma(k), snr(k), detected(k), i);
	fprintf('SNR = %f \t probabilit = %3.2f\n', snr(k), probability(k));
end	%for k=1

fclose(fd);

plot(snr, probability),
	xlabel('SNR, dB'),
	ylabel('Probalility, %')
	title('Probability of detection');
