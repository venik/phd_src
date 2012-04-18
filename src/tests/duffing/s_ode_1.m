% http://www.math.tamu.edu/REU/comp/matode.pdf
function s_ode_1()
x0=[0;0];
tspan=[0,1];
[t,x]=ode45(@eq1,tspan,x0);
clf; plot(t,x(:,1)), hold on ; 
plot(t,2*5*t.^2.*exp(2*t),'r-.') ;
function f = eq1(t,x)
f=[x(2);4*x(2)-4*x(1)+20*exp(2*t)] ;