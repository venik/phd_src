addpath('../../gnss/');

PRN = 19 ;
PRN_fake = 2 ;
tau = 10000;

ca_base = ca_get(PRN, 0) ;
ca_fake = ca_get(PRN_fake, 0) ;

ca_local = [ca_base] ;
%x_local = cos(2*pi*4092000/16368000*(0:length(ca_local)-1)).' ;
%sig_local = ca_local .* x_local;

ca_tmp = [ca_base; ca_base] ;
%x_tmp = cos(2*pi*(4092000+10)/16368000*(0:length(ca_tmp)-1)).' ;
%sig_tmp = ca_tmp .* x_tmp ;

%sig_tau = sig_tmp(tau:length(sig_local) + tau - 1);
ca_tau = ca_tmp(tau:length(ca_local) + tau - 1);
% test parca_new = ca_local .* ca_tau;

ca_new_test = zeros(3, 16368*2-1);

for k= -1:1
	k
	ca_new_tmp = ca_local .* ca_tmp(tau + 16*k:length(ca_local) + tau + 16*k -1);
	ca_new_test(k+2,:) = xcorr(ca_new, ca_new_tmp);
end

figure(1),
	subplot(3,1,1), plot(ca_new_test(1,:)), title('-1'),
	subplot(3,1,2), plot(ca_new_test(2,:)), title('0'),
	subplot(3,1,3), plot(ca_new_test(3,:)), title('1');
	
%figure(2), plot(xcorr(ca_tmp, [ca_new; ca_new]));
%sig_new = sig_local .* conj(sig_tau);
%figure(1);
%subplot(3,1,1), plot(xcorr(ca_local)), title('C/A', 'Fontsize', 14);
%subplot(3,1,2), plot(xcorr(ca_tau)), title('C/A + tau', 'Fontsize', 14);
%subplot(3,1,3), plot(xcorr(ca_new)), title('New C/A', 'Fontsize', 14);

%figure(1);
%subplot(1,1,1),plot(1:200, sig_local(1:200	), 'r', 1:200, sig_new(1:200), 'g');

%figure(2);
%tt = sig_new(1:16368);
%[x,y] = max(xcorr(sig_new, sig_local))
