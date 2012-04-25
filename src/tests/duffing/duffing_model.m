% http://www.math.tamu.edu/REU/comp/matode.pdf
% Duffing
function s_ode_3()
clc;
global signal
global fs
global fd

% singal constants
fd = 16.368e6;		% 16.368 MHz
fs = 4.092e6;
%freq_delta = -5e3:0.5e3:5e3;
freq_delta = 0;
%freq_delta = 5e3;
N = 16368;

ms = 10;
DumpSize = ms*N;
snr_range = 15;

vars = zeros(length(freq_delta), 2);

for k=1:length(freq_delta)
    num_of_sat = 1;
    PRN = 1:num_of_sat;
    freq_delta_once = freq_delta(k);
    freq_delta_sig = repmat(freq_delta_once, 1, length(PRN));
    ca_phase = 1;
    ca_phase = repmat(ca_phase, 1, length(PRN));
    snr_for_range = repmat(snr_range(1), 1, length(PRN));
    signal = signal_generate(PRN, freq_delta_sig, ca_phase, snr_for_range, DumpSize, 0);

    % despread
    x_ca16 = ca_get(PRN, 0) ;
    x_ca16 = repmat(x_ca16, ms, 1);
    signal = real(signal .* x_ca16);

    %plot(signal(1:100)), pause;

    % duffing constants
    x0=[1;0];
    tspan=[0 100];

    [t,x]=ode45(@eq1,tspan,x0);
    clf; plot(x(:,1),x(:,2)), 
        title(sprintf(' delta %d', freq_delta(k))),
        grid on, hold on, comet(x(:,1),x(:,2));
    %clf; plot3(x(:,1),x(:,2),t), grid
    %on,xlabel('x_1'),ylabel('x_2'),zlabel('t'), hold on, comet3(x(:,1),x(:,2),t) ;

    vars(k, :) = var(x);
    fprintf('%d from %d\tVariance %f\n', k, length(freq_delta), vars(k,2));
    
end     % for k=1

%plot(freq_delta, vars(:,2)), title('hello')

function f = eq1(t,x)

global signal
global fs
global fd

gamma=1 ;
%w0 = 8 ;
w0 = 2*pi*fs/fd;
w = 2*pi*(fs+1e3)/fd;
w = 8 ;
A = 1.7 ;
beta = 1000 ;
k = 1;
f=[x(2);-k*x(2) + x(1)^3 - x(1)^5 + 5*cos(w0*round(t)) + 5*signal(round(t) + 1)] ;
%f=[x(2);-w0*k*x(2) + x(1)^3 - x(1)^5 + 5*cos(w0*t) + 0.2 * signal(round(t) + 1)] ;
%f=[x(2);-1*x(2) + x(1)^3 - x(1)^5 + 6.5*cos(w0*round(t)) + 1 * cos(w0*round(t))] ;
%f=[x(2);-1*x(2) + x(1)^3 - x(1)^5 + 6.5 * cos(w0*round(t)) + 1 * cos(w*round(t))] ;