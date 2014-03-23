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
fcr = 4092000 ;
fs = 5456000 ;
fc = 1023000 ;
N = round(fs/1000) ; % samples/ms
dmaDelta = 40 ;

% !< Get DMA code
ca_code = get_ca_code(round(fc/1000)*3+1,PRN) ;
ca_indices = round(fc/fs*(0:N*3-1))+1 ;
% ca code
prs = ca_code(ca_indices) ;
% new code
dma_prs = prs(1:N*2).*prs(1+dmaDelta:N*2+dmaDelta) ;

% DMA without filter
phasearg = (0:N*3-1)*2*pi*fcr/fs ;
x = cos(phasearg(:)).*prs ;
dma_out = x(1:N*2).*conj(x(1+dmaDelta:N*2+dmaDelta)) ;

% DMA with butterworth
Fnyq = fs/2 ;       % Nyquist freq
Fc=Fnyq/2 ;             % cut-off freq [Hz]
[b,a]=butter(2, Fc/Fnyq) ;
bt_out = filter(b, a, dma_out) ;

% DMA with FIR filter
h = firls(64,[0 0.5 0.6 1.0],[1 1 0 0]) ;
fir_out = filter(h,1,dma_out) ;

% DMA using Hilbert transform
X = fft(x) ;
Y = X ;
Y(length(Y)/2+1:end) = 0 ;
y = ifft(Y)*2 ;
ht_out = real(y(1:N*2).*conj(y(1+dmaDelta:N*2+dmaDelta))) ;

% compute acf
prs_ccf = zeros(N,1) ;
dma_ccf = zeros(N,1) ;
bt_ccf = zeros(N,1) ;
fir_ccf = zeros(N,1) ;
ht_ccf = zeros(N,1) ;
for k=1:N
    prs_ccf(k) = sum(dma_prs(1:N).*dma_prs(1+(k-1):N+(k-1)))/N ;
    dma_ccf(k) = sum(dma_out(1:N).*dma_prs(1+(k-1):N+(k-1)))/N ;
    bt_ccf(k) = sum(bt_out(1:N).*dma_prs(1+(k-1):N+(k-1)))/N ;
    fir_ccf(k) = sum(fir_out(1:N).*dma_prs(1+(k-1):N+(k-1)))/N ;
    ht_ccf(k) = sum(ht_out(1:N).*dma_prs(1+(k-1):N+(k-1)))/N ;
end

[~, dma_index0] = max(abs(dma_ccf)) ;
[~, bt_index0] = max(abs(bt_ccf)) ;
[~, fir_index0] = max(abs(fir_ccf)) ;
[~, ht_index0] = max(abs(ht_ccf)) ;

prs_slope = mean(abs(prs_ccf(2:end))) ;
dma_slope = mean(abs(dma_ccf(2:end))) ;
bt_slope = mean(abs([bt_ccf(1:bt_index0-1); bt_ccf(bt_index0+1:end)])) ;
fir_slope = mean(abs([fir_ccf(1:fir_index0-1); fir_ccf(fir_index0+1:end)])) ;
ht_slope = mean(abs(ht_ccf(2:end))) ;

%hold off, plot(dma_prs,'Color',[0.45 0.45 0.9],'LineWidth',2) ;
%hold on, plot(dma_out,'Color',[0.45 0.65 0.35],'LineWidth',2) ;
%hold on, plot(bt_out,'Color',[0.9 0.45 0.45],'LineWidth',2) ;
%hold on, plot(fir_out,'Color',[0.9 0.7 0.45],'LineWidth',2) ;

hold off, plot(fftshift(prs_ccf),'Color',[0.45 0.45 0.9],'LineWidth',2) ;
hold on, plot(fftshift(dma_ccf)*prs_slope/dma_slope,'Color',[0.3 0.65 0.35],'LineWidth',2) ;
hold on, plot(fftshift(bt_ccf)*prs_slope/bt_slope,'Color',[0.9 0.3 0.3],'LineWidth',2) ;
hold on, plot(fftshift(fir_ccf)*prs_slope/fir_slope,'Color',[0.9 0.7 0.45],'LineWidth',2) ;
hold on, plot(fftshift(ht_ccf)*prs_slope/ht_slope,'Color',[0.7 0.1 0.7],'LineWidth',2) ;

bar([prs_ccf(1), dma_ccf(1)*prs_slope/dma_slope, bt_ccf(bt_index0)*prs_slope/bt_slope, fir_ccf(fir_index0)*prs_slope/fir_slope, ht_ccf(1)*prs_slope/ht_slope]) ;

grid on ;
set(gca,'FontSize',14) ;
set(gca,'LineWidth',2) ;
set(gca,'Color',[1 1 0.94]) ;
%set(gca,'XTick',['1','2','3','4','5'])

%legend('ideal CCF', 'No filter', 'Batterforth', '64 Tap FIR', 'Hilbert') ;

% remove model path
rmpath(modelPath) ;