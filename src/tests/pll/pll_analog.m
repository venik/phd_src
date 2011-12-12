#!/usr/bin/octave

% definitions
zeta = 0.707;
wp = 2 * pi * 0.5;

Kd = 7 ;
K0 = 6 ;
Ki = wp^2 / (Kd*K0) ;		% Kd * K0  >> wp
Kp = 2*zeta*wp / (Kd*K0) ;

f0 = 1e3;			% 1kHz
delta_f = 2;
dt = 0.01;

phi = pi/2;

N = 100000;
x = zeros(N,1);
y = zeros(N,1);
e = zeros(N,1);

Int_e = 0;
Int_f = 0;
yn = 0;

B_noise = wp / 2 * (zeta + 0.25 / zeta);

for k=1:N
	t = (k-1) * dt;
	x(k) = sin(2*pi*(f0 + delta_f)*t + phi) * yn ; ;
	Int_f = Int_f + x(k)*dt;
	e(k) = Kd * (Kp * x(k) + Ki * Int_f);
	Int_e = Int_e + e(k)*dt;
	y(k) = cos(2*pi*f0*t + K0 * Int_e);
	yn = y(k);
end % for k=1:N

plot(e(1:5000)), title(sprintf('Freq shift=%d Hz    B\\_noise = %02.02f     phase =pi*%.02f', delta_f, B_noise, phi/pi));
%print -djpeg 'pll2.jpg';