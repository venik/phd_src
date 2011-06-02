% SNR tests

addpath('../../gnss/');

PRN = 19 ;
sigma = 0;
delta = 1;

ca_base = ca_generate_bits(PRN, 0);
ca_local = [ca_base] ;

signal = ca_local;

noised_signal = [signal; signal];
noised_signal = noised_signal + sigma * randn(length(noised_signal), 1);

noised_signal = noised_signal(delta : length(ca_local) + delta - 1) ;

% fft convolution
S = fft(signal);
NS = fft(noised_signal);
corr_array = ifft(S .* conj(NS) );

% calculate energy
corr_array = corr_array .* conj(corr_array);

%test
corr_array = sqrt(corr_array);

[max_val, ca_phase] = max(corr_array);
%std_val = var(corr_array);			% here var bcoz I got sqrt() from corr_array
std_val = std(corr_array);			% here var bcoz I got sqrt() from corr_array
mean_val = mean(corr_array);

fprintf('phase: %03d max_val = %.2f\n', ca_phase, max_val);
fprintf('after spreading std_val = %.2f before = %.2f\n', std_val, var(noised_signal));
fprintf('after spreading mean = %.2f before = %.2f\n', mean_val, mean(noised_signal));

% snr magic
snr = 10*log10( (max_val - mean_val) / std_val );
fprintf('Result = %.2f dB\n', snr);


plot(corr_array);

rmpath('../../gnss/');
