clc, clear all ;
% get access to model
curPath = pwd() ;
cd('..\\..\\..\\model') ;
modelPath = pwd() ;
cd( curPath );
addpath(modelPath) ;

n1 = 1 ;
n2 = 2 ;
n3 = 11 ;
n4 = 12 ;

fs = 4000 ;
Pwr = 1.0 ; 
I1 = 1.5 ;
I2 = 0.6 ;
r1 = Pwr*cos(n1*2*pi*fs/16368) + I1 ;
r2 = Pwr*cos(n2*2*pi*fs/16368) + I2 ;
r3 = Pwr*cos(n3*2*pi*fs/16368) ;
r4 = Pwr*cos(n4*2*pi*fs/16368) ;

%n2 = n2/n1 ;
%n1 = 1 ;

% newton iterations
Nnw = 15 ;
z = zeros(2,Nnw) ;
z(:,1) = [0.8; 2*pi*4092/16368*(n1-1)+2*pi*4092/16368] ;

z4 = zeros(4,Nnw) ;
InitialPwr = .5 ;
InitialAlpha = 2*pi*3600/16368*n1 ;
z4(:,1) = [InitialPwr; InitialAlpha; 0.1; 0.1] ;
for n=2:Nnw
    % frequency-energy solver 
    N_gamma = z(1,n-1) ;
    N_alpha = z(2,n-1) ;
    F = [N_gamma*cos(N_alpha)-r1; N_gamma*cos(n2/n1*N_alpha)-r2] ;
    z(:,n) = z(:,n-1) - ...
        pinv([cos(N_alpha)        -N_gamma*sin(N_alpha); ...
              cos(n2/n1*N_alpha)  -n2/n1*N_gamma*sin(n2/n1*N_alpha)])*F ;
          
    % frequency-energy-interference solver 
    N_gamma = z4(1,n-1) ;
    N_alpha = z4(2,n-1) ;
    N_I1 = z4(3,n-1) ;
    N_I2 = z4(4,n-1) ;
    F = [N_gamma*cos(N_alpha*n1)-r1+N_I1; N_gamma*cos(N_alpha*n2)-r2+N_I2; N_gamma*cos(N_alpha*n3)-r3;N_gamma*cos(N_alpha*n4)-r4] ;
    J = [ cos(N_alpha*n1), -N_gamma*n1*sin(N_alpha*n1),  1, 0; ...
          cos(N_alpha*n2), -N_gamma*n2*sin(N_alpha*n2),  0, 1; ...
          cos(N_alpha*n3), -N_gamma*n3*sin(N_alpha*n3),  0, 0; ...
          cos(N_alpha*n4), -N_gamma*n4*sin(N_alpha*n4),  0, 0; ...
          ] ;
    z4(:,n) = z4(:,n-1) - pinv(J)*F ;
end


fprintf('Two variable solver:\n') ;
fprintf('power: %5.3f\n', z(1,end) ) ;
%fprintf('alpha: %5.3f\n', z(2,end) ) ;
fprintf('Freq : %5.3f\n', z(2,end)/2/pi/n1*16368 ) ;

fprintf('Four variable solver:\n') ;
fprintf('power4: %5.3f\n', z4(1,end) ) ;
fprintf('I1: %5.3f\n', z4(3,end) ) ;
fprintf('I2: %5.3f\n', z4(4,end) ) ;
fprintf('Freq4 : %5.3f\n', z4(2,end)/2/pi/n1*16368 ) ;


alpha0 = n1*2*pi*0/16368 ;
alpha1 = n1*2*pi*16368/16368 ;
alpha = alpha0:0.01:alpha1 ;
gamma1 = (r1)./cos(alpha) ; gamma1(abs(gamma1)>6) = NaN ;
gamma2 = (r2)./cos(n2/n1*alpha) ; gamma2(abs(gamma2)>6) = NaN ;
hold off, plot( alpha/2/pi*16368/n1, gamma1, 'LineWidth', 2, 'Color',[0.7 0.7 0.7] ) ;
hold on, plot( alpha/2/pi*16368/n1, gamma2, 'LineWidth', 2, 'Color',[0.7 0.7 0.7] ) ;
gamma1 = (r1-z4(3,end))./cos(alpha) ; gamma1(abs(gamma1)>6) = NaN ;
gamma2 = (r2-z4(4,end))./cos(n2/n1*alpha) ; gamma2(abs(gamma2)>6) = NaN ;
hold on, plot( alpha/2/pi*16368/n1, gamma1, 'LineWidth', 2 ) ;
hold on, plot( alpha/2/pi*16368/n1, gamma2, 'm-', 'LineWidth', 2,'Color',[0 0.7 0.6] ) ;

hold on, plot(fs,Pwr,'^','Color',[.3 0.5 0.3],'MarkerSize',10,'LineWidth',2) ;
hold on, plot(z(2,:)/2/pi*16368/n1,z(1,:),'g-+','Color',[.8 0.1 0.1],'LineWidth',1) ;
hold on, plot(z4(2,:)/2/pi*16368/n1,z4(1,:),'g-+','Color',[.8 0.1 0.8],'LineWidth',1) ;
xlim([0 8000]) ;
set(gca,'FontSize',14)
grid on ;
xlabel('Frequency') ;
ylabel('Power') ;
title(sprintf('n_1=%d, n_2=%d, fs=%5.1f', n1,n2, fs ),'FontSize',14) ;

% remove model path
rmpath(modelPath) ;