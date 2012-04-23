% http://www.math.tamu.edu/REU/comp/matode.pdf
% Duffing
function s_ode_3()
x0=[0;0];

tspan=[0:0.01:15];

[t,x]=ode45(@eq1,tspan,x0);
clf; plot(x(:,1),x(:,2)), grid on, hold on, comet(x(:,1),x(:,2)) ;
%clf; plot3(x(:,1),x(:,2),t), grid on,xlabel('x_1'),ylabel('x_2'),zlabel('t'), hold on, comet3(x(:,1),x(:,2),t) ;
function f = eq1(t,x)
gamma=1 ;
w0 = 8 ;
w = 8 ;
A = 1.7 ;
beta = 1000 ;
k = 1;
%f=[x(2);-w0*k*x(2) + +w0^2*(x(1)-x(1)^3) + w0^2*A*cos(w0*t) + cos(w*t)] ;
f=[x(2);-w0*k*x(2) + x(1)^3 - x(1)^5 + 1*cos(w0*t) + 0.2*cos(w*t)] ;
%f=[x(2);-0.5*x(2) + x(1)^3 - x(1)^5 + 0.78*cos(w0*t)] ;