clear all; clc;

addpath('../../gnss/');

fd= 16.368e6;		% 16.368 MHz
fs = 4.092e6;
freq_delta = 0;
N = 16368;
ca_phase = 1000;

ms = 10;
DumpSize = ms*N;

PRN = 1;

sigma = 3;

% generate signal
x_ca16 = ca_get(PRN, 0) ;
x_ca16 = repmat(x_ca16, ms + 1, 1);

x = cos(2*pi*(fs + freq_delta)/fd*(0:length(x_ca16)-1)).' ;
x = x .* x_ca16 ;		% variance = var(x) * var(x_ca16) = 0.5 * 1 = 0.5
x = x(ca_phase:DumpSize + ca_phase - 1);

wn = (sigma/sqrt(2)) * (randn(DumpSize, 1) + j * randn(DumpSize, 1));
signal = x + wn ;		% variance = var(x) + sigma
%signal = x;


fprintf('var(signal) = %.02f, var(x) = %.02f, var(x_ca16) = %.02f, var(wn) = %.02f \n', var(signal), var(x), var(x_ca16), var(wn));

% ===================================
tau = 32;
iteration = 1;
signal_dma = zeros(N,1);
for k=1:iteration
	signal_dma(1:N) = signal_dma(1:N) .+ signal((k-1)*N + 1: k*N) .* conj(signal((k-1)*N + 1 + tau: k*N + tau));
end

% var(cos())^2 + 2*var(cos())*sigma^2 + (sigma^2)^2
predicted_var = 0.5*0.5 + 2*0.5*(sigma^2) + (sigma^2)^2;
fprintf('estimated var(signal_dma) = %.03f predicted var(signal_dma) = %.03f\n', var(signal_dma), predicted_var);

% get new code
signal_dma = signal_dma;% ./ iteration;
NEW_CODE = fft(signal_dma);

% generate local replica of the new code
ca_new_tmp = x_ca16(1:N) .* x_ca16(1+tau : N+tau);
NEW_TMP = fft(ca_new_tmp);

% correlate
acx = ifft(NEW_TMP .* conj(NEW_CODE));
acx = acx .* conj(acx); % / 4092;

[res(2), res(1)] = max(acx);

fprintf('shift_ca = [%d] corr = %.02f mean(acx) = %.02f var(acx)=%.02f \n', res(1), res(2), mean(acx), var(acx));
plot(acx);

rmpath('../../gnss/');