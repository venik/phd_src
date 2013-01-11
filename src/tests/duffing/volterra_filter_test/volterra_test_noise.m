function s_ode()
clc; clf;

global noise
noise = 0.7 * randn(1, length(50:2500)) ;

x0=[1;1];
tspan=[0:0.01:150];
[t,x]=ode45(@eq1,tspan,x0);
figure(1), plot(x(:,1),x(:,2)), grid on; % hold on, comet(x(:,1),x(:,2)) ;
fprintf('Variance duffing %f\n', var(x(:,1)));

gamma = 1 ;
f = gamma * cos(1*tspan) ;
f = f(50:2500) + noise;
y = x(50:2500,1) ;

savefile = 'ode_h.mat' ;
load(savefile, 'h') ;

r = zeros(size(y)) ;
for n=3:length(y)
  r(n) = h(1) + h(2)*f(n-0) + h(3)*f(n-1) + h(4)*f(n-2) +  ...
   ...
  h(5)*f(n-0)*f(n-0) + h(6)*f(n-0)*f(n-1) + h(7)*f(n-0)*f(n-2) + h(8)*f(n-1)*f(n-1) + h(9)*f(n-1)*f(n-2) +  ...
  h(10)*f(n-2)*f(n-2) +  ...
  h(11)*f(n-0)*f(n-0)*f(n-0) + h(12)*f(n-0)*f(n-0)*f(n-1) + h(13)*f(n-0)*f(n-0)*f(n-2) + h(14)*f(n-0)*f(n-1)*f(n-1) +  ...
  h(15)*f(n-0)*f(n-1)*f(n-2) + h(16)*f(n-0)*f(n-2)*f(n-2) + h(17)*f(n-1)*f(n-1)*f(n-1) + h(18)*f(n-1)*f(n-1)*f(n-2) + h(19)*f(n-1)*f(n-2)*f(n-2) +  ...
  h(20)*f(n-2)*f(n-2)*f(n-2) + 0 ;
end
fprintf('Variance volterra %f\n', var(r));

figure(2), hold off,plot(y), hold on,plot(r,'r-'), legend('duffing', 'volterra');

[b a] = butter(5, 0.01) ;
r = filter(b, a, r) ;
figure(3), hold off,plot(y), hold on,
    plot(r,'r-'), legend('duffing', 'volterra'),
    title('after filtering');
fprintf('Variance filtered volterra %f\n', var(r));
    
function f = eq1(t,x)
global noise
gamma = 1 ;
w = 1 ;
k = 0.5 ;
f=[x(2);-k*x(2) + x(1) - x(1)^3 + gamma*cos(w*t) + noise(round(t) + 1)] ;
