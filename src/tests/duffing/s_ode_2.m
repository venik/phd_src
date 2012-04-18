% http://www.math.tamu.edu/REU/comp/matode.pdf
% d2x/dt2 + gamma dx(t)/dt + w^2 = A*cos(wt)
function s_ode_2()
x0=[0;0];
tspan=[0,10];
[t,x]=ode45(@eq1,tspan,x0);
%clf; plot(x(:,1),x(:,2)), hold on,grid on, comet(x(:,1),x(:,2)) ;
clf; plot3(x(:,1),x(:,2),t),grid on, hold on, comet3(x(:,1),x(:,2),t) ;
function f = eq1(t,x)
gamma=-1 ;
w0 = 8 ;
w = 8 ;
A = .1 ;
f=[x(2);-gamma*x(2)-w0^2*x(1)+A*cos(w*t)] ;