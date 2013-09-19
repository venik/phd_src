clc, clear all;

%f = 30 ; real_a = [0.6180; 1] ;
f = 5 ; real_a = [-1.9021; 1] ;

fd = 100 ;
N = 1000 ;
% FIXME - make me 10000 for PHD, 1000 only for tests
times = 1000 ;

sigma = 0.005:0.005:0.5 ;
%sigma = 0.0000000005 ;

%marple_delta = zeros(length(sigma), 1) ;
actual_delta = zeros(length(sigma), 1) ;

% a vector for NON noise case
%real_a = [1.9021; 1] ;

var_a = zeros(2, length(sigma)) ;
cov_a = zeros(2, length(sigma)) ;
real_var_a = zeros(2, length(sigma)) ;

est_a = zeros(2, times) ;
var_poles = zeros(length(sigma), 1) ;

for k=1:length(sigma)
    fprintf('iteration %d\n', k) ;
    for tt=1:times
        noise = sqrt(sigma(k)) * randn(1,N) ;
        sig = sin(2*pi*f / fd * [0:N-1]) ;

        x = sig + noise ;  

        rxx0 = x * x' / (length(x) - 1) ;
        rxx1 = x * [x(2:end), x(1)]' / (length(x) - 1) ;
        rxx2 = x * [x(3:end), x(1:2)]' / (length(x) - 1) ;

        rxx = [rxx0, rxx1, rxx2];

        Rxx = [rxx(1) , rxx(2); rxx(2), rxx(1)] ;

        % calculate coef
        a = pinv(Rxx) * rxx(2:3)' ;
        a = [1;-a] ;
        poles = roots(a) ;
        freq = angle(poles(1)) ;
        
        var_poles(k) = var_poles(k) + (abs(poles(1)) - 1).^2 ;
        
        actual_delta(k) = actual_delta(k) + (f - freq*fd/2/pi).^2 ;
        est_a(:, tt) = a(2:3) ;
        real_var_a(:, k) = var_a(:, k) + (a(2:3) - real_a).^2 ;
    end ;  % tt
    
    var_poles(k) = var_poles(k) / times ;
    
    actual_delta(k) = actual_delta(k) / times ;
    % marple eq 7.35 in Marple book
    %marple_delta(k) = 1.03/(2*(0.5/sigma(k))*(2+1 )^0.31) ;
    
    hat_a(1) = sum(est_a(1,:)) / times ;
    hat_a(2) = sum(est_a(2,:)) / times ;
    %fprintf('a1: real: %.4f, estimated: %.4f\n', real_a(1), hat_a(1)) ;
    %fprintf('a2: real: %.4f, estimated: %.4f\n', real_a(2), hat_a(2)) ;
    
    var_a(1, k) = sum((est_a(1,:) - hat_a(1)).^ 2) / times ;
    var_a(2, k) = sum((est_a(2,:) - hat_a(2)).^ 2) / times ;
    
    %fprintf('var: a1: %.8f a2:%.8f\n', var_a(1, k), var_a(2, k)) ;
    
    real_var_a(:, k) = real_var_a(:, k) / times ;
    
    % 11a equation in
    % Noise Compensation for AR Spectral Estimates
    cov_matrix = sigma(k) / N * pinv(Rxx) ;
    cov_a(:, k) = cov_matrix(:, 1) ;
    %fprintf('cov: a1: %.8f a2:%.8f\n', cov_a(1, k), cov_a(2, k)) ;
end ;   %for k=1:length(sigma)


if length(sigma) > 1
    clf ;
    snr = 10*log(0.5./sigma) ;

    figure(1),
    plot(snr, var_a(1,:), snr, cov_a(1,:), snr, real_var_a(1, :));
        title('ќценка a1'),
        legend('Estimated', 'Calculated', 'Real variance') ,
        xlabel('SNR dB') ,
        ylabel('delta in Hz') ;

    figure(2),
    plot(snr, var_a(2,:), snr, cov_a(2,:), snr, real_var_a(2, :))
        title('ќценка a2'),
        legend('Estimated', 'Calculated', 'Real variance') ,
        xlabel('SNR dB') ,
        ylabel('delta in Hz') ;
        
    figure(3),
    
    plot(snr, var_poles ./ var_poles(end) , '-r', ...
         snr, actual_delta ./ actual_delta(end), '-g',  ...
         snr, var_a(1,:) ./ var_a(1,end), '-b',  ...
         snr, var_a(2,:) ./ var_a(2,end), '-c');
     
     legend('poles', 'freq', 'var a1', 'var a2');
     xlabel('SNR dB');
    
end ;
    

%plot(snr, actual_delta, snr, marple_delta)
%    legend('Actual', 'Marple') ,
%    xlabel('SNR dB') ,
%    ylabel('delta in Hz') ;

% 1.03 / (p*SNR*(p+1)^0.31)
%fprintf('Error estimation %.02f\n', 1.03/(2*(0.5/sigma)*(2+1)^0.31) ) ;
%fprintf('resolution: %.02f\t delta:%.02f\t true freq: %d\n', ...
%        freq*fd/2/pi, f-freq*fd/2/pi, f) ;
    
% Hjw = freqz(1,a) ;
% [X,omega] = pwelch(x, 1000) ;
% 
% hold off, semilogy(omega,X.*conj(X), 'LineWidth',2);
% hold on,semilogy(omega(1:numel(Hjw)),Hjw.*conj(Hjw),'r-','LineWidth',2), grid on
% legend('Welch spectrum estimation', '2rd order AR model')