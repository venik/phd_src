% Copyright (C)
%   2012 Alex Nikiforov  nikiforov.alex@rf-lab.org
%	2012 Alexey Melnikov  melnikov.alexey@rf-lab.org
%
% Solve Duffing attractor with Runge-Kutta
% x'' + kx' - x^3 + x^5 = gamma*cos(wt) + gamma_x*cos(w_x*t) + n
% (gamma_x*cos(w_x*t) + n) - incominf signal
% GPLv3
function runge_kutta()
clc;

global gamma;
global delta_t;
global w;
global k;

%gamma = 0.77;
%delta_t = 0.01;
%w = 1;
%k = 0.5;

gamma = 94 ;
w = 5;
k = 1.29;

delta_t = 0.01;
t = 0:delta_t:150;
x = zeros(length(t) + 1, 2) ;
x(1, 1) = 1;
x(1, 2) = 1;

for iter = 1:length(t)
    x(iter + 1, :) = step(t(iter), x(iter, :));
end % for

clf; plot(x(:,1),x(:,2)), 
    xlabel('x'), ylabel('y'),
    grid on; %, hold on, comet(x(:,1),x(:,2));

% Incoming parameters:
%   t - current time
%   x(1) - x
%   x(2) - x'
% Return parameters:
%   y(1) - y
%   y(2) - y'
function y = step(t, x)

global gamma;
global w;
global k;
global delta_t;

% calculate Runge-Kutta step
k1 =    gamma * cos(w*t) + ...
        x(1)^3 - x(1)^5 - ...
        k*x(2) ;
    
x_tmp = x(1) + x(2) * delta_t / 2 ;
x_der = x(2) + k1 / 2 ;
k2 =    gamma * cos(w * (t + delta_t / 2)) + ...
        x_tmp^3 - x_tmp^5 - ...
        k*x_der ;
    
x_tmp = x(1) + x(2) * delta_t / 2 + k1/4 * delta_t ;
x_der = x(2) + k2 / 2 ;
k3 =    gamma * cos(w * (t + delta_t / 2)) + ...
        x_tmp^3 - x_tmp^5 - ...
        k*x_der;
        
x_tmp = x(1) + x(2) * delta_t + k2/2 * delta_t;
x_der = x(2) + k3 ;
k4 =    gamma * cos(w * (t + delta_t)) + ...
        x_tmp^3 - x_tmp^5 - ...
        k*x_der ;

y(1) = x(1) + delta_t * (x(2) + delta_t/6 * (k1 + k2 + k3)) ;
y(2) = x(2) + delta_t/6 * (k2 + 2*k2 + 2*k3 + k4) ;