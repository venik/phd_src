clc, clear all ;
% get access to model
curPath = pwd() ;
cd('..\\..\\..\\model') ;
modelPath = pwd() ;
cd( curPath );
addpath(modelPath) ;

n1 = 21 ;
n2 = 22 ;

fs = 4500 ;
Pwr = 1.0 ; 
r1 = Pwr*cos(n1*2*pi*fs/16368) ;
r2 = Pwr*cos(n2*2*pi*fs/16368) ;

%n2 = n2/n1 ;
%n1 = 1 ;

alpha0 = n1*2*pi*0/16368 ;
alpha1 = n1*2*pi*16368/16368 ;
alpha = alpha0:0.01:alpha1 ;

gamma1 = r1./cos(alpha) ; gamma1(abs(gamma1)>6) = NaN ;
gamma2 = r2./cos(n2/n1*alpha) ; gamma2(abs(gamma2)>6) = NaN ;

% newton iterations
Nnw = 15 ;
z = zeros(2,Nnw) ;
z(:,1) = [0.8 2*pi*2000/16368] ;
for n=2:Nnw
    N_gamma = z(1,n-1) ;
    N_alpha = z(2,n-1) ;
    F = [N_gamma*cos(N_alpha)-r1; N_gamma*cos(n2/n1*N_alpha)-r2] ;
    z(:,n) = z(:,n-1) - ...
        pinv([cos(N_alpha)        -N_gamma*sin(N_alpha); ...
              cos(n2/n1*N_alpha)  -N_gamma*sin(n2/n1*N_alpha)])*F ;
end

fprintf('power: %5.3f\n', z(1,end) ) ;
fprintf('alpha: %5.3f\n', z(2,end) ) ;

hold off, plot( alpha/2/pi*16368/n1, gamma1, 'LineWidth', 2 ) ;
hold on, plot( alpha/2/pi*16368/n1, gamma2, 'm-', 'LineWidth', 2,'Color',[0 0.7 0.6] ) ;
hold on, plot(fs,Pwr,'^','Color',[.3 0.5 0.3],'MarkerSize',10,'LineWidth',2) ;
hold on, plot(z(2,:)/2/pi*16368/n1,z(1,:),'g-+','Color',[.8 0.1 0.1],'LineWidth',1) ;
xlim([0 8000]) ;
set(gca,'FontSize',14)
grid on ;
xlabel('Frequency') ;
ylabel('Power') ;
title(sprintf('n_1=%d, n_2=%d, fs=%5.1f', n1,n2, fs ),'FontSize',14) ;
% for n=2:Nnw
%     hold on, plot([z(2,n-1) z(2,n)]/2/pi*16368/n1,[z(1,n-1) z(1,n)],'g-+','Color',[.8 0.1 0.1],'LineWidth',1) ;
%     pause(0.3) ;
%     drawnow ;
% end

% remove model path
rmpath(modelPath) ;