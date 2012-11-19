function s_ode()
clc; clf; clear all;

global gamma ;

gamma_vals = 0:0.05:1.3 ;
x0=[0;0];
tspan=[0:0.01:500];

lyap_exp_x = zeros(numel(gamma_vals), 1) ;
lyap_exp_y = zeros(numel(gamma_vals), 1) ;

energy_x = zeros(numel(gamma_vals), 1) ;
energy_y = zeros(numel(gamma_vals), 1) ;

for k=1:numel(gamma_vals)
    gamma = gamma_vals(k) ;
    
    [t,x]=ode45(@eq1,tspan,x0);
    fprintf('Variance duffing x''=%.2f x=%.2f\n', var(x(:,1)), var(x(:,2)));

    energy_x(k) = var(x(:,1)) ;
    energy_y(k) = var(x(:,2)) ;
    
    % figure(1),
    %     plot(x(:,1),x(:,2)),
    %     xlabel('x'),
    %     ylabel('x'''),
    %     grid on; % hold on, comet(x(:,1),x(:,2)) ;

    savefile = 'lyapunov_coef.mat' ;
    load(savefile, 'x_lyap') ;

    trac_x = zeros(numel(tspan), 1) ;
    trac_y = zeros(numel(tspan), 1) ;
    for i=1:numel(tspan)
        trac_x(i) = x(i, 1) - x_lyap(i, 1) ;
        trac_y(i) = x(i, 2) - x_lyap(i, 2) ;
    end
    
    lyap_exp_x(k) = max(trac_x) ;
    lyap_exp_y(k) = max(trac_y) ;
    
    if (numel(gamma_vals) < 2)
        figure(1),
            subplot(2,1,1), plot(t, trac_x, 'r'),
            title('lyapunov x'' ')
            subplot(2,1,2), plot(t, trac_y, 'g') ;
            title('lyapunov x' ) ;
    end % if(numel(gamma) < 2)

    %x_lyap = x ;
    %savefile = 'lyapunov_coef.mat' ;
    %save(savefile, 'x_lyap') ;
end % for i

figure(1),
    hold off,
    subplot(2,1,1), plot(gamma_vals, lyap_exp_x, 'r', gamma_vals, lyap_exp_y, 'g'),
    legend('x', 'x'''),
    xlabel('\gamma'), ylabel('Lyapunov exponent'),
    title('Lyapunov exponent'),
    subplot(2,1,2), plot(gamma_vals, energy_x, 'r', gamma_vals, energy_y, 'g'),
    xlabel('\gamma'), ylabel('energy'),
    legend('x', 'x'''),
    title('Energy detector')

function f = eq1(t,x)
% nothing here
global gamma ;
w = 1 ;
k = 0.5 ;
f=[x(2);-k*x(2) + x(1) - x(1)^3 + gamma*cos(w*t) + 0] ;
