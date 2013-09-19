clc, clear all, clf ;

f = 30 ;
fd = 100 ;
N = 1000 ;
times = 10000 ;

%sigma = 0.005:0.005:0.5 ;
sigma = 1 ;

%marple_delta = zeros(length(sigma), 1) ;
%actual_delta = zeros(length(sigma), 1) ;

% a vector for NON noise case
real_a = [0.6180; 1] ;

var_a = zeros(2, length(sigma)) ;
cov_a = zeros(2, length(sigma)) ;

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
        
        %actual_delta(k) = actual_delta(k) + abs(f - freq*fd/2/pi) ;
        var_a(:, k) = var_a(:, k) + (a(2:3) - real_a).^2 ;
    end ;  % tt
    
    %actual_delta(k) = actual_delta(k) / times ;
    % marple eq 7.35 in Marple book
    %marple_delta(k) = 1.03/(2*(0.5/sigma(k))*(2+1 )^0.31) ;
    
    var_a(:, k) = var_a(:, k) / times ;
    
    % 11a equation in
    % Noise Compensation for AR Spectral Estimates
    cov_matrix = sigma(k) / N * Rxx^-1 ;
    cov_a(:, k) = cov_matrix(:, 1) ;
end ;   %for k=1:length(sigma)


if length(sigma > 1)
    snr = 10*log(0.5./sigma) ;

    figure(1),
    plot(snr, est_a(1,:), snr, cov_a(1,:))
        legend('Estimated', 'Calculated') ,
        xlabel('SNR dB') ,
        ylabel('delta in Hz') ;

    figure(2),
    plot(snr, est_a(2,:), snr, cov_a(2,:))
        legend('Estimated', 'Calculated') ,
        xlabel('SNR dB') ,
        ylabel('delta in Hz') ;
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