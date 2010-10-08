% signal
x = -10*pi:0.01:10*pi;
y = sin(x);
x1 = ceil(length(x)*0.1);
x2 = ceil(length(x)*0.9);
y(x1:x2) = y(x1:x2) .* (-1) ;

% bit
y_bit = ones(length(y), 1);
y_bit(x1:x2) = y_bit(x1:x2) .* 0 ;

figure(1),
subplot(2,1,1), plot(x,y), title('a)'), xlim([x(1), x(end)]), ylim([-1.1,1.1 ]), grid on,
subplot(2,1,2), plot(x, y_bit, 'r'), title('b)'), xlim([x(1), x(end)]), ylim([-0.1,1.1 ]), grid on,
figure (1, 'visible', 'on');
print -deps 'bpsk.eps'
