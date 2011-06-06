% SNR tests

addpath('../../gnss/');

PRN = 19 ;
delta = 500;

SNR = 1;
%sigma =  2.5;
sigma = sqrt(10^(-SNR/10));


ca_base = ca_generate_bits(PRN, 0);
ca_another = ca_generate_bits(1, 0);

ca_local = [ca_base] ;

signal = ca_local;
%signal_lo = signal;
signal_lo = ca_another;

noised_signal = [signal; signal];
noised_signal = noised_signal + sigma * randn(length(noised_signal), 1);

noised_signal = noised_signal(delta : length(ca_local) + delta - 1) ;

% fft convolution
S = fft(signal_lo);
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

%  snr magic
snr = 10*log10( (max_val - mean_val)^2 / std_val^2 );

fprintf('\n Real SNR = %.2f dB sigma = %d\n', 10*log10(1/sigma^2), sigma);

fprintf('max_val = %.2f in dB = %.2f phase:%03d\n', max_val, 10*log10(max_val),ca_phase);
fprintf('mean_val = %.2f in dB = %.2f\n', mean_val, 10*log10(mean_val));
fprintf('std_val = %.2f in dB = %.2f\n', std_val, 10*log10(std_val));
fprintf('Result = %.2f dB\n', snr);

plot(corr_array);

rmpath('../../gnss/');
