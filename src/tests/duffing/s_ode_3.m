% http://www.math.tamu.edu/REU/comp/matode.pdf
% Duffing
function s_ode_3()
x0=[1;1];

tspan=[0 200];

[t,x]=ode45(@eq1,tspan,x0);
clf; plot(x(:,1),x(:,2)), grid on; %, hold on, comet(x(:,1),x(:,2)) ;
%clf; plot3(x(:,1),x(:,2),t), grid on,xlabel('x_1'),ylabel('x_2'),zlabel('t'), hold on, comet3(x(:,1),x(:,2),t) ;
function f = eq1(t,x)
%gamma = 0.385 ;
%gamma_x = 0.385 ;
%w_x = 1 ;
%w = 1 ;
%k = 0.5;
%f=[x(2);-k*x(2) + x(1)^3 - x(1)^5 + gamma*cos(w*t) + gamma_x*cos(w_x*t)] ;

gamma = 30 ;
gamma_x = gamma ;
w_x = 5 ;
w = 5 ;
k = 3.4;
f=[x(2);-k*x(2) + x(1)^3 - x(1)^5 + gamma*cos(w*t) + gamma_x*cos(w_x*t)] ;
