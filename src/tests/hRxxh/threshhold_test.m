% test of the threshold tsui page 111

%clc; clear all;

N = 16368 ;
k = 4.092e6;		% 4.092 MHz

noise_real = randn(N, 1);
noise_real(noise_real<-0.5) = -6;
noise_real((noise_real<0) & (noise_real>-1)) = -2;
noise_real(noise_real>0.5) = 6;
noise_real(noise_real>0 & noise_real<1) = 2;
noise_imag = randn(N, 1);
noise_imag(noise_imag<-0.5) = -6;
noise_imag(noise_imag<0 & noise_imag>-1) = -2;
noise_imag(noise_imag>0.5) = 6;
noise_imag(noise_imag>0 & noise_imag<1) = 2;

noise = noise_real + j*noise_imag;

A = sqrt(noise .* conj(noise));

mean(A)
var(A)

hist(A);


%sigma = 0.2;

%noise = sigma*randn(N, 1) + sigma*j*randn(N, 1);
%x = exp(j * (2*pi/N) * k * (0:N-1)) .+ noise';

%X = sum(x .* exp(-j * (2*pi/N) * k * (0:N-1)));

%A = sqrt(real(X)^2 + imag(X)^2)