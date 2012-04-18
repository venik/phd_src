% http://www.math.tamu.edu/REU/comp/matode.pdf
% d2x/dt2 + gamma dx(t)/dt + w^2 = A*cos(wt)
function s_ode_4()
clf ;
x0=[1;0];
tspan=[0,10];
[t,x]=ode45(@eq1,tspan,x0);
plot(x(:,1),x(:,2),'LineWidth',2), hold on,grid on;
plot(x0(1),x0(2),'ro','LineWidth',2) ;

xlim([-1.1 1.1])
ylim([-8.1 7.1])
set(gca(),'FontSize',14,'LineWidth',3)
xlabel('x(t)') ;
ylabel('dx(t)/dt')
%axis square ;
%comet(x(:,1),x(:,2)) ;
%clf; plot3(x(:,1),x(:,2),t),grid on, hold on, comet3(x(:,1),x(:,2),t) ;
function f = eq1(t,x)
gamma=1 ;
w0 = 8 ;
w = 8 ;
A = 0 ;
f=[x(2);-gamma*x(2)-w0^2*x(1)+A*cos(w*t)] ;