clc, clear all ;
% get access to model
curPath = pwd() ;
cd('..\\..\\..\\model') ;
modelPath = pwd() ;
cd( curPath );
addpath(modelPath) ;

% ADD CODE HERE
% get received signal
N = 100 ;
preciseFreq = zeros(N,1) ;
roughFreq = zeros(N,1) ;
for n= 1:N
[x1,y1] = if_signal_model( 1,5 ) ;
[x,y,sats, delays, signoise] = if_signal_model( [1 2 3], 0 ) ;
% remove code from first sattelite
code_off = delays(1) ;
code1 = get_ca_code16(1023*2+20,sats(1)) ;
x1 = x1.*code1(1+delays(1):16368*2+delays(1)) ;
x = y.*code1(1+code_off:16368*2+code_off) ;

% get precise frequency and power
roughFreq(n) = 3900+rand()*200 ;
[preciseFreq(n), precisePower] = get_precise_frequency2(x(1:16368*2), roughFreq(n), 16368.0 ) ;

%fprintf('Frequency: %5.2f\n', preciseFreq ) ;
%fprintf('Power:     %5.2f\n', precisePower ) ;
end

hold off, plot(preciseFreq) ;
hold on, plot(roughFreq,'Color',[0.7 0.7 0.7]) ;
hold on, plot([1 N],[4000 4000],'k-.')
hold on, plot([1 N],[mean(preciseFreq) mean(preciseFreq)],'r-.')
round(mean(preciseFreq))


% remove model path
rmpath(modelPath) ;