% http://www.math.tamu.edu/REU/comp/matode.pdf
% Duffing
function s_ode_3()
clc;
global signal
global fs
global fd
global iter

% singal constants
fd = 16.368e6;		% 16.368 MHz
fs = 4.092e6;
%freq_delta = -5e3:0.5e3:5e3;
freq_delta = 0;
%freq_delta = 5e3;
N = 16368;
sigma = 1;

ms = 10;
DumpSize = ms*N;
snr_range = 15;

vars = zeros(length(freq_delta), 2);

for iter=1:length(freq_delta)
    %plot(signal(1:100)), pause;

    % duffing constants
    x0=[1;1];
    tspan=[0 100];

    [t,x]=ode45(@eq1,tspan,x0);
    clf; plot(x(:,1),x(:,2)), 
        xlabel('x'), ylabel('y'),
        grid on, hold on, comet(x(:,1),x(:,2));
    %clf; plot3(x(:,1),x(:,2),t), grid
    %on,xlabel('x_1'),ylabel('x_2'),zlabel('t'), hold on, comet3(x(:,1),x(:,2),t) ;

    %vars(k, :) = var(x);
    %fprintf('%d from %d\tVariance %f\n', k, length(freq_delta), vars(k,2));
    
end     % for k=1

%plot(freq_delta, vars(:,2)), title('hello')

function f = eq1(t,x)

global signal
global fs
global fd
global iter

gamma=1 ;
sigma = 8 ;
w0 = 2*pi*fs/fd;
w = 2*pi*(fs + 10e3)/fd;
k = 0.5;

%f=[x(2);-k*x(2) + x(1)^3 - x(1)^5 + 1.6315*cos(w0*t) + 1*cos(w*t)] ;
f=[x(2);-k*x(2) + x(1)^3 - x(1)^5 + 0.36*cos(t) + 0.36*cos(t)] ; % + 100*randn(1)] ;
%f=[x(2);-w0*k*x(2) + x(1)^3 - x(1)^5 + 5*cos(w0*t) + 0.2 * signal(round(t) + 1)] ;
%f=[x(2);-1*x(2) + x(1)^3 - x(1)^5 + 6.5*cos(w0*round(t)) + 1 * cos(w0*round(t))] ;
%f=[x(2);-1*x(2) + x(1)^3 - x(1)^5 + 6.5 * cos(w0*round(t)) + 1 * cos(w*round(t))] ;