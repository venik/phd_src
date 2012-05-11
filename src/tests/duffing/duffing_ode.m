% http://www.math.tamu.edu/REU/comp/matode.pdf
% Duffing
function s_ode_3()
clc;

x0=[1;1];

tspan=[0 200];
[t,x]=ode45(@eq1,tspan,x0);

clf; plot(x(:,1),x(:,2)), grid on; % hold on, comet(x(:,1),x(:,2)) ;

fprintf('Variance %f\n', var(x(:,1)));

function f = eq1(t,x)
gamma = 120 ;
w = 5 ;
k = 3.4 ;
f=[x(2);-k*x(2) + x(1) - x(1)^3 + gamma*cos(w*t)] ;