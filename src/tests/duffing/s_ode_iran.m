% http://www.math.tamu.edu/REU/comp/matode.pdf
% Duffing
function s_ode_3()
x0=[0;0];
tspan=0:0.0002:1;

iter = 1000 ;
varss = zeros(iter, 1) ;
for i=1:iter
    [t,x]=ode45(@eq1,tspan,x0) ;
    spectrum = fft(x(:, 2)); spectrum = abs(spectrum) ;:w
    
    varss(iter) = var(spectrum) ;
    i
end ;

hist(varss, 100);

%clf; figure(1),
%    plot(x(:,1),x(:,2)), grid on; %, hold on, comet(x(:,1),x(:,2)) ;

%spectrum = fft(x(:, 2)); spectrum = abs(spectrum);
%[a,b] = max(spectrum);
%fprintf(' max %f, position %d\n', a, b);

%figure(2),
%    plot(spectrum(1:500)), grid on, title(sprintf('Max %f, position %d', a,b));

%a = [0.028  0.053 0.071  0.053 0.028];
%b = [1.000 -2.026 2.148 -1.159 0.279];

%x_filtered = filter(a, b, x(:, 1));
%spectrum = fft(x_filtered); spectrum = spectrum .* conj(spectrum);
%figure(3),
%    plot(spectrum(1:500)), grid on, title(sprintf('filtered'));

    
%spectrum(112:132)

function f = eq1(t,x)

gamma = 0.825 ;
w = 100*pi ;
k = 0.5;

gamma_x = 0.01;
w_x = w ;
sigma = 0.08;
noise = sigma * randn(1);
input = gamma_x * cos(w_x*t) + noise;

f=[x(2) * w ; w*(-k*x(2) + x(1) - x(1)^3 + gamma*cos(w*t)) + input] ;