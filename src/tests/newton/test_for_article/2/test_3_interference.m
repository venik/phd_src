clc, clear all ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parameters for define
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
n2 = 20 ; % !!! in SNR dB
A = 1 ;     % sine amplitude
times = 1 ;% number of simulation times
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

N = 16368 ;
fsig = 3000 ;

fsig_int = 4000 ;
A_int = 1 ;     % sine amplitude
phase_int = 0 ;

% storage for variance
w_delta = zeros(numel(n2), 1) ;
A_delta = zeros(numel(n2), 1) ;

w_3_delta = zeros(numel(n2), 1) ;
A_3_delta = zeros(numel(n2), 1) ;

tau1 = 5 ;
tau2 = 8 ;
tau3 = 23 ;
tau4 = 24 ;

for i=1:numel(n2)
    fprintf('Stage %d dB\n', n2) ;
    for j=1:times
        x = A*cos(2*pi*fsig/16368*(0:2 * N-1));         % sig

        code = get_ca_code16(1023, 1) ;             % interference
        code = repmat(code, 2, 1) ;
        x_intf = A_int * cos(2*pi*fsig_int/16368*(0:2*N-1));
        x_intf = x_intf .* code' ;
        % x_intf = circshift(x_intf, phase_int) ;
        x_intf = [x_intf(phase_int + 1 : end), x_intf(1 : phase_int)] ;
        
        signoise = 10^(-n2(i)/10)*var(x) ;          % noise
        
        %x = x + randn(1,2*N)*sqrt(signoise) + x_intf;
        
        % rxx = [x*circshift(x,0)';x*circshift(x',tau1);x*circshift(x',tau2)] ;
        
        %rxx0 = x(1 : N) * x(1 : N).' ;
        %rxx1 = x(1 : N) * x(1 + tau1 : N + tau1).' ;
        %rxx2 = x(1 : N) * x(1 + tau2 : N + tau2).' ;
        %rxx = [rxx0 / N, rxx1 / N, rxx2 / N]
        rxx = zeros(30,1) ;
        for idx=1:30
            rxx(idx) = sum(x(1 : N) .* x(1 + idx-1 : N + idx-1))/N ;
        end
        %hold off, plot(0:29,rxx), hold on, plot(tau1,rxx(tau1+1),'r^'), plot(tau2,rxx(tau2+1),'ro'), plot(tau3,rxx(tau3+1),'ro'), plot(tau4,rxx(tau4+1),'ro') ;
        %hold off, plot(0:29,rxx), hold on, plot(tau1,rxx(tau1+1),'r^'), plot(tau2,rxx(tau2+1),'ro'), grid on ;
        
        % Utilize Newton iterations to compute 
        % Signal Energy, Noise Energy and Frequency        

        % for 2 terms
        z2 = [0.5;4092/16368*2*pi] ;
        %z2 = [rxx(1) / 2;1] ;
        % for 3 terms
        z = [rxx(1)/2;rxx(1)/2;1] ;

        step = 10 ;
        A_step = zeros(step + 1, 1) ;
        w_step = zeros(step + 1, 2) ;
        
        A_step(1) = z2(1) ;
        %w_step(1) = z2(2) ;
        
        for n=1:step
            % Get Jacobian for 2 terms
            J = [cos(z2(2)*tau1) -tau1 * z2(1)*sin(z2(2)*tau1);...
                 cos(z2(2)*tau2) -tau2 * z2(1)*sin(z2(2)*tau2)];
                 %cos(z2(2)*tau3) -tau3 * z2(1)*sin(z2(2)*tau3);...
                 %cos(z2(2)*tau4) -tau4 * z2(1)*sin(z2(2)*tau4)] ;
             %rcond(J)

            % Update solution for 2 terms
            z2 = z2 + pinv(J)* ...
                (-[z2(1)*cos(z2(2)*tau1)-rxx(tau1+1); ...
                   z2(1)*cos(z2(2)*tau2)-rxx(tau2+1)]) ;
                   %z2(1)*cos(z2(2)*tau3)-rxx(tau3+1); ...
                   %z2(1)*cos(z2(2)*tau4)-rxx(tau4+1);]) ;

            A_step(n+1) = z2(1) ;
            w_step(n+1) = mod(z2(2)*16368/2/pi,16368/2) ;
                   
            % Get Jacobian
            J1 = [1 1 0;...
                cos(z(3)*tau1) 0 -tau1*z(1)*sin(z(3)*tau1);...
                cos(z(3)*tau2) 0 -tau2*z(1)*sin(z(3)*tau2)] ;

            % Update solution
            z = z + pinv(J1)* ...
                (-[z(1)+z(2)-rxx(1);
                   z(1)*cos(z(3)*tau1)-rxx(2);
                   z(1)*cos(z(3)*tau2)-rxx(3)]) ;
        end
        
        w_delta(i) = w_delta(i) + (fsig - mod(z2(2)*16368/2/pi,16368/2))^2 ;
        A_delta(i) = A_delta(i) + (z2(1)/N - A^2/2)^2;

        w_3_delta(i) = w_3_delta(i) + (fsig - mod(z(3)*16368/2/pi,16368/2))^2 ;
        A_3_delta(i) = A_3_delta(i) + (z(1)/N - A^2/2)^2;
        
        freq2 = mod(z2(2)*16368/2/pi,16368/2) ;
        freq3 = mod(z(3)*16368/2/pi,16368/2) ;
        
        fprintf('freq2: %.2f  E=%5f\nfreq3: %.2f\n', freq2, z2(1), freq3) ;
    end
    
    [z2(1)*cos(z2(2)*tau1)-rxx(tau1+1),z2(1)*cos(z2(2)*tau2)-rxx(tau2+1)]
    
    % normalie
    w_delta(i) = w_delta(i) / times ;
    A_delta(i) = A_delta(i) / times ;
    
    w_3_delta(i) = w_3_delta(i) / times ;
    A_3_delta(i) = A_3_delta(i) / times ;
    
end % for i=n(1):n(end)

figure(2),
    subplot(2,1,1),
        plot(0:step, A_step), grid on, 
            title('Energy'),  xlabel('step'),
    subplot(2,1,2),
        plot(0:step, w_step), grid on, 
            title('freq'),  xlabel('step'),

% if A>0
%     figure(1), grid on,
%         subplot(2,1,1),
%             plot(n2, w_delta, '-mo', n2, w_3_delta, '-bx'),
%             title('freq estimation variance with signal'),
%             grid on, xlabel('SNR'), ylabel('Variance'),
%             legend('2 terms', '3 terms'),
%         subplot(2,1,2),
%             plot(n2, A_delta, '-mo', n2, A_3_delta, '-bx'),
%             title('Energy estimation variance with signal'),
%             grid on, xlabel('SNR'), ylabel('Variance'),
%             legend('2 terms', '3 terms'),
% else
%     figure(1)
%         subplot(2,1,1),
%             plot(n2, w_delta, '-mo', n2, w_3_delta, '-bx'),
%             title('freq estimation variance withOUT signal'),
%             grid on, xlabel('SNR'), ylabel('Variance'),
%             legend('2 terms', '3 terms'), 
%         subplot(2,1,2),
%             plot(n2, A_delta, '-mo', n2, A_3_delta, '-bx'),
%             title('Energy estimation variance withOUT signal'),
%             grid on, xlabel('SNR'), ylabel('Variance'),
%             legend('2 terms', '3 terms'), 
% end