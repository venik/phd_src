% SNR tests

A = 1 ;
SNR =  -3	;			% in dB
x = 0:0.1:6*pi;
noise = zeros(length(x), 1);

y = (A .* sin(x));
y_n = awgn_my(y, SNR, 'measured');
%y_n = awgn_my(y, SNR);

%plot(x, y_n, 'r', x, y, 'g'), xlim([0,x(end)]);
figure(1), plot(x, y_n, 'r', x, y, 'g'), xlim([0,x(end)]);
%igure(2), plot(2*x+2, xcorr(y, y_n).^2);