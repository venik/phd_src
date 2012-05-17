% Copyright (C)
%   2012 Alex Nikiforov  nikiforov.alex@rf-lab.org
%	2012 Alexey Melnikov  melnikov.alexey@rf-lab.org
%
% article by Abolfazl Jalilvand and Hadi Fotoohabadi
% The Application of Duffing Oscillator in Weak Signal Detection
%
% x'' + 0.5x' - x^3 + x^5 = gamma*cos(wt) + gamma_x*cos(w_x*t) + n
% (gamma_x*cos(w_x*t) + n) - incoming signal
%
% GPLv3
function runge_kutta()
clc;

global gamma ;
global gamma_x ;
global delta_t ;
global w ;
global w_x ;
global k ;
global sigma ;
global phi ;

gamma = 0.825 ;
w = 1;
k = 0.5;

gamma_x = 0;
w_x = 1 ;
sigma = 8;
phi = 0;

delta_t = 0.0002;
t = 0:delta_t:200;
x = zeros(length(t) + 1, 2) ;
x(1, 1) = 1;
x(1, 2) = 1;

for iter = 1:length(t)
    x(iter + 1, :) = step(t(iter), x(iter, :));
end % for

clf; 
    figure(1); plot(x(:,1),x(:,2)), 
    xlabel('x'), ylabel('y'),
    grid on; %, hold on, comet(x(:,1),x(:,2));

spectrum = fft(x(:, 1));
spectrum = spectrum .* conj(spectrum);
figure(2); plot(spectrum), grid on;
    
    
% Incoming parameters:
%   t - current time
%   x(1) - x
%   x(2) - x'
% Return parameters:
%   y(1) - y
%   y(2) - y'
function y = step(t, x)

global gamma ;
global gamma_x ;
global delta_t ;
global w ;
global w_x ;
global k ;
global sigma ;
global phi ;

noise = sigma * randn(1) ;

% calculate Runge-Kutta step
k1 =    gamma * cos(w*t) + ...
        gamma_x * cos(w_x*t + phi) + noise + ...
        x(1)^3 - x(1)^5 - ...
        k*x(2) ;
    
x_tmp = x(1) + x(2) * delta_t / 2 ;
x_der = x(2) + k1 / 2 ;
k2 =    gamma * cos(w * (t + delta_t / 2)) + ...
        gamma_x * cos(w_x * (t + delta_t / 2) + phi) + noise + ...
        x_tmp^3 - x_tmp^5 - ...
        k*x_der ;
    
x_tmp = x(1) + x(2) * delta_t / 2 + k1/4 * delta_t ;
x_der = x(2) + k2 / 2 ;
k3 =    gamma * cos(w * (t + delta_t / 2)) + ...
        gamma_x * cos(w_x * (t + delta_t / 2) + phi) + noise + ...
        x_tmp^3 - x_tmp^5 - ...
        k*x_der;
        
x_tmp = x(1) + x(2) * delta_t + k2/2 * delta_t;
x_der = x(2) + k3 ;
k4 =    gamma * cos(w * (t + delta_t)) + ...
        gamma_x * cos(w_x * (t + delta_t) + phi) + noise + ...
        x_tmp^3 - x_tmp^5 - ...
        k*x_der ;

y(1) = x(1) + delta_t * (x(2) + delta_t/6 * (k1 + k2 + k3)) ;
y(2) = x(2) + delta_t/6 * (k2 + 2*k2 + 2*k3 + k4) ;