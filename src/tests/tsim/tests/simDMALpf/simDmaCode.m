% <! DMA signal model
clc, clear ;
% get access to model
curPath = pwd() ;
cd('..\\..\\model') ;
modelPath = pwd() ;
cd( curPath ) ;
addpath(modelPath) ;

plot_opt = '+++' ;

% !< Sim. Parameters
PRN = 29 ;
fcr = 4090000 ;
fs = 5456000 ;
fc = 1023000 ;
N = round(fs/1000) ; % samples/ms
dmaDelta = 10 ;

% !< Get DMA code
ca_code = get_ca_code(round(fc/1000)*3+1,PRN) ;
ca_indices = round(fc/fs*(0:N*3-1))+1 ;
prs = ca_code(ca_indices) ;
dmaPrs = prs(1:N*2).*prs(1+dmaDelta:N*2+dmaDelta) ;

% compute ideal acf
prsAcf = zeros(N,1) ;
for k=1:N
    prsAcf(k) = sum(dmaPrs(1:N).*dmaPrs(1+(k-1):N+(k-1)))/N ;
end
if plot_opt(1)=='+'
    plot(fftshift(prsAcf),'Color',[0.4 0.4 0.9],'LineWidth',2) ;
end

% Carrier and prs
phasearg = (0:N*3-1)*2*pi*fcr/fs ;
x = cos(phasearg(:)).*prs ;
carPrs = x(1:N*2).*x(1+dmaDelta:N*2+dmaDelta) ;
% compute carrier acf
carAcf = zeros(N,1) ;
for k=1:N
    carAcf(k) = sum(carPrs(1:N).*dmaPrs(1+(k-1):N+(k-1)))/N ;
end
if plot_opt(2)=='+'
    hold on,
    plot(-fftshift(carAcf),'Color',[0.9 0.45 0.45],'LineWidth',3) ;
end

% filtered dma
h = firls(64,[0 0.5 0.55 1.0],[1 1 0 0]) ;
fltPrs = filter(h,1,carPrs) ;
% compute filtered dma acf
fltAcf = zeros(N,1) ;
for k=1:N
    fltAcf(k) = sum(fltPrs(1:N).*dmaPrs(1+(k-1):N+(k-1)))/N ;
end
if plot_opt(3)=='+'
    hold on,
    plot(-fftshift(fltAcf),'Color',[0.5 0.7 0.55],'LineWidth',3) ;
end

grid on ;
set(gca,'FontSize',14) ;
set(gca,'LineWidth',2) ;
set(gca,'Color',[1 1 0.93]) ;

legend('CCF(code,code)', 'CCF(code,carr_code)', 'CCF(code,filt)') ;

% remove model path
rmpath(modelPath) ;