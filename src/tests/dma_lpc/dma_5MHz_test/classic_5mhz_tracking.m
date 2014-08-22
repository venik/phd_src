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

%otstup = 70000 - 3645;
otstup = 2000;

y_base = load_primo_file('101112_0928GMT_primo_fs5456_fif4092.dat',N*200);
y_base = double(y_base);

y = y_base(otstup : otstup + N - 1) ;

freq = 4.092e6-5e3 : 1e3 : 4.092e6+5e3;

fs = 5.456e6 ;
N = 5456 ;

acx = 0 ;
ca_phase = 0 ;
freq_z = 0 ;

res = zeros(N, 1) ;

%%%%%%%
% Correlator

Y = fft(y);
cacode2= CACode(PRN);
CAcode1 = cacode2.Bits;  %генерируем CA код
CAcode16 = zeros(1, N);  %объ€вили сигнал —инус* на CA код 

for i=1:N
    CAcode16(i) = CAcode1(ceil(1023000/fs*i));  
end

for p=1:length(freq)   
    cos_opor = exp(-1i*2*pi*freq(p)/fs * (0:N-1));

    lo_sig = CAcode16 .* cos_opor;

    LO_SIG = fft(lo_sig);

    q = ifft(LO_SIG .* conj(Y).') ;

    acx_res = q .* conj(q) ;
    [value_x, index_x] = max(acx_res) ;

    if (value_x > acx)
        res = acx_res ;
        acx = value_x ;
        ca_phase = index_x ;
        freq_z = freq(p) ;
    end;

end; % p
    
fprintf('PRN: %02d\tCA phase: %d\tfreq: %.2f\tE/sigma: %.2f dB\n', ...
    PRN, ca_phase, freq_z, 10*log10(acx / std(res)));

%%%%%%%
% Fine freq
settings = initSettings();
ss = FileSource(settings.fileName, 'int8', 'r');

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