% SNR tests

addpath('../../gnss/');

PRN = 19 ;
N=16368;
sigma = 15;
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
[max_val, ca_phase] = max(corr_array);
mean_val = mean(corr_array);
std_val = std(corr_array);

snr = 10*log10( (max_val - mean_val) / std_val );

fprintf('\n Real sigma = %.2f dB sigma = %d\n', 10*log10(1/sigma^2), sigma);

fprintf('max_val = %.2f in dB = %.2f phase:%03d\n', max_val, 10*log10(max_val),ca_phase);
fprintf('mean_val = %.2f in dB = %.2f\n', mean_val, 10*log10(mean_val));
fprintf('std_val = %.2f in dB = %.2f\n', std_val, 10*log10(std_val));
fprintf('Result = %.2f\n', snr);


%%%%%%%%%%%%%%%%%%%%%%%%%
%%fprintf('\nWithout noise\n');
%fprintf('max_val = 66977856.00 in dB = 78.26\n');
%fprintf('mean_val = 47964.81 in dB = 46.81\n');
%fprintf('std_val = 949449.42 in dB = 59.77\n');
%fprintf('Result = 18.48\n');
%%%%%%%%%%%%%%%%%%%%%%%%%


%plot(corr_array);

%plot(noised_signal(1:100));

rmpath('../../gnss/');
