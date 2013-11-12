clc, clear all ;

%addpath('../../../gnss/');
addpath('../../tsim/model/');

N = 1023*15 ;
times = 1000 ;
SNR_dB = 10:1:40 ;

interference = 0 ; 


if interference == 0 
    ifsmp.snr_db = 0 ;
    ifsmp.sats = [1] ;
    ifsmp.vars = [1] ;
    ifsmp.fs = [4.092e6] ;
    ifsmp.fd = [16.368e6] ;
    ifsmp.delays = [200] ;
else
    ifsmp.snr_db = 0 ;
    ifsmp.sats = [1, 2, 3] ;
    ifsmp.vars = [1, 1, 1] ;
    ifsmp.fs = [4.092e6, 4.095e6, 4.090e6] ;
    ifsmp.fd = 16.368e6 ;
    ifsmp.delays = [200, 300, 100] ;
end ;

freq = zeros(length(SNR_dB), 1) ; 

pll_line = 18 ; % Hz

ifsmps = repmat(ifsmp,numel(SNR_dB),1) ;

matlabpool open 8 ;

parfor k = 1:length(SNR_dB)
    ifsmps(k).snr_db = SNR_dB(k) ;
    fprintf('SNR: %2.2f\n', SNR_dB(k)) ;
    %sim_events = zeros(times,1) ;
    for kk = 1:times
        [x, y, sats, delays, signoise] = get_if_signal(ifsmps(k)) ;
        [omega0, ca_shift, E, Hjw] = lpcs(y, get_ca_code16(N, ifsmps(k).sats), 0) ;
        %fprintf('freq:%8.2f\t CA_phase:%d\n', omega0*ifsmp.fd/2/pi, ca_shift ) ;

       if (abs(omega0*ifsmps(k).fd/2/pi - ifsmps(k).fs) <= pll_line)
            freq(k) = freq(k) + 1 ;
            %sim_events(kk) = 1 ;
        end ;
    end % for kk
    
%    freq(k) = nnz(sim_events) / times ;
    freq(k) = freq(k) / times ;
    
end % for k

figure(1) ,
    semilogy(SNR_dB, freq, '-r+') ,
    title('Probability') ,
    xlabel('SNR, dB') ;
    ylabel('P(f\in[f_0-18Hz...f_0+18Hz])') ;
    phd_figure_style(gcf) ;
    
matlabpool close ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% END
rmpath('../../tsim/model/');