clc; clear all;

delta1= 10; %дельта смещени€
fs =5456e3 ;
freq = 4.092e6 ;
N = 5456 ;
mi_sec = 0;
PRN= 30;

otstup = 70000;

y = load_primo_file('101112_0928GMT_primo_fs5456_fif4092.dat',5456*200);
y = double (y);   

cacode2= CACode(PRN);

CAcode1 = cacode2.Bits;  %генерируем CA код
CAcode16 = zeros(1, 5456);  %объ€вили сигнал —инус* на CA код 

for i=1:5456
    CAcode16(i) = CAcode1(ceil(1023000/fs*i));  
end

%%%%%%%%%
% DMA part
CA_lo = repmat(CAcode16, 1, 2) ;
sig_new = zeros(N, 1);

for jj=0:8
    sig_new = sig_new + y(otstup + (N * jj) : N + otstup + (N * jj) - 1) .* y(otstup+ delta1+(N * jj) : N + delta1 + otstup + (N * jj)-1) ;
end;

new_CAcode16 = CA_lo(1:N) .* CA_lo(1 + delta1 : N + delta1) ;

% скоррелировали  CA код спутника со сгенерированным кодом
q = ifft(fft(new_CAcode16(1:N)) .* conj(fft(sig_new(1:N).')) ) ;

acx = q.*conj(q);
[value_x, index_x] = max(acx);

fprintf('PRN: %02d\tCA phase: %d\n', PRN, index_x);

%%%%%%%%%
% PLL part
x  = y(otstup+(N*mi_sec)-(index_x-1):N+otstup+(N*mi_sec)-(index_x-1)-1).*CAcode16.';

x_new = zeros(1,N*5);

x_new(1:N)=x(1:N);

X = fft(x_new);
X2 = X.*conj(X);

X8 = X2.^8./(10^40);

%plot(X8);

r = ifft(X8);
%plot(r);

R = [r(1) r(2);r(2) r(1)];
a = R\[r(2);r(3)];

D = a(1)^2 + 4*a(2);
Z = (a(1) + sqrt(D))/2;
freq_z = 5456 - (angle(Z)/(2*pi)*5456); 

root1 = roots([1;-a]);
settings = initSettings();
ss = FileSource(settings.fileName, 'int8', 'r');

tracker = Tracker(PRN, ss);
tracker.Init(otstup+(N*mi_sec)-(index_x-1), freq_z*1000);
                
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

%plot(I);

plot(CarrierError(1:200)),
    xlabel('мс'), ylabel('ошибка');