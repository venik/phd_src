clc; clear all; clf;

range_cos = pi/2:0.01:5*pi/2;
x = cos(range_cos);
x_inv = -x;
x_res = [x,x,x,x_inv,x_inv,x_inv,x,x,x];

plot(x_res),
	xlim([1, length(x_res)]),
	xlabel('t',  'FontSize', 16),
	grid on;
	
print -depsc bpsk.eps
