clc, clear all ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parameters for define
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
n2 = 0:15 ; % !!! in SNR dB
A = 1 ;     % sine amplitude
times = 10 ;% number of simulation times
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
        %txx = [cos(2*pi*fsig/16368*0);cos(2*pi*fsig/16368*1);cos(2*pi*fsig/16368*2)]*N/2 ;
        %cxx = [txx(1)+n2*N;txx(2);txx(3)] ;
        %[rxx, txx, cxx]

        % Utilize Newton iterations to compute 
        % Signal Energy, Noise Energy and Frequency
        z = [rxx(1)/2;1] ;
        tau = 1 ;
        for n=1:20
            % Get Jacobian
            J = [cos(z(2)*tau) -tau*z(1)*sin(z(2)*tau);...
                cos(2*z(2)*tau) -2*tau*z(1)*sin(2*z(2)*tau)] ;

            % Update solution
            z = z + pinv(J)* ...
                (-[z(1)*cos(z(2)*tau)-rxx(2);z(1)*cos(2*z(2)*tau)-rxx(3)]) ;
        end

        %[z,[txx(1);n2*N;2*pi*fsig/16368]]

        %fprintf('Frequency: %f\n', mod(z(2)*16368/2/pi,16368/2)) ;
        %fprintf('Signl Enr: %f\n', z(1)/N) ;
        
        w_delta(i) = w_delta(i) + mod(z(2)*16368/2/pi,16368/2) ;
        A_delta(i) = A_delta(i) + z(1)/N ;
    end
    
    % normalie
    w_delta(i) = w_delta(i) / times ;
    A_delta(i) = A_delta(i) / times ;
    
end % for i=n(1):n(end)

w_line = ones(numel(n2), 2) .* fsig ;
A_line = ones(numel(n2), 2) .* (A^2/2) ;

if A>0
    figure(1)
        subplot(2,1,1), title('With signal'),
            plot(n2, w_line, '-bx', n2, w_delta, '-mo'),
            %legend('Freq', 'Est freq'),
        subplot(2,1,2), plot(n2, A_line, '-bx', n2, A_delta, '-mo'),
            %legend('E', 'Est E'),
else
    figure(1)
        title('With signal'),
        subplot(2,1,1), plot(n2, w_delta, '-mo'),
            %legend('Freq', 'Est freq'),
        subplot(2,1,2), plot(n2, A_delta, '-mo'),
            %legend('E', 'Est E'),    
end