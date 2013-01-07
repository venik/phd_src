% Analog model oth the PLL by Alex Nikiforov

#!/usr/bin/octave
clf; clc; clear;

% definitions
zeta = 0.707;
wp = 2 * pi * 0.5;

Kd = 8;
K0 = 6 ;
Ki = wp^2 / (Kd*K0) ;		% Kd * K0  >> wp
Kp = 2*zeta*wp / (Kd*K0) ;

f0 = 1e3;			% 1kHz
delta_f = 2;			
dt = 0.01;
phi = 1;

% check for maximum freq shift
% must be less than 2 * zeta * wp
if( delta_f > (2*zeta*wp))
	fprintf('[ERR] delta:%.02f maximum_delta:%.02f\n', delta_f, 2*zeta*wp)
	fprintf('Too much freq delta. Plz look at page 49 in the book about PLL by Best\n');
	return
end

N = 100000;
x = zeros(N,1);
y = zeros(N,1);
e = zeros(N,1);
psi = zeros(N,1) ;

Int_e = 0;
Int_f = 0;
yn = 0;

B_noise = wp / 2 * (zeta + 0.25 / zeta);

for k=1:N
	t = (k-1) * dt;
	x(k) = sin(2*pi*(f0 + delta_f)*t + phi) * yn   ;
	Int_f = Int_f + x(k)*dt;
	e(k) = Kd * (Kp * x(k) + Ki * Int_f);
	Int_e = Int_e + e(k)*dt;
	y(k) = cos(2*pi*f0*t + K0 * Int_e);
	yn = y(k);
	psi(k) = K0*Int_e ;
end % for k=1:N

fprintf('freq delta:%0.2f Hz founed by PLL delta freq:%0.2f Hz\n', delta_f, mean(e));

figure(1),
plot(e(1:20000)), title(sprintf('Freq shift=%d Hz    B\\_noise = %02.02f     phase =pi*%.02f', delta_f, B_noise, phi/pi));
%print -djpeg 'pll2.jpg';

Kdf = Kd/2 ; % because 1/2sin(.)

sys = tf2sys([Kdf*K0*Kp Kdf*K0*Ki],[1 Kdf*K0*Kp Kdf*K0*Ki]);
[V, T] = step(sys) ;


figure(2), hold on,
	grid on, 
	plot(T, V, T,psi(1:length(T))), grid on, legend('step response', 'real phase'),
	hold off;