clc, clear all ;
x8 = load_primo_file('101112_0928GMT_primo_fs5456_fif4092.dat', 5456) ;
%x = resample( double(x8), 2,1 ) ;
x = double(x8) ;

code = get_ca_code_primo(1023, 13) ;

max_r = 0 ;
best_r = [] ;
best_freq = [] ;
X = fft(x) ;
for freq=500:100:5456
    lx = exp(1j*2*pi*freq/5456*(0:5455)).' ;
    LX = fft(lx.*code) ;
    r = ifft(X.*conj(LX)) ;
    r2 = r.*conj(r) ;
    if max(r2)>max_r
        best_r = r2 ;
        best_freq = freq ;
        max_r = max(r2) ;
    end
end
plot(best_r) ;
fprintf('Frequency: %f\n', 5456-best_freq) ;
return ;

%[freq,E,Hjw_max] = lpcs_primo( x, code(1:10912), 0.6 ) ;
[freq,E,Hjw_max] = lpcs_primo( x, code(1:5456), 0.1 ) ;

[p1,ca_shift] = max(E) ;
f = freq(ca_shift) ;
%fprintf('ca_shift:%d\n', 10912-ca_shift+1 ) ;
fprintf('ca_shift:%d\n', 5456-ca_shift+1 ) ;
fprintf('freq:%8.2f\n', f*5456/2/pi ) ;

hold off ;
plot(E); set(gca,'FontSize',14) ;
title('Frequency response at pole frequency point','FontSize',12) ;
xlabel('Code offset','FontSize',12) ;
grid on ;


