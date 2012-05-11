% http://www.math.tamu.edu/REU/comp/matode.pdf
% Duffing
function s_ode_3()
clc;
global freq_delta
global sigma
global iter

% singal constants
fd = 16.368e6;		% 16.368 MHz
fs = 4.092e6;
%freq_delta = 0.1:0.1:1.9;
freq_delta = 1 ;
%freq_delta = 5e3;
N = 16368;
sigma = 0;

ms = 10;
DumpSize = ms*N;
snr_range = 15;

vars = zeros(length(freq_delta), 2);

for iter=1:length(freq_delta)
    %plot(signal(1:100)), pause;

    % duffing constants
    x0=[1;1];
    tspan=[0 1000];

    [t,x]=ode45(@eq1,tspan,x0);
    if(length(freq_delta) < 2)
        clf; plot(x(:,1),x(:,2)), 
            xlabel('x'), ylabel('y'),
            grid on, hold on, comet(x(:,1),x(:,2));
    %clf; plot3(x(:,1),x(:,2),t), grid
    %on,xlabel('x_1'),ylabel('x_2'),zlabel('t'), hold on, comet3(x(:,1),x(:,2),t) ;
    end

    if(length(freq_delta) > 1)
        vars(iter, :) = var(x);
        fprintf('%d from %d\tVariance %f\n', iter, length(freq_delta), vars(iter,2));
    end
end     % for k=1

freq_delta = freq_delta - 1;

if(length(freq_delta) > 1)
    clf;
        plot(freq_delta, vars(:,2)),
        title('Зависимость СКО от \Delta\omega'),
        xlabel('\omega'), ylabel('\sigma^2');
end;

function f = eq1(t,x)

global freq_delta
global iter
global sigma

%gamma=1 ;
%w0 = 2*pi*fs/fd;
%w = 2*pi*(fs + 10e3)/fd;
k = 0.5;

%f=[x(2);-k*x(2) + x(1)^3 - x(1)^5 + 1.6315*cos(w0*t) + 1*cos(w*t)] ;
f=[x(2);-k*x(2) + x(1)^3 - x(1)^5 + 0.36*cos(t) + 0.36*cos(freq_delta(iter)*t) + sigma*randn(1)] ;
%f=[x(2);-w0*k*x(2) + x(1)^3 - x(1)^5 + 5*cos(w0*t) + 0.2 * signal(round(t) + 1)] ;
%f=[x(2);-1*x(2) + x(1)^3 - x(1)^5 + 6.5*cos(w0*round(t)) + 1 * cos(w0*round(t))] ;
%f=[x(2);-1*x(2) + x(1)^3 - x(1)^5 + 6.5 * cos(w0*round(t)) + 1 * cos(w*round(t))] ;