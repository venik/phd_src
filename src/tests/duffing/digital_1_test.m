function digital_1_test()

clc; clear all;

h = [0.0142
   -0.0004
   -0.0004
    0.0016
   -0.0003
    0.0016]

delta_t = 0.01;
t = 0:delta_t:500;
w = 1;
y = zeros(length(t), 1);

sigma = 1 ;
x = sigma * randn(length(t), 1) ;

gamma_x = 0.385 ;
x = gamma_x *  cos(w*t);

for k = 2:length(t)
    y(k) = h(1) + h(2) * x(k) + h(3) * x(k-1) + h(4) * x(k)^2 + h(5) * x(k) * x(k-1) + h(6) * x(k-1)^2;
end % for

var(y)