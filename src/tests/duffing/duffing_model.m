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
freq_delta = 0;
N = 16368;

ms = 10;
DumpSize = ms*N;
snr_range = -10;

num_of_sat = 1;
PRN = 1:num_of_sat;
freq_delta_once = 1;
freq_delta = repmat(freq_delta_once, 1, length(PRN));
ca_phase = 1;
ca_phase = repmat(ca_phase, 1, length(PRN));
snr_for_range = repmat(snr_range(1), 1, length(PRN));
signal = signal_generate(PRN, freq_delta, ca_phase, snr_for_range, DumpSize, 0);

% despread
x_ca16 = ca_get(PRN, 0) ;
x_ca16 = repmat(x_ca16, ms, 1);
signal = real(signal .* x_ca16);

%plot(signal(1:100)), pause;

% duffing constants
x0=[1;0];
tspan=[0 100];

[t,x]=ode45(@eq1,tspan,x0);
clf; plot(x(:,1),x(:,2)), grid on, hold on, comet(x(:,1),x(:,2)) ;
%clf; plot3(x(:,1),x(:,2),t), grid
%on,xlabel('x_1'),ylabel('x_2'),zlabel('t'), hold on, comet3(x(:,1),x(:,2),t) ;
fprintf('Variance %f std %f\n', var(x), std(x));


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
f=[x(2);-w0*k*x(2) + x(1)^3 - x(1)^5 + 7*cos(w0*t) + 0.2 * signal(round(t) + 1)] ;
%f=[x(2);-w0*k*x(2) + x(1)^3 - x(1)^5 + 5*cos(w0*t) + 0.2 * signal(round(t) + 1)] ;
%f=[x(2);-1*x(2) + x(1)^3 - x(1)^5 + 6.5*cos(w0*round(t)) + 1 * %cos(w0*round(t))] ;
%f=[x(2);-1*x(2) + x(1)^3 - x(1)^5 + 6.5 * cos(w0*round(t)) + 1 * cos(w*round(t))] ;