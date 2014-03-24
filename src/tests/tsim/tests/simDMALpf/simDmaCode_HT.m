% <! DMA signal model
clc, clear ;
% get access to model
curPath = pwd() ;
cd('..\\..\\model') ;
modelPath = pwd() ;
cd( curPath ) ;
addpath(modelPath) ;

plot_opt = '---+-' ;
%plot_opt = '+++-+' ;

% !< Sim. Parameters
PRN = 29 ;
fcr = 4090000 ;
fs = 5456000 ;
fc = 1023000 ;
N = round(fs/1000) ; % samples/ms
dmaDelta = 40 ;

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
% Carrier and prs
phasearg = (0:N*3-1)*2*pi*fcr/fs ;
x = cos(phasearg(:)).*prs ;
carPrs = x(1:N*2).*conj(x(1+dmaDelta:N*2+dmaDelta)) ;
% compute carrier acf
carAcf = zeros(N,1) ;
for k=1:N
    carAcf(k) = sum(carPrs(1:N).*dmaPrs(1+(k-1):N+(k-1)))/N ;
end

% Carrier and prs
phasearg = (0:N*3-1)*2*pi*fcr/fs ;
x = cos(phasearg(:)).*prs ;
X = fft(x) ;
Y = X ;
Y(length(Y)/2+1:end) = 0 ;
y = ifft(Y)*2 ;
hilbPrs = real(y(1:N*2).*conj(y(1+dmaDelta:N*2+dmaDelta))) ;
% compute carrier acf
hilbAcf = zeros(N,1) ;
for k=1:N
    hilbAcf(k) = sum(hilbPrs(1:N).*dmaPrs(1+(k-1):N+(k-1)))/N ;
end

if plot_opt(1)=='+'
    plot(fftshift(prsAcf),'Color',[0.4 0.4 0.9],'LineWidth',2) ;
end
if plot_opt(3)=='+'
    hold on,
    plot(fftshift(hilbAcf),'Color',[0.3 0.8 0.3],'LineWidth',3) ;
end
if plot_opt(2)=='+'
    hold on,
    plot(fftshift(carAcf),'Color',[0.9 0.45 0.45],'LineWidth',3) ;
end


if plot_opt(4)=='+'
    hold off, plot(dmaPrs,'Color',[0.45 0.45 0.9],'LineWidth',2) ;
    hold on, plot(carPrs,'Color',[0.45 0.65 0.35],'LineWidth',2) ;
    hold on, plot(hilbPrs,'Color',[0.9 0.45 0.45],'LineWidth',2) ;
end

grid on ;
set(gca,'FontSize',14) ;
set(gca,'LineWidth',2) ;
set(gca,'Color',[1 1 0.93]) ;

if plot_opt(5)=='+'
    legend('CCF(code,code)', 'CCF(code*cos,code)', 'CCF(hilbert(code*cos),code)') ;
end


% remove model path
rmpath(modelPath) ;