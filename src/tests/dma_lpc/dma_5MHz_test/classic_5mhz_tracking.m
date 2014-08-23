clc; clear all;
curPath = pwd() ;
cd('..\\..\\tsim\\model') ;
modelPath = pwd() ;
cd( curPath ) ;
addpath(modelPath) ;

%fs = 5.456e6 ;
%freq = 4.092e6 ;
N = 5456 ;
%PRN = 30;
PRN = 31;

otstup = 100;

%%%%%%%
% Fine freq
settings = initSettings();
ss = FileSource(settings.fileName, 'int8', 'r');

ss.Move(otstup);

detector = Detector(PRN, ss);
detector.Execute();

fprintf('PRN:%d state:%s ca_phase:%d freq:%.2f\n', PRN, detector.State, detector.CodePhase, detector.Frequency) ;

%%%%%%%%%
% DLL/PLL part
tracker = Tracker(PRN, ss);
tracker.Init(detector.CodePhase, detector.Frequency);
                
proc_time = settings.processTime;
                
I = zeros(proc_time, 1);
Q = zeros(proc_time, 1);
CarrierFrequency = 0;
CodeError = zeros(proc_time, 1);
CarrierError = zeros(proc_time, 1);
time = 1;

while true
    tracker.Execute();

    if strcmp(tracker.State, 'nodata')
        break
    end

    I(time) = tracker.I;
    Q(time) = tracker.Q;
    CodeError(time) = tracker.codeErr;
    CarrierError(time) = tracker.carrErr;
    
    nnn = 10 ;
    if time > nnn
        ss = sum(CarrierError(time:-1:time-nnn).^2) / nnn ;
        fprintf('%.4f\n', ss ) ;
        
        if abs(ss) < 0.01
            fprintf('lock time:%5d\n', time) ;
            % break;
        end
    end
    
    if time == settings.processTime
        break
    else
        time = time + 1;
    end
end

subplot(2,1,2), plot(I), xlabel('врем€, мс'), ylabel('Ёнерги€'), phd_figure_style(gcf) ;
subplot(2,1,1), plot(CarrierError, 'k'), xlabel('врем€, мс'), ylabel('ќшибка'), phd_figure_style(gcf) ;


rmpath(modelPath) ;