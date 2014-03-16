clc; clear all;

delta1= 10; %дельта смещени€
fs =5456e3 ;
freq = 4.092e6 ;
N = 5456 ;
secs=5;
mi_sec = 0;
PRN= 30;

otstup = 70000;

y = load_primo_file('101112_0928GMT_primo_fs5456_fif4092.dat',5456*200);  %обработали прин€тый сигнал
y = double (y);   

cacode2= CACode(PRN);

CAcode1 = cacode2.Bits;  %генерируем CA код
CAcode16 = zeros(1, 5456);  %объ€вили сигнал —инус* на CA код 

for i=1:5456
    CAcode16(i) = CAcode1(ceil(1023000/fs*i));  
end

%%%%%%%%%
% DMA part

CA_lo = repmat(CAcode16, 1, secs) ;

summ1 = y(otstup+(N*mi_sec):N+otstup+(N*mi_sec)-1) .* y(otstup+ delta1+(N*mi_sec):N+delta1+otstup+(N*mi_sec)-1) ;
summ2 = y(otstup+(N*(mi_sec+1)):N+(N*(mi_sec+1))+otstup-1) .* y(otstup+ delta1+(N*(mi_sec+1)):N+delta1+otstup+(N*(mi_sec+1))-1);
summ3 = y(otstup+(N*(mi_sec+2)):N+(N*(mi_sec+2))+otstup-1) .*  y(otstup+ delta1+(N*(mi_sec+2)):N+delta1+otstup+(N*(mi_sec+2))-1);
summ4 = y(otstup+(N*(mi_sec+3)):N+(N*(mi_sec+3))+otstup-1) .*  y(otstup+ delta1+(N*(mi_sec+3)):N+delta1+otstup+(N*(mi_sec+3))-1);
summ5 = y(otstup+(N*(mi_sec+4)):N+(N*(mi_sec+4))+otstup-1) .*  y(otstup+ delta1+(N*(mi_sec+4)):N+delta1+otstup+(N*(mi_sec+4))-1);
summ6 = y(otstup+(N*(mi_sec+5)):N+(N*(mi_sec+5))+otstup-1) .*  y(otstup+ delta1+(N*(mi_sec+5)):N+delta1+otstup+(N*(mi_sec+5))-1);
summ7 = y(otstup+(N*(mi_sec+6)):N+(N*(mi_sec+6))+otstup-1) .*  y(otstup+ delta1+(N*(mi_sec+6)):N+delta1+otstup+(N*(mi_sec+6))-1);
summ8 = y(otstup+(N*(mi_sec+7)):N+(N*(mi_sec+7))+otstup-1) .*  y(otstup+ delta1+(N*(mi_sec+7)):N+delta1+otstup+(N*(mi_sec+7))-1);
summ9 = y(otstup+(N*(mi_sec+8)):N+(N*(mi_sec+8))+otstup-1) .*  y(otstup+ delta1+(N*(mi_sec+8)):N+delta1+otstup+(N*(mi_sec+8))-1);

sig_new = summ1+summ2+summ3+summ4+summ5+summ6+summ7+summ8+summ9;

new_CAcode16 = CA_lo(1:N) .* CA_lo(1 + delta1:N+delta1) ;

% скоррелировали  CA код спутника со сгенерированным кодом
q = ifft(fft(new_CAcode16(1:N)) .* conj(fft(sig_new(1:N).')) ) ;

acx = q.*conj(q);
[value_x, index_x] = max(acx);

fprintf('CA phase: %d', index_x);

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
tracker.Init(otstup+(N*mi_sec)-(index_x-1), ...
					freq_z*1000);
                
proc_time=100;
                
I = zeros(proc_time, 1);
Q = zeros(proc_time, 1);
CarrierFrequency = 0;
CodeError = zeros(proc_time, 1);
CarrierError = zeros(proc_time, 1);
time =1;

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

plot(I);