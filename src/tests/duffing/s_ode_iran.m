% http://www.math.tamu.edu/REU/comp/matode.pdf
% Duffing
function s_ode_iran()
global noise

x0=[0;0];
tspan=0:0.0002:1;

iter = 1 ;
varss = zeros(iter, 1) ;
for i=1:iter
    [t,x]=ode45(@eq1, tspan, x0) ;

    h= firls(30, [ 0  40/(5000*2)   60/(5000*2)  1 ],[ 0 0 1 1  ]) ;
    %fvtool(h,1) ;
    y = filter(h,1,x(:, 1)) ;
    %y=x(:, 1);
    
    spectrum = pwelch(y); spectrum = abs(spectrum) ;    
    varss(i) = var(spectrum) ;
    [energy, freq] = max(spectrum) ;
    fprintf('%03d: freq:%02d: energy:%5.2f\n', i, freq, energy)
end ;

if iter>1
    hist(varss, 100);
end;

if iter==1
clf; figure(1),
    figure(1), plot(x(:,1),x(:,2)), grid on; %, hold on, comet(x(:,1),x(:,2)) ;
    figure(2), plot(spectrum);
end

function f = eq1(t,x)

global noise

gamma = 0.826 ;
%gamma = 0 ;
w = 50 * 2 * pi ;
k = 0.5;

gamma_x = 0.005;
w_x = w ;
sigma = 0;
noise = sigma * randn(1);

input = gamma_x * cos(w_x*t - 4*pi) + noise;

f=[x(2) * w ; w*(-k*x(2) + x(1) - x(1)^3 + gamma*cos(w*t) + input)] ;