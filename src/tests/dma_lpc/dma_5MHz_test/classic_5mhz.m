clc; clear all;

%fs = 5.456e6 ;
%freq = 4.092e6 ;
N = 5456 ;
PRN = 30;

otstup = 70000 - 3645;

y_base = load_primo_file('101112_0928GMT_primo_fs5456_fif4092.dat',N*200);
y_base = double(y_base);

y = y_base(otstup : otstup + N - 1) ;

freq = 4.092e6-5e3 : 1e1 : 4.092e6+5e3;
%freq = 4.0898e6;

%freq = 4.0935e6;
fs = 5.456e6 ;
%dop_freq = 0 ;
N = 5456 ;

peaks = zeros(length(freq), N) ;

Y = fft(y);
cacode2= CACode(PRN);
CAcode1 = cacode2.Bits;  %генерируем CA код
CAcode16 = zeros(1, N);  %объявили сигнал Синус* на CA код 

for i=1:5456
    CAcode16(i) = CAcode1(ceil(1023000/fs*i));  
end

acx = 0 ;
ca_phase = 0 ;
res = zeros(N, 1) ;
freq_z = 0 ;

for p=1:length(freq)   
    cos_opor = exp(-1i*2*pi*freq(p)/fs .* [0:N-1]);
    
    lo_sig = CAcode16 .* cos_opor;

    LO_SIG = fft(lo_sig);

    q = ifft(Y .* conj(LO_SIG).') ;

    acx_res = q .* conj(q) ;
    [value_x, index_x] = max(acx_res) ;
    
    if (value_x > acx)
        res = acx_res ;
        acx = value_x ;
        ca_phase = index_x ;
        freq_z = freq(p) ;
    end;
    
end

fprintf('PRN: %02d\tCA phase: %d\n', PRN, ca_phase);
fprintf('freq after AR: %.2f\n', freq_z);

plot(res)

