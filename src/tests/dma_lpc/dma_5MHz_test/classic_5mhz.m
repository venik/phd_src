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
PRN = 1:32;

%otstup = 70000 - 3645;
otstup = 40645;

y_base = load_primo_file('101112_0928GMT_primo_fs5456_fif4092.dat',N*200);
y_base = double(y_base);

y = y_base(otstup : otstup + N - 1) ;

freq = 4.092e6-5e3 : 1e3 : 4.092e6+5e3;

fs = 5.456e6 ;
N = 5456 ;

acx = zeros(length(PRN), 1) ;
ca_phase = zeros(length(PRN), 1) ;
freq_z = zeros(length(PRN), 1) ;

res = zeros(N, 1) ;

for jj=1:length(PRN)
    Y = fft(y);
    cacode2= CACode(PRN(jj));
    CAcode1 = cacode2.Bits;  %генерируем CA код
    CAcode16 = zeros(1, N);  %объявили сигнал Синус* на CA код 

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

        if (value_x > acx(jj))
            res = acx_res ;
            acx(jj) = value_x ;
            ca_phase(jj) = index_x ;
            freq_z(jj) = freq(p) ;
        end;

    end; % p
    
    fprintf('PRN: %02d\tCA phase: %d\tfreq: %.2f\tE/sigma: %.2f dB\n', ...
        PRN(jj), ca_phase(jj), freq_z(jj), 10*log10(acx(jj) / std(res)));

end; % jj

barh(acx), phd_figure_style(gcf) ;

rmpath(modelPath) ;