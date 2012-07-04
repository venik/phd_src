% http://www.math.tamu.edu/REU/comp/matode.pdf
% Duffing
% Volterra series on Duffing

function digita_l()

step = 0.0002 ;
x0=[0;0];
tspan=0:step:1;

iter = 1 ;
varss = zeros(iter, 1) ;
for i=1:iter
    [t,x]=ode45(@eq1,tspan,x0, 1) ;

    %h= firls(30, [ 0  40/(5000*2)   60/(5000*2)  1 ],[ 0 0 1 1  ]) ;
    %fvtool(h,1) ;
    %y = filter(h,1,x(:, 1)) ;
    %y=x(:, 1);
    
    %spectrum = pwelch(y); spectrum = abs(spectrum) ;
    [spectrum, f] = pwelch(x,[],[],[],1/step); spectrum = abs(spectrum) ;
    %spectrum = fft(x); spectrum = abs(spectrum) ;    
    %varss(i) = var(spectrum) ;
    [energy, freq] = max(spectrum) ;
    fprintf('%03d: freq:%02d: energy:%5.2f\n', i, freq, energy) ;
end ;

%if iter>1
%    hist(varss, 100);
%end;

%if iter==1
%clf; figure(1),
%    figure(1), plot(x(:,1),x(:,2)), grid on, title('Phase plane'); %, hold on, comet(x(:,1),x(:,2)) ;
%    figure(2), plot(f, spectrum), grid on, title('Spectrum') ;
%end

%%%%%%%%%%%%%%%%%%%%%%%% digital part %%%%%%%%%%%%%%%%%%%%%%%%%%%
num_eq = 1;

length_of_vec = 6 ;

mtx_coef = ones(num_eq, length_of_vec) ; 

for k = 1:num_eq
    mtx_coef(k, 2:length_of_vec) = x(1:length_of_vec-1)
    mtx_coef(k, 4) =  mtx_coef(k, 4)^2 ;
    mtx_coef(k, 6) =  mtx_coef(k, 6)^2 ;
    %mtx_coef(k, )
end ;  % for k

mtx_coef

function f = eq1(t,x)

global noise

gamma = 0.826 ;
w = 100 * 2 * pi ;
k = 0.5; 

gamma_x = 0;
w_x = w ;
sigma = 0;
noise = sigma * randn(1);

%input = gamma_x * cos(w_x*t + phase) + noise;
input = 0;

f=[x(2) * w ; w*(-k*x(2) + x(1) - x(1)^3 + gamma*cos(w*t) + input)] ;