clc, clear all ;

%addpath('../../../gnss/');
addpath('../../tsim/model/');

N = 1023*15 ;
times = 100 ;

ifsmp.sats = [1] ;
ifsmp.vars = [1] ;
ifsmp.fs = [4.092e6] ;
ifsmp.fd = [16.368e6] ;
ifsmp.delays = [200] ;

SNR_db = [10:5:50] ;

real_delta = zeros(length(SNR_db), 1) ; 

T = 10^-3 ;

%%%%%%%%%%%%%%%%%%
% without ACF
SNR = 10.^(SNR_db ./ 10) ;
marple_eq = 1.03 ./ (2*T*(3*SNR_db)) ;

for k = 1:length(SNR_db)
    fprintf('SNR: %2d\n', SNR_db(k)) ;
    for kk = 1:times
        ifsmp.snr_db = [SNR_db(k)] ;
        [x, y, sats, delays, signoise] = get_if_signal(ifsmp) ;
        [omega0, ca_shift, E, Hjw] = lpcs(y, get_ca_code16(N, ifsmp.sats), 0) ;
        %fprintf('freq:%8.2f\t CA_phase:%d\n', omega0*ifsmp.fd/2/pi, ca_shift ) ;

        real_delta(k) = real_delta(k) + (ifsmp.fs - omega0*ifsmp.fd/2/pi) ^2 ;
    end % for kk
    
    real_delta = sqrt(real_delta ./ times) ;
    
end % for k

figure(1) ,
    plot(SNR_db, marple_eq, SNR_db, real_delta) ,
    xlabel('ОСШ, дБ') ,
    ylabel('F, Гц') ,
    legend('ф. Марпла', 'Алгоритм'),
    phd_figure_style(gcf) ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% END
rmpath('../../tsim/model/');