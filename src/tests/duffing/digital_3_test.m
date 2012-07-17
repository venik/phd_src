function digital_2_test()

clc; clear all;

h = [   -0.0025
 -354.4166
  354.9949
   -1.9505
    0.0097
    1.9698];

delta_t = 0.01;
t = 0:delta_t:500;
w = 1;
y = zeros(length(t), 1) ;
y_noise = zeros(length(t), 1) ;

% signal presented
gamma_x = 0.385 ;
x = gamma_x *  cos(w*t);

for k = 2:length(t)
    y(k) = h(1) + h(2) * x(k) + h(3) * x(k-1) + h(4) * x(k)^2 + h(5) * x(k) * x(k-1) + h(6) * x(k-1)^2;
end % for

% noise
sigma = 1 ;
x = sigma * randn(length(t), 1) ;

for k = 2:length(t)
    y_noise(k) = h(1) + h(2) * x(k) + h(3) * x(k-1) + h(4) * x(k)^2 + h(5) * x(k) * x(k-1) + h(6) * x(k-1)^2;
end % for

fprintf('Signal variance:\t\t%f\nNoise variance:\t\t\t%f\n', var(y), var(y_noise));