% <! DMA signal model
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

newcode = prs(1:5456*4).*prs(1+dmaDelta:5456*4+dmaDelta) ;
x = sin(phasearg(:)).*prs ;
dma_x = x(1:5456*4).*x(1+dmaDelta:5456*4+dmaDelta) ;
hold off, plot(newcode,'Color',[0.4 0.4 0.9],'LineWidth',2) ;
hold on, plot(-dma_x,'Color',[0.9 0.4 0.4],'LineWidth',2) ;

% remove model path
rmpath(modelPath) ;