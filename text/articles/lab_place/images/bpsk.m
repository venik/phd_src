% signal
x = -10*pi:0.01:10*pi;
y = sin(x);
x1 = ceil(length(x)*0.1);
x2 = ceil(length(x)*0.9);
y(x1:x2) = y(x1:x2) .* (-1) ;

% bit
y_bit = ones(length(y), 1);
y_bit(x1:x2) = y_bit(x1:x2) .* (-1) ;


figure(1), , grid on;
subplot(2,1,1), plot(x,y), title('a)')
subplot(2,1,2), plot(x, y_bit, 'r'), title('b)'), ylim([-1.5,1.5 ]);
%figure (1, 'visible', 'off');
print -deps 'bpsk.eps'
