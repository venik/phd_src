clear all, clc, clf;

path_gnss = '../../gnss/' ;
path_model = '../tsim/model/' ;
addpath(path_gnss);
addpath(path_model);

data_model = 0 ;
ms = 1 ;
N = 16368 ;
rays = 3 ;

ifsmp.sats = [3, 2, 4] ;
ifsmp.delays = [5687, 300, 100] ;
ifsmp.fd = 16.368e6 ;

% get the data
if data_model == 1
    ifsmp.vars = [1, 1, 1] ;
    ifsmp.fs = [4.0923e6, 4.095e6, 4.090e6] ;
    ifsmp.fd = 16.368e6 ;
    ifsmp.snr_db = -20 ;
    
    [x, sig, sats, delays, signoise] = get_if_signal(ifsmp, ms, rays) ;
    fprintf('Model\n');
else    
    %sig_from_file = readdump_txt('./data/flush.txt', ms*N);	% create data vector
    %save('./data/flush.txt.mat', 'sig_from_file') ;
    %load('./data/flush.txt.mat', 'sig_from_file') ;
    
    load('./data/x.mat') ; sig = x ;
    t_offs = 10000 ; % /* time offset */
    %sig = sig_from_file(t_offs:t_offs + ms*N - 1) ;
    %sig = sig_from_file ;
	fprintf('Real\n');
end ; % if model

prn = 3 ;
ca16 = get_ca_code16(N/16, prn) ;
ca16 = repmat(ca16, ms, 1);

y = sig.*circshift(ca16(:), 5687-1 ) ;
Y = fftshift(fft(y)) ;
Y2 = Y.*conj(Y) ;
plot((-16368*ms/2:16368*ms/2-1)*1e3,Y2) ;
    grid on ;
    phd_figure_style(gcf) ;
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make me quadruple
acf_iteration = 10 ;
X = fft(real(y)) ;
XX(1, :) = X.*conj(X) ;
rxx = ifft(XX .^ acf_iteration) ;
rxx = rxx ./ max(rxx) ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AR model
b = ar_model([rxx(1); rxx(2); rxx(3)]) ;
[poles, omega0, Hjw0] = get_ar_pole(b) ;
freq = omega0*ifsmp.fd/2/pi 

RXX = fftshift(fft(rxx)) ;
RXX2 = RXX.*conj(RXX) ;
plot((-16368*ms/2:16368*ms/2-1)*1e3,RXX2,'y-','LineWidth',2) ;
set(gca,'Color',[0 0 0]) ;
set(gca,'XColor',[0.7 0 0]) ;
set(gca,'YColor',[0.7 0 0]) ;
grid on ;

%pwelch(rxx, N), phd_figure_style(gcf) ;
%semilogy(abs(fft(rxx(1:N))))
%    title(sprintf('ms: %d, ACF iteration: %d estimated freq: %.0f \n', ...
%        length(sig_after_dma) / N, acf_iteration, freq)) ;
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% END
rmpath(path_gnss);
rmpath(path_model);