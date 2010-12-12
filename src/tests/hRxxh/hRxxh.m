% noise energy estimation routine
clc, clear all;
sigma_n = .4 ;
drw_pts = 500 ;

%N_filt = 128 ;
%N = 1024*128 ;
N = 16368 ;
N_filt = 2 ;


xp = cos(2*pi/N_filt*(0:(N_filt-1))).' ;
xp(xp>0) = 2 ;
xp(xp<0) = -3 ;
x = repmat(xp,N/N_filt,1) ;

y = x + randn(size(x))*sigma_n ;
h = xp(end:-1:1) ;

offs = 90 ;
%hold off, plot(1+offs:(length(y)+offs),y)
hold off, plot(1+offs:(length(x(1:drw_pts))+offs),x(1:drw_pts),'g-','LineWidth',2,'Color',[0 0.7 0])
hold on, plot(1+offs:(length(y(1:drw_pts))+offs),y(1:drw_pts))

% convolution
%f = zeros(size(x)) ;
%for k=1:length(x)
%    for n=1:min(k,length(h))
%        f(k) = f(k) + h(n)*y(k-n+1) ;
%    end
%end
f = conv(h, y) ;

%X = zeros(N_filt,N_filt) ;
%for k=1:N_filt
    %X(:,k) = [xp(k:end);xp(1:k-1)] ;			% by mao
%    X(:,k) = [xp(k:-1:2);xp(1:end-k+1)] ;		% by me
%end
%Rxx = X'*X/N_filt ;
%Rxx = Rxx/Rxx(1,1) ;

%hold on, plot(f(1:drw_pts)/sqrt(h'*Rxx*h),'r-','Linewidth',2)

% Es = h(end:-1:1)'*Rxx*h(end:-1:1) ;
% En = h(end:-1:1)'*eye(64)*(sigma_n)^2*h(end:-1:1) ;
% sigma_f = Es + En ;
%fprintf('sigma_y: %f  %f  %f\n',sigma_f,var(f),10*log10(Es/En)) ;

grid on ;
% analyze outputs of correlator at maximim output snr points
% sigma_s^2+sigma_n^2 ~ sigma_s^2*(N*h'*h) + sigma_n^2*(h'*h)

% it's possible to use all points for input signal
% to estimate sigma2_y
%ypik = y(N_filt:N_filt:end) ;
ypik = y ;
fpik = f(N_filt:N_filt:end) ;
sigma2_y = ypik'*ypik/length(ypik) ;
sigma2_f = fpik'*fpik/length(fpik) ;

e_sigma_n = sqrt( (sigma2_y - sigma2_f/(h'*h)/N_filt)/(1-1/N_filt)) ;
%e_sigma_n = sqrt( (sigma2_y - sigma2_f/(h'*h)/N_filt)) ;

%fprintf('Theoretical sigma_n=%f\n',sigma_n) ;
fprintf('%d peaks analyzed, sigma_n=%f, e_sigma_n=%f err = %f\n',length(fpik),sigma_n,e_sigma_n, abs(sigma_n - e_sigma_n))
str = sprintf('%d peaks analyzed, \\sigma_{n,t}=%f, \\sigma_n=%f\n',length(fpik),sigma_n,e_sigma_n) ;
title(str,'FontSize',14)
