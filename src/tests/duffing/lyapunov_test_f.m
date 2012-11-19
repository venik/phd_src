function s_ode()
clc; clf; clear all;

x0=[0;0];
tspan=[0:0.01:500];
[t,x]=ode45(@eq1,tspan,x0);
fprintf('Variance duffing x''=%.2f x=%.2f\n', var(x(:,1)), var(x(:,2)));

figure(1),
    plot(x(:,1),x(:,2)),
    xlabel('x'),
    ylabel('x'''),
    grid on; % hold on, comet(x(:,1),x(:,2)) ;
  
savefile = 'lyapunov_coef.mat' ;
load(savefile, 'x_lyap') ;
    
trac_x = zeros(numel(tspan), 1) ;
trac_y = zeros(numel(tspan), 1) ;
k = 1 ;
for i=1:numel(tspan)
    trac_x(i) = abs(x(i, 1) - x_lyap(i, 1)) ;
    trac_y(i) = abs(x(i, 2) - x_lyap(i, 2)) ;
end

figure(2),
    hold off,
    subplot(2,1,1), plot(t, trac_x, 'r'),
    title('lyapunov x'' ')
    subplot(2,1,2), plot(t, trac_y, 'g') ;
    title('lyapunov x' ) ;

%x_lyap = x ;
%savefile = 'lyapunov_coef.mat' ;
%save(savefile, 'x_lyap') ;

function f = eq1(t,x)
% nothing here
gamma = 0.9 ;
w = 1 ;
k = 0.5 ;
f=[x(2);-k*x(2) + x(1) - x(1)^3 + gamma*cos(w*t) + 0] ;
