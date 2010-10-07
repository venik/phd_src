x = -10*pi:0.01:10*pi;
y = sin(x);
x1 = ceil(length(x)*0.1);
x2 = ceil(length(x)*0.9);

y(x1:x2) = y(x1:x2) .* (-1) ;
figure(1), plot(x,y), grid on;
%figure (1, 'visible', 'off');
print -deps 'bpsk.eps'
