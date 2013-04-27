clc, clear all ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parameters for define
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
n2 = -5:15 ; % !!! in SNR dB
A = 1 ;     % sine amplitude
times = 10 ;% number of simulation times
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

N = 16368 ;
fsig = 3000 ;

% storage for variance
w_delta = zeros(numel(n2), 1) ;
A_delta = zeros(numel(n2), 1) ;

w_3_delta = zeros(numel(n2), 1) ;
A_3_delta = zeros(numel(n2), 1) ;

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
        z2 = [rxx(1)/2;1] ;
        % for 3 terms
        z3 = [rxx(1)/2;rxx(1)/2;1] ;

        tau = 1 ;
        for n=1:5
            % one term
            
            % Get Jacobian for 2 terms
            J = [cos(z2(2)*tau) -tau*z2(1)*sin(z2(2)*tau);...
                cos(2*z2(2)*tau) -2*tau*z2(1)*sin(2*z2(2)*tau)] ;

            % Update solution for 2 terms
            z2 = z2 + pinv(J)* ...
                (-[z2(1)*cos(z2(2)*tau)-rxx(2);z2(1)*cos(2*z2(2)*tau)-rxx(3)]) ;

            % Get Jacobian for 3 terms
            J1 = [1 1 0;...
                cos(z3(3)*tau) 0 -tau*z3(1)*sin(z3(3)*tau);...
                cos(2*z3(3)*tau) 0 -2*tau*z3(1)*sin(2*z3(3)*tau)] ;

            % Update solution
            z3 = z3 + pinv(J1)* ...
                (-[z3(1)+z3(2)-rxx(1) ; z3(1)*cos(z3(3)*tau)-rxx(2) ; z3(1)*cos(2*z3(3)*tau)-rxx(3)]) ;
        end

        %fprintf('Frequency: %f\n', mod(z(2)*16368/2/pi,16368/2)) ;
        %fprintf('Signl Enr: %f\n', z(1)/N) ;
        
        mod(z2(2)*16368/2/pi,16368/2)
        w_delta(i) = w_delta(i) + (fsig - mod(z2(2)*16368/2/pi,16368/2))^2 ;
        A_delta(i) = A_delta(i) + (z2(1)/N - A^2/2)^2;
        
        mod(z3(3)*16368/2/pi,16368/2)
        w_3_delta(i) = w_3_delta(i) + (fsig - mod(z3(3)*16368/2/pi,16368/2))^2 ;
        A_3_delta(i) = A_3_delta(i) + (z3(1)/N - A^2/2)^2;
    end
    
    % normalie
    w_delta(i) = w_delta(i) / times ;
    A_delta(i) = A_delta(i) / times ;
    
    w_3_delta(i) = w_3_delta(i) / times ;
    A_3_delta(i) = A_3_delta(i) / times ;
    
end % for i=n(1):n(end)

if A>0
    figure(1), grid on,
        subplot(2,1,1),
            plot(n2, w_delta, '-mo', n2, w_3_delta, '-bx'),
            title('freq estimation variance with signal'),
            grid on, xlabel('SNR'), ylabel('Variance'),
            legend('2 terms', '3 terms'),
        subplot(2,1,2),
            plot(n2, A_delta, '-mo', n2, A_3_delta, '-bx'),
            title('Energy estimation variance with signal'),
            grid on, xlabel('SNR'), ylabel('Variance'),
            legend('2 terms', '3 terms'),
else
    figure(1)
        subplot(2,1,1),
            plot(n2, w_delta, '-mo', n2, w_3_delta, '-bx'),
            title('freq estimation variance withOUT signal'),
            grid on, xlabel('SNR'), ylabel('Variance'),
            legend('2 terms', '3 terms'),
        subplot(2,1,2),
            plot(n2, A_delta, '-mo', n2, A_3_delta, '-bx'),
            title('Energy estimation variance withOUT signal'),
            grid on, xlabel('SNR'), ylabel('Variance'),
            legend('2 terms', '3 terms'), 
end