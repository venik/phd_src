% <! DMA Filter design
% <! This code compute low pass DMA filter for real signal processing
% <! and check for proper spectral mitigation vs time
% <! domain code alignment 
clc, clear ;
% get access to model
curPath = pwd() ;
cd('..\\..\\model') ;
modelPath = pwd() ;
cd( curPath ) ;
addpath(modelPath) ;

% !< Sim. Parameters
PRN = 29 ;
fs = 5456000 ;
fc = 1023000 ;
N = 5456*8 ;
dmaDelta = 10 ;

% !< Get code
ca_code = get_ca_code(1023*8+1,PRN) ;
ca_indices = round(fc/fs*(0:N-1))+1 ;
prs = ca_code(ca_indices) ;

% make input signal
phasearg = (0:N-1)*2*pi*4092000/5456000 ;
%x = cos(phasearg(:)).*prs ;
x = prs ;

figure(1) ; set(gcf,'Name','Spectral check')

newcode_x = x(1:5456).*x(1+dmaDelta:5456+dmaDelta) ;
[DMA_X,omega] = pwelch(newcode_x,512,256,512,5456000);
plot(omega,DMA_X,'Color',[0.3 0.6 0.3],'LineWidth',2) 
xlabel('Frequency, Hz') ;

hold on
x = sin(phasearg(:)).*prs ;
dma_x = x(1:5456).*x(1+dmaDelta:5456+dmaDelta) ;
[DMA_X,omega] = pwelch(dma_x,512,256,512,5456000);
plot(omega,DMA_X,'Color',[0.9 0.6 0.6],'LineWidth',2) ;

x = cos(phasearg(:)).*prs ;
dma_x = x(1:5456).*x(1+dmaDelta:5456+dmaDelta) ;
h = firls(64,[0 0.65 0.75 1.0],[1 1 0 0]) ;
fdma_x = filter(h,1,dma_x) ;
[DMA_X,omega] = pwelch(fdma_x,512,256,512,5456000);
plot(omega,DMA_X,'Color',[0.6 0.6 0.9],'LineWidth',2) ;
grid on ;

% alignment check
figure(2) ; set(gcf,'Name','Time Alignment')
hold off, plot(newcode_x,'Color',[0.4 0.4 0.9],'LineWidth',2) ;
% Why should I use  - sign?
hold on, plot(-fdma_x(1+32:end),'Color',[0.9 0.4 0.4],'LineWidth',2) ;
grid on ; 

% remove model path
rmpath(modelPath) ;