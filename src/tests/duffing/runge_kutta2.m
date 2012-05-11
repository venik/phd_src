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

global gamma_x;
global gamma;
global delta_t;
global w;
global w_x;
global sigma;
global k;

% Duffing constants
gamma_x = 0.385 ;
gamma = 0.385;
w = 1  ;
k = 0.5;

%gamma_x = 3.5 ;
%gamma = 3.5 ;
%w = 2 ;
%k = 1 ;

%w_test = w-1:0.1:w+1 ;
%w_test = 0.1:0.1:3 ;
w_test = 1 ;

delta_t = 0.01;
t = 0:delta_t:200;
vars = zeros(length(w_test), 2);

% convert to SNR 10*log10(0.5/sigma)
sigma = 0;

for iter=1:length(w_test)
    
    % Incoming signal
    w_x = w_test(iter) ;
    
    % [x; x']
    x = zeros(length(t) + 1, 2) ;
    
    % Cauchy coditions
    x(1, :) = [1; 1];
    x(1, 2) = 1;

    for duff = 1:length(t)
        x(duff + 1, :) = step(t(duff), x(duff, :));
    end % for

    vars(iter) = var(x(:,1)) ;
    fprintf('Variance %f\n', vars(iter));

    if (length(w_test) < 2) 
        clf; plot(x(:,1),x(:,2)),
            xlabel('x'), ylabel('y'),
            grid on; %, hold on, comet(x(:,1),x(:,2));
    end
    
end % for iter

if (length(w_test) > 2) 
    clf; plot(w_test, vars), 
        xlabel('\omega'), ylabel('Variance'),
        grid on, hold on;
end

    
    
% Incoming parameters:
%   t - current time
%   x(1) - x
%   x(2) - x'
% Return parameters:
%   y(1) - y
%   y(2) - y'
function y = step(t, x)

global gamma_x;
global w_x;
global gamma;
global w;
global sigma;
global k;
global delta_t;

% calculate Runge-Kutta step
k1 =    gamma_x * cos(w*t) + ...
        gamma * cos(w*t) + ...
        sigma * randn(1) + ...
        x(1)^3 - x(1)^5 - ...
        k*x(2) ;
    
x_tmp = x(1) + x(2) * delta_t / 2 ;
x_der = x(2) + k1 / 2 ;
k2 =    gamma_x * cos(w_x * (t + delta_t / 2)) + ...
        gamma * cos(w * (t + delta_t / 2)) + ...
        sigma * randn(1) + ...
        x_tmp^3 - x_tmp^5 - ...
        k*x_der ;
    
x_tmp = x(1) + x(2) * delta_t / 2 + k1/4 * delta_t ;
x_der = x(2) + k2 / 2 ;
k3 =    gamma_x * cos(w_x * (t + delta_t / 2)) + ...
        gamma * cos(w * (t + delta_t / 2)) + ...
        sigma * randn(1) + ...
        x_tmp^3 - x_tmp^5 - ...
        k*x_der;
        
x_tmp = x(1) + x(2) * delta_t + k2/2 * delta_t;
x_der = x(2) + k3 ;
k4 =    gamma_x * cos(w_x * (t + delta_t)) + ...
        gamma * cos(w * (t + delta_t)) + ...
        sigma * randn(1) + ...
        x_tmp^3 - x_tmp^5 - ...
        k*x_der ;

y(1) = x(1) + delta_t * (x(2) + delta_t/6 * (k1 + k2 + k3)) ;
y(2) = x(2) + delta_t/6 * (k2 + 2*k2 + 2*k3 + k4) ;