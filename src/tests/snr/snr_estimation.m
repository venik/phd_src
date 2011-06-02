% SNR tests

addpath('../../gnss/');

PRN = 19 ;
N=16368;
sigma = 0;
delta = 5000;

ca_base = ca_get(PRN, 0) ;
ca_local = [ca_base] ;

signal = ca_local .* cos(2*pi*0.25*[0:N-1]).';

noised_signal = [signal; signal];
noised_signal = noised_signal + sigma * randn(length(noised_signal), 1);

noised_signal = noised_signal(delta : N + delta - 1) ;

% fft convolution
S = fft(signal);
NS = fft(noised_signal);
corr_array = ifft(S .* conj(NS) );

% calculate energy
corr_array = corr_array .* conj(corr_array);

% calculate SNR
max_val = max(corr_array)
mean_val = mean(corr_array)
std_val = std(corr_array)

snr = 10*log10( (max_val - mean_val) / std_val );

fprintf('max_val = %.2f in dB = %.2f\n', max_val, 10*log10(max_val));
fprintf('mean_val = %.2f in dB = %.2f\n', mean_val, 10*log10(mean_val));
fprintf('std_val = %.2f in dB = %.2f\n', std_val, 10*log10(std_val));

fprintf('Result = %.2f\n', snr);


plot(corr_array);

%plot(noised_signal(1:100));

rmpath('../../gnss/');
