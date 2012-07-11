% Copyright (C)
%   2012 Alex Nikiforov  nikiforov.alex@rf-lab.org
%	2012 Alexey Melnikov  melnikov.alexey@rf-lab.org
%
% http://www.math.tamu.edu/REU/comp/matode.pdf
% Duffing
% Volterra series on Duffing

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
gamma = 0.4;
gamma_x = 0.385 ;
w = 1  ;
k = 0.5;

% presence signal
delta_t = 0.01;
t = 0:delta_t:500;

% convert to SNR 10*log10(0.5/sigma)
sigma = 0 ;
noise = sigma * randn(length(t), 1) ;

% Incoming signal
w_x = w ;

% [x; x']
x = zeros(length(t) + 1, 2) ;

% Cauchy coditions
x(1, :) = [1; 1];
x(1, 2) = 1;

for duff = 1:length(t)
    x(duff + 1, :) = step(t(duff), x(duff, :), noise(duff));
end % for

fprintf('Variance %f\n', var(x(100:end,1)));

% plot
    clf; figure(1), plot(x(:,1),x(:,2)),
        xlabel('x'), ylabel('y'),
        grid on; %, hold on, comet(x(:,1),x(:,2));

    [spectrum, f] = pwelch(x(:, 1)); spectrum = spectrum .* conj(spectrum);
    [a,b] = max(spectrum);
    fprintf(' max %f, position %d\n', a, b);
    figure(2), plot(f(1:500), spectrum(1:500)), grid on, title(sprintf('Max %f, position %d SNR:%2.2f', a,b, 10*log10(0.5/sigma)));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
% absence signal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
gamma_x = 0 ;
w_x = 1 ;

% convert to SNR 10*log10(0.5/sigma)
sigma = 2 ;
noise = sigma * randn(length(t), 1) ;

% [x; x']
x_noise = zeros(length(t) + 1, 2) ;

% Cauchy coditions
x_noise(1, :) = [1; 1];
x_noise(1, 2) = 1;

for duff = 1:length(t)
    x_noise(duff + 1, :) = step(t(duff), x_noise(duff, :), noise(duff));
end % for

% plot
    clf; figure(3), plot(x_noise(:,1),x_noise(:,2)),
        xlabel('x'), ylabel('y'),
        grid on; %, hold on, comet(x(:,1),x(:,2));

    [spectrum, f] = pwelch(x_noise(:, 1)); spectrum = spectrum .* conj(spectrum);
    [a,b] = max(spectrum);
    fprintf(' max %f, position %d\n', a, b);
    figure(4), plot(f(1:500), spectrum(1:500)), grid on, title(sprintf('Max %f, position %d SNR:%2.2f', a,b, 10*log10(0.5/sigma)));

    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%% digital part %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
num_eq = length(t) - 1;

% [1  x_k  x_k-1  x_k^2  x_k*x_k-1  x_k-1^2]
length_of_vec = 6 ;

mtx_coef = ones(2 * num_eq, length_of_vec) ;

% signal
for k = 1:num_eq
    mtx_coef(k, 2:3) = [cos(w*t(k+1)), cos(w*t(k))] ;   x(k+1:-1:k) ;
    % adjust coef
    mtx_coef(k, 4) = mtx_coef(k, 2)^2 ;
    mtx_coef(k, 5) = mtx_coef(k, 2) * mtx_coef(k, 3) ;
    mtx_coef(k, 6) = mtx_coef(k, 3)^2 ;
end ;  % for k

% noise
for k = num_eq+1:2*num_eq
    mtx_coef(k, 2:3) = [noise(k+1-num_eq), noise(k-num_eq)] ;          %x(k+1:-1:k) ;
    % adjust coef
    mtx_coef(k, 4) = mtx_coef(k, 2)^2 ;
    mtx_coef(k, 5) = mtx_coef(k, 2) * mtx_coef(k, 3) ;
    mtx_coef(k, 6) = mtx_coef(k, 3)^2 ;
end ;  % for k

mtx_coef(1:3,:)

out_vec = [x(1:end-2, 1); x_noise(1:end-2, 1)] ;

%size([x(1:end-2, 1); x_noise(1:end-2, 1)])
%size(mtx_coef)

h = pinv(mtx_coef) * out_vec
    
% Incoming parameters:
%   t - current time
%   x(1) - x
%   x(2) - x'
% Return parameters:
%   y(1) - y
%   y(2) - y'
function y = step(t, x, noise)

global gamma_x;
global w_x;
global gamma;
global w;
global k;
global delta_t;

% calculate Runge-Kutta step
k1 =    gamma_x * cos(w_x*t) + ...
        gamma * cos(w*t) + ...
        noise + ...
        x(1)^3 - x(1)^5 - ...
        k*x(2) ;
    
x_tmp = x(1) + x(2) * delta_t / 2 ;
x_der = x(2) + k1 / 2 ;
k2 =    gamma_x * cos(w_x * (t + delta_t / 2)) + ...
        gamma * cos(w * (t + delta_t / 2)) + ...
        noise + ...
        x_tmp^3 - x_tmp^5 - ...
        k*x_der ;
    
x_tmp = x(1) + x(2) * delta_t / 2 + k1/4 * delta_t ;
x_der = x(2) + k2 / 2 ;
k3 =    gamma_x * cos(w_x * (t + delta_t / 2)) + ...
        gamma * cos(w * (t + delta_t / 2)) + ...
        noise + ...
        x_tmp^3 - x_tmp^5 - ...
        k*x_der;
        
x_tmp = x(1) + x(2) * delta_t + k2/2 * delta_t;
x_der = x(2) + k3 ;
k4 =    gamma_x * cos(w_x * (t + delta_t)) + ...
        gamma * cos(w * (t + delta_t)) + ...
        noise + ...
        x_tmp^3 - x_tmp^5 - ...
        k*x_der ;

y(1) = x(1) + delta_t * (x(2) + delta_t/6 * (k1 + k2 + k3)) ;
y(2) = x(2) + delta_t/6 * (k2 + 2*k2 + 2*k3 + k4) ;