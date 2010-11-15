addpath('../snr');

N = 1000000;
x_binary = rand(1,N)>0.5;
fc = 1;
Eb = 1;
T = 1;

%s = sqrt(2*Eb/T)*cos(2*pi*fc*(1:N) + pi*(1-x_binary));
s = 2*x_binary -1 + 0.0001j;
SNR  = -3:1:3;
err_num = zeros(length(SNR),1) ;
x_noise = zeros(N,1);

% noise part
for k = 1:length(SNR)
	x_noise = awgn_my(s, SNR(k), 'measured');
	x_receive = x_noise > 0;
	err_num(k) = size(find([x_binary-x_receive]),2);
end;

% BER
err_num = err_num / N
simul = 0.5 * erfc(sqrt(10.^(SNR/10)))

figure(1),
	hold off,
	plot(SNR, err_num, '-rx',SNR, simul, '-go'), ;
	grid on,
	xlim([SNR(1),SNR(end)]),
	axis([-3 10 10^-5 0.5]),
	title('My BER test');

figure(2),
	plot(1:20, s(1:20), '-rx', 1:20, x_noise(1:20), '-go', 1:20, x_receive(1:20), '-b'),
	grid on;