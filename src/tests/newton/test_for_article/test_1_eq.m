clc, clear all ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parameters for define
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
n2 = -5:1:15 ; % !!! in SNR dB
A = 1 ;     % sine amplitude
times = 100 ;% number of simulation times
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

N = 16368 ;
fsig = 3000 ;

% storage for variance
w_delta = zeros(numel(n2), 1) ;
A_delta = zeros(numel(n2), 1) ;

for i=1:numel(n2)
    fprintf('Stage %d dB\n', n2) ;
    for j=1:times
        x = A*cos(2*pi*fsig/16368*(0:N-1));
        signoise = 10^(-n2(i)/10)*var(x) ;
        x = x + randn(1,N)*sqrt(signoise) ;
        rxx = [x*circshift(x,0)';x*circshift(x',1);x*circshift(x',2)] ;
        
        % Utilize Newton iterations to compute 
        % Signal Energy, Noise Energy and Frequency        
        
        % for 2 terms
        z2 = [rxx(1)/2;1000/16368*2*pi] ;
        
        tau = 1 ;
        for n=1:10
            num = rxx(2)*cos(z2(2)*2) - rxx(3)*cos(z2(2)) ;
            denom = -2*rxx(2)*sin(z2(2)*2) + rxx(3)*sin(z2(2));
            
            z2(2) = z2(2) - num/denom ;
        end

        freq = mod(z2(2)*16368/2/pi,16368/2);
        fprintf('Frequency: %.2f E=%.2f\n', freq, rxx(2) / cos(z2(2)) / N) ;        
        
        w_delta(i) = w_delta(i) + (fsig - mod(z2(2)*16368/2/pi,16368/2))^2 ;
        A_delta(i) = A_delta(i) + (rxx(2) / cos(z2(2)) / N - A^2/2)^2;
    end
    
    % normalie
    w_delta(i) = w_delta(i) / times ;
    A_delta(i) = A_delta(i) / times ;

end % for i=n(1):n(end)

% dont want to plot a point
if numel(n2) == 1
    return;
end

if A>0
    figure(1), grid on,
        subplot(2,1,1),
            plot(n2, w_delta, '-mo'),
            title('freq estimation variance with signal 1 equation'),
            grid on, xlabel('SNR'), ylabel('Variance')
        subplot(2,1,2),
            plot(n2, A_delta, '-mo'),
            title('Energy estimation variance with signal 1 equation'),
            grid on, xlabel('SNR'), ylabel('Variance')
else
    figure(1)
        subplot(2,1,1),
            plot(n2, w_delta, '-mo'),
            title('freq estimation variance withOUT signal 1 equation'),
            grid on, xlabel('SNR'), ylabel('Variance'),
        subplot(2,1,2),
            plot(n2, A_delta, '-mo'),
            title('Energy estimation variance withOUT signal 1 equation'),
            grid on, xlabel('SNR'), ylabel('Variance'),
end