function s_ode()
clc; clf; clear all;

global noise ;
global gamma ;
global last_t_noise ;

x0=[1;1];
tspan=[0:0.1:200];

gamma = 0 ;
last_t_noise = -1 ;

awgn_size = numel(tspan) * 1000 ;
noise = 1 * rand(awgn_size, 1) ;

[t,x]=ode45(@eq1,tspan,x0, 1e-1);

fprintf('Variance duffing %f\n', var(x(:,1)));

figure(1),
    plot(x(:,1),x(:,2)), grid on; % hold on, comet(x(:,1),x(:,2)) ;

[spectrum] = fft(x(:, 1)) ;
[spectrum_noise] = fft(noise) ;
spectrum = spectrum .* conj(spectrum) ;
spectrum_noise = spectrum_noise .* conj(spectrum_noise) ;

figure(2),
    hold off,
    plot(spectrum(1:100), '-rx')
    hold on
    plot(spectrum_noise(1:100), '-go'),
    xlabel('Частота'),
    ylabel('Амплитуда'),
    legend('Выход осциллятора Дуффинга', 'Вход осциллятора Дуффинга') ;

spectrum_noise(1:10)    
    
function f = eq1(t,x)

global gamma ;
global noise ;
global last_t_noise ;

t_noise = round(t * 1000) ;
if last_t_noise == t_noise
       fprintf('collision at %d\n', t_noise) ;
else
        % fprintf('\t not collision at %d\n', t_noise) ;
end
last_t_noise = t_noise ;

w = 1 ;
k = 0.5 ;
f=[x(2);-k*x(2) + x(1) - x(1)^3 + gamma*cos(w*t) + noise(t_noise + 1)] ;
