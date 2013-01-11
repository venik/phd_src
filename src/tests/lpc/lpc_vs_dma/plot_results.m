
% dma
load('result_dma.mat', 'snr_db', 'succ') ;
snr_db_dma = snr_db ;
succ_dma = succ ;

% dma
load('result_corr.mat', 'snr_db', 'succ') ;
snr_db_corr = snr_db ;
succ_corr = succ ;


plot(snr_db_dma, succ_dma, '-gx', snr_db_corr, succ_corr, '-ro'),
    grid on,
    legend('DMA', 'Correlator') ;
%plot(snr_db_dma, succ_dma)