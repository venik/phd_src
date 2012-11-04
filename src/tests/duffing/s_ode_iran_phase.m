% http://www.math.tamu.edu/REU/comp/matode.pdf
% Duffing
function s_ode_iran_phase()
global phase

x0=[0;0];
tspan=0:0.0002:1;

phase_range = -2*pi:0.025*pi:2*pi ;
iter = length(phase_range) ;
varss = zeros(iter, 1) ;
for i=1:iter
    phase = phase_range(i) ;
    [t,x]=ode45(@eq1,tspan,x0, 1) ;

    h= firls(30, [ 0  40/(5000*2)   60/(5000*2)  1 ],[ 0 0 1 1  ]) ;
    %fvtool(h,1) ;
    y = filter(h,1,x(:, 1)) ;
    %y=x(:, 1);
    
    spectrum = fft(y); spectrum = abs(spectrum) ;    
    varss(i) = var(spectrum) ;
    [energy, freq] = max(spectrum) ;
    fprintf('%03d: freq:%02d: energy:%5.2f phase:%f\n', i, freq, energy, phase)
end ;

if iter>1
    %hist(varss, 100);
    plot(phase_range, varss), grid on, xlabel('phase'), ylabel('Energy');
end;

if iter==1
clf; figure(1),
    plot(x(:,1),x(:,2)), grid on; %, hold on, comet(x(:,1),x(:,2)) ;
end

function f = eq1(t,x, step)

global noise
global phase

gamma = 0.826 ;
w = 100*pi ;
k = 0.5;

gamma_x = 0.005;
w_x = w ;
sigma = 0;
noise = sigma * randn(1);

input = gamma_x * cos(w_x*t + phase) + noise;

f=[x(2) * w ; w*(-k*x(2) + x(1) - x(1)^3 + gamma*cos(w*t) + input)] ;