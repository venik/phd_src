clc, clear all; clear;

addpath('../snr');

N = 1000000;
x_base = zeros(N,1);

%generate base data vector
x_binary = rand(1,N)>0.5;
x_base = 2.*x_binary - 1;

SNR  = 0:1:0;
err_num = zeros(length(SNR),1) ;
x_noise = zeros(N,1);

n = 1/sqrt(2)*randn(1,N);   % white gaussian noise, 0dB variance 

for k = 1:length(SNR)
	x_noise = awgn_my(x_base, SNR(k), 'measured');
	fprintf('mult from dsplog = %f\n', 10^(-SNR(k)/20));
	%x_noise = x_base + 10^(-SNR(k)/20)*n; % additive white gaussian noise
	
	x_receive = x_noise > 0;
	
	err_num(k) = size(find([x_binary-x_receive]),2);
%	for i=1:N
%		if( (x_base(i) * x_noise(i)) <= 0 )
%			err_num(k) = err_num(k)+1;
%		end;
%	end;
end;

% BER
err_num = err_num / N
simul = 0.5 * erfc(sqrt(10.^(SNR/10))/sqrt(2))


figure(1),
	hold off,
	plot(SNR, err_num, '-rx',SNR, simul, '-go'), ;
	grid on,
	xlim([SNR(1),SNR(end)]),
	axis([-3 10 10^-5 0.5]),
	title('My BER test');
