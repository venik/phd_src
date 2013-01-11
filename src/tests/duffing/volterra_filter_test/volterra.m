function s_ode()
clc;

x0=[1;1];
tspan=[0:0.01:150];
[t,x]=ode45(@eq1,tspan,x0);
clf; figure(1), plot(x(:,1),x(:,2)), grid on; % hold on, comet(x(:,1),x(:,2)) ;
fprintf('Variance duffing %f\n', var(x(:,1)));

gamma = 1 ;
f = gamma * cos(1*tspan) ;
f = f(50:2500) + 0;
y = x(50:2500,1) ;

len = size(f,2) ;
X = zeros(len-2, 18) ;
for n=3:len
  X(n-2,1) = 1 ;
  X(n-2,2) = f(n-0) ;
  X(n-2,3) = f(n-1) ;
  X(n-2,4) = f(n-2) ;

  X(n-2,5) = f(n-0)*f(n-0) ;
  X(n-2,6) = f(n-0)*f(n-1) ;
  X(n-2,7) = f(n-0)*f(n-2) ;
  X(n-2,8) = f(n-1)*f(n-1) ;
  X(n-2,9) = f(n-1)*f(n-2) ;
  X(n-2,10) = f(n-2)*f(n-2) ;

  X(n-2,11) = f(n-0)*f(n-0)*f(n-0) ;
  X(n-2,12) = f(n-0)*f(n-0)*f(n-1) ;
  X(n-2,13) = f(n-0)*f(n-0)*f(n-2) ;
  X(n-2,14) = f(n-0)*f(n-1)*f(n-1) ;
  X(n-2,15) = f(n-0)*f(n-1)*f(n-2) ;
  X(n-2,16) = f(n-0)*f(n-2)*f(n-2) ;
  X(n-2,17) = f(n-1)*f(n-1)*f(n-1) ;
  X(n-2,18) = f(n-1)*f(n-1)*f(n-2) ;
  X(n-2,19) = f(n-1)*f(n-2)*f(n-2) ;
  X(n-2,20) = f(n-2)*f(n-2)*f(n-2) ;
end

size(pinv(X))
size(y(3:end))
h = pinv(X)*y(3:end)

savefile = 'ode_h.mat' ;
save(savefile, 'h') ;

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

function f = eq1(t,x)
% nothing here
gamma = 1 ;
w = 1 ;
k = 0.5 ;
f=[x(2);-k*x(2) + x(1) - x(1)^3 + gamma*cos(w*t) + 0] ;
