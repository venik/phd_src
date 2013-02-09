clc, clear all ;
N = 16368 ;
fsig = 3000 ;

tries = 100 ;
noise = 1:2:30 ;
a = 1 ;

noise_est = zeros(numel(noise), 1) ;
sig_est = zeros(numel(noise), 1) ;
fsig_est = zeros(numel(noise), 1) ;

for k=1:numel(noise)
    fprintf('k=%02d\n', k) ;
    for kk=1:tries
        n2 = noise(k) ; % !!!
        x = a*cos(2*pi*fsig/16368*(0:N-1)) + randn(1,N)*sqrt(n2) ;
        rxx = [x*circshift(x,0)';x*circshift(x',1);x*circshift(x',2)] ;
        txx = [cos(2*pi*fsig/16368*0);cos(2*pi*fsig/16368*1);cos(2*pi*fsig/16368*2)]*N/2 ;
        cxx = [txx(1)+n2*N;txx(2);txx(3)] ;
        [rxx, txx, cxx] ;

        % Utilize Newton iterations to compute 
        % Signal Energy, Noise Energy and Frequency
        %z = [rxx(1)/2;rxx(1)/2;1] ;
        z = [rxx(1);rxx(1);1] ;
        tau = 1 ;
        for n=1:10
            % Get Jacobian
            J = [1 1 0;...
                cos(z(3)*tau) 0 -tau*z(1)*sin(z(3)*tau);...
                cos(2*z(3)*tau) 0 -2*tau*z(1)*sin(2*z(3)*tau)] ;

            % Update solution
            z = z + pinv(J)* ...
                (-[z(1)+z(2)-rxx(1);z(1)*cos(z(3)*tau)-rxx(2);z(1)*cos(2*z(3)*tau)-rxx(3)]) ;
        end % n=1:10
        
        noise_est(k) = noise_est(k) + z(2)/N ;
        sig_est(k) = sig_est(k) + z(1)/N ;
        fsig_est(k) = fsig_est(k) + mod(z(3)*16368/2/pi,16368/2) ;
        
    end % kk=1:tries
    
    noise_est(k) = noise_est(k) / tries ;
    sig_est(k) = sig_est(k) / tries ;
    fsig_est(k) = fsig_est(k) / tries ;
    
end % for k=1:numel(noise)

figure(1), plot(noise, noise_est, '-rx', noise, noise, '-g*'),
    title('Оценка мощности шума', 'FontSize',18),
    xlabel('Мощность шума', 'FontSize',18),
    ylabel('Оценка мощности шума', 'FontSize',18),
    grid on,
    h_legend = legend('Оценка мощности шума', 'Мощность шума');
    set(h_legend,'FontSize',18) ;


sig_real = a^2 / 2 ;
sig_real = repmat(sig_real, 1, numel(noise)) ;
    
figure(2), plot(noise, sig_est, '-rx', noise, sig_real, '-g*'),
    title('Оценка мощности сигнала', 'FontSize',18),
    xlabel('Мощность шума', 'FontSize',18),
    ylabel('Оценка мощности сигнала', 'FontSize',18),
    grid on,
    h_legend = legend('Оценка мощности сигнала', 'Мощность сигнала');
    set(h_legend,'FontSize',18) ;
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    fsig_real = repmat(fsig, 1, numel(noise)) ;
    
figure(3), plot(noise, fsig_est, '-rx', noise, fsig_real, '-g*'),
    title('Оценка частоты сигнала', 'FontSize',18),
    xlabel('Мощность шума', 'FontSize',18),
    ylabel('Оценка частоты сигнала', 'FontSize',18),
    grid on,
    %h_legend = legend('Оценка частоты сигнала', 'Частота сигнала');
    %set(h_legend,'FontSize',18) ;
    
%[z,[txx(1);n2*N;2*pi*fsig/16368]]

%fprintf('Frequency: %f\n', mod(z(3)*16368/2/pi,16368/2)) ;
%fprintf('Noise Enr: %f\n', z(2)/N) ;
%fprintf('Signl Enr: %f\n', z(1)/N) ;