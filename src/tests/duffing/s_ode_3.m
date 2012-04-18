% http://www.math.tamu.edu/REU/comp/matode.pdf
% Duffing
function s_ode_3()
x0=[0;0];
tspan=[0,5];
[t,x]=ode45(@eq1,tspan,x0);
clf; plot(x(:,1),x(:,2)), grid on, hold on, comet(x(:,1),x(:,2)) ;
%clf; plot3(x(:,1),x(:,2),t), grid on,xlabel('x_1'),ylabel('x_2'),zlabel('t'), hold on, comet3(x(:,1),x(:,2),t) ;
function f = eq1(t,x)
gamma=1 ;
w0 = 8 ;
w = 8 ;
A = 1000 ;
beta = 1000 ;
f=[x(2);-gamma*x(2)-w0^2*x(1)-beta*x(1)^3+A*cos(w*t)] ;