clc, clear all ;

infs = 0:0.1:1 ;
freq_infs = zeros(numel(infs), 1) ;

for k=1:numel(infs)
    [y,sats, delays] = if_signal_model_infs(infs(k)) ;
    code = get_ca_code16(1023+20,sats(1)) ;
    [freq,E,Hjw] = lpcs(y,code(1:16368),0) ;
    [p1,ca_shift] = max(E) ;
    f = freq(ca_shift) ;
    fprintf('infs: %d freq:%8.2f\n', infs(k), f*16368/2/pi ) ;
    freq_infs(k) = abs(3800 - f*16368/2/pi) ;
end

plot(infs, freq_infs),
    grid on,
    xlabel('Амплитуда помехи интерференционной'),
    ylabel('Ошибка по частоте')

%code = code(1+delays(1):16368+delays(1)) ;
%x = y.*code ;
%x = y ;
%[X,omega] = pwelch(x,1024) ;
%[Y] = pwelch(y,1024) ;

%hold off, semilogy(omega,X.*conj(X), 'LineWidth',2);
%hold on,semilogy(omega(1:numel(Hjw)),Hjw.*conj(Hjw),'r-','LineWidth',2), grid on
%semilogy(omega,Y.*conj(Y),'k-','LineWidth',2)
%xlabel('Частота, рад/с','FontSize',14) ;
%legend('Спектр сигнала', 'АР оценка спектра сигнала', 'Спектр сигнала до снятия ПСП'),
%xlim([omega(1), omega(end)])
