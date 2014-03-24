clc; clear all;
curPath = pwd() ;
cd('..\\..\\tsim\\model') ;
modelPath = pwd() ;
cd( curPath ) ;
addpath(modelPath) ;

delta1 = 10; %дельта смещени€
fs = 5.456e6 ;
freq = 4.092e6 ;
N = 5456 ;
PRN = 21;

%otstup = 70000 - 10*N - 3645;
otstup = 2000;

y_base = load_primo_file('101112_0928GMT_primo_fs5456_fif4092.dat',N*200);
y_base = double (y_base);

y = y_base(otstup : end) ;

cacode2= CACode(PRN);

CAcode1 = cacode2.Bits;
CAcode16 = zeros(1, 5456); 

for i=1:5456
    CAcode16(i) = CAcode1(ceil(1023000/fs*i));  
end

%%%%%%%%%
% DMA part
CA_lo = repmat(CAcode16, 1, 2) ;
sig_new = zeros(N, 1);

for jj=0:2
    sig_new = sig_new + y(N * jj + 1 : N + N * jj) .* ...
        y(delta1 + N * jj + 1 : N + delta1 + N * jj) ;
end;

new_CAcode16 = CA_lo(1:N) .* CA_lo(1 + delta1 : N + delta1) ;

% скоррелировали  CA код спутника со сгенерированным кодом
q = ifft(fft(new_CAcode16(1:N)) .* conj(fft(sig_new(1:N).'))) ;

acx = q.*conj(q);
[value_x, index_x] = max(acx);

fprintf('PRN: %02d\tCA phase: %d\tE/sigma: %.2f dB\n', ...
    PRN, index_x, 10*log10(value_x / std(acx)));
%plot(acx); return ;

%%%%%%%%%
% AR part
%x = y(index_x : N + index_x - 1) .* CAcode16.';
x = y(1:N) .* CA_lo(index_x : N + index_x - 1).';

X = fft(x(1:N), N*4);
X2 = X.*conj(X);
X8 = X2.^8./(10^40);
r = ifft(X8);
%plot(X8);

R = [r(1) r(2);r(2) r(1)];
a = R\[r(2);r(3)];
Z = roots([1;-a]);

freq_z = fs - fs * angle(Z(1)) / (2*pi);

fprintf('freq after AR: %.2f\n', freq_z);
%return;

%%%%%%%%%
% DLL/PLL part
settings = initSettings();
ss = FileSource(settings.fileName, 'int8', 'r');

tracker = Tracker(PRN, ss);
tracker.Init(otstup + (N - index_x), freq_z);
                
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

    if time == settings.processTime
        break
    else
        time = time + 1;
    end
end

subplot(2,1,2), plot(I), xlabel('врем€, мс'), ylabel('Ёнерги€'), phd_figure_style(gcf) ;
subplot(2,1,1), plot(CarrierError, 'k'), xlabel('врем€, мс'), ylabel('ќшибка'), phd_figure_style(gcf) ;
    
% remove model path
rmpath(modelPath) ;