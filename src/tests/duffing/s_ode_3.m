% http://www.math.tamu.edu/REU/comp/matode.pdf
% Duffing
function s_ode_3()
x0=[1;1];

tspan=[0 2000];

[t,x]=ode45(@eq1,tspan,x0);

%clf; plot(x(:,1),x(:,2)), grid on; %, hold on, comet(x(:,1),x(:,2)) ;

spectrum = pwelch(x(:, 1)); spectrum = spectrum .* conj(spectrum);
[a,b] = max(spectrum);
fprintf(' max %f, position %d\n', a, b);
plot(spectrum), grid on, title(sprintf('Max %f, position %d', a,b));

%spectrum(112:132)

function f = eq1(t,x)
gamma = 0.385 ;
%gamma_x = 0.01 ;        % chaos
gamma_x = 0.385         % great scale
w_x = 1 ;
w = 1 ;
k = 0.5;
f=[x(2);-k*x(2) + x(1)^3 - x(1)^5 + gamma*cos(w*t) + gamma_x*cos(w_x*t)] ;

%gamma = 30 ;
%gamma_x = gamma ;
%w_x = 5 ;
%w = 5 ;
%k = 3.4;
%f=[x(2);-k*x(2) + x(1)^3 - x(1)^5 + gamma*cos(w*t) + gamma_x*cos(w_x*t)] ;
