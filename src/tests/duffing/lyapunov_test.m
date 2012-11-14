function s_ode()
clc; clf; clear all;

x0=[0;0];
tspan=[0:0.01:500];
[t,x]=ode45(@eq1,tspan,x0);
fprintf('Variance duffing %f\n', var(x(:,1)));

figure(1),
    plot(x(:,1),x(:,2)),
    xlabel('x'),
    ylabel('x'''),
    grid on; % hold on, comet(x(:,1),x(:,2)) ;
   

% traectories = zeros(numel(tspan), 1) ;
k = 1 ;
for i=2:length(x(:,1))
    if (roundn(x(i,1), -2)) == 0
        traectories(k) = i;
        k = k + 1 ;
        fprintf('catch %d\n', i) ;
    end
end

%reshape(traectories, i, 1) ;
%lyapunov ;
j = 1 ;
for k=1:2:numel(traectories)
    fprintf('pair %d to %d\n', traectories(k), traectories(k+1)) ;
    
    for i=traectories(k):traectories(k+1)
        lyapunov(j) = sqrt( (x(traectories(k),1) - x(traectories(k+1), 1))^2 + ...
                    (x(traectories(k),2) - x(traectories(k+1), 2))^2) ;
        j = j + 1 ;
    end
end

lyapunov_real = lyapunov(2:end) ./ lyapunov(1:end-1) ;

figure(2), plot(lyapunov_real), title('lyapunov') ;
    
function f = eq1(t,x)
% nothing here
gamma = 1 ;
w = 1 ;
k = 0.5 ;
f=[x(2);-k*x(2) + x(1) - x(1)^3 + gamma*cos(w*t) + 0] ;
