clc, clear, clf ;
% get access to model
curPath = pwd() ;
cd('..\\tsim\\model') ;
modelPath = pwd() ;
cd( curPath ) ;
addpath(modelPath) ;
    
% save('strong_vs_weak_data.mat','times','res_a1a2','match','a1','a2',...
%     'N','fs','f1','f2','sigma','tau','tau_s2') ;

load('strong_vs_weak_data_50000.mat');

base_line = repmat(7, 1, length(res_a1a2));
a2_dB = 10*log10(a2./a1) ;

figure(1),
    semilogy(a2_dB, 1- match, '-kx'),
    ylabel('Вероятность пропуска'),
    xlabel('ОСШ дБ', 'FontSize', 18),
    phd_figure_style(gcf) ;

figure(2)
semilogy(a2_dB, res_a1a2, '-kx', a2_dB, base_line, '-ko'),
    h_legend = legend('1', '2') ;
    set(h_legend, 'FontSize', 18),
    xlabel('ОСШ дБ', 'FontSize', 18),
    ylabel('Макс/СКО дБ', 'FontSize', 18),
    phd_figure_style(gcf) ;
    
% remove model path
rmpath(modelPath) ;