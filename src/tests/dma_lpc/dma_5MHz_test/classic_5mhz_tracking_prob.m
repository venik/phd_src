clc; clear all;
curPath = pwd() ;
cd('..\\..\\tsim\\model') ;
modelPath = pwd() ;
cd( curPath ) ;
addpath(modelPath) ;

N = 5456 ;
PRN = 31;

otstup = 0;

prob = 0 ;
mean_time = 0 ;
times = 0 ;

while otstup < N * 170
    
    otstup = otstup + 100 ;
    res = 0 ;
    
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

        num_var = 10 ;
        if time > num_var
            ss = sum(CarrierError(time: -1: time-num_var).^2) / num_var ;
            %fprintf('\t sum %.2f\n', ss) ;

            if ss < 0.01
                fprintf('lock, time: %d\n', time) ;
                res = 1 ;
                break ;
            end ; % if ss
        end ; % if time

        if time == settings.processTime
            break
        else
            time = time + 1;
        end
    end % while true
    
    times = times + 1 ;
    
    if res == 1
        prob = prob + 1 ;
        mean_time = mean_time + time ;
    end ;

end % otstup < N * 10

fprintf('PRN:%d\n', PRN);
fprintf('times %d\n', times(1)) ;

mean_time = mean_time ./ prob ;
prb = prob ./ times ;
fprintf('Mean time of lock: %.2f Probability: %.2f\n', mean_time, prb) ;

% subplot(2,1,2), plot(I), xlabel('врем€, мс'), ylabel('Ёнерги€'), phd_figure_style(gcf) ;
% subplot(2,1,1), plot(CarrierError, 'k'), xlabel('врем€, мс'), ylabel('ќшибка'), phd_figure_style(gcf) ;

rmpath(modelPath) ;