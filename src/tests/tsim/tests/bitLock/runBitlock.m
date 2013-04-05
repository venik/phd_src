clc, clear all ;
% get access to model
curPath = pwd() ;
cd('..\\..\\model') ;
modelPath = pwd() ;
cd( curPath );
addpath(modelPath) ;

% ADD CODE HERE
load ('..\\..\\data\\serg_primo_data\\prn_5.mat') ;

BitFigure = zeros(20,1) ;
BitChange = zeros(size(I_P)) ;
for k=20:length(I_P)
    if (I_P(k)*I_P(k-1))<0
        BitChange(k) = 1000 ;
        bitIdx = mod(k-1,20)+1 ;
        BitFigure(bitIdx) = BitFigure(bitIdx) + 1 ;
    end
end
[~,BitEdgeIdx] = max(BitFigure) ;
BitEdge = zeros(size(I_P)) ;
BitEdge(BitEdgeIdx:20:end) = 1000 ;

figure(1) ; hold off ; plot(BitFigure), grid on ;

figure(2) ; hold off ; plot(I_P), grid on ;
hold on, plot(BitEdge, 'r-') ;

% remove model path
rmpath(modelPath) ;