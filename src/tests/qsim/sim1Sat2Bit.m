clc, clear all ;

init_rand( 1 ) ;

[x,y, sats, delays, signoise] = if_signal_model() ;

[qy, scale_y] = quantize_nbits( y, 3 ) ;
qy = qy / scale_y ; % normalization
code = get_ca_code16(1023,sats(1)) ;

% compute exact noise variance 
% taking into account quantization noise
%noiseVar = (qy-x)'*(qy-x)/length(x) ;
%fprintf('Quantized noise variance: %8.4f\n', noiseVar ) ;
%fprintf('final SNR: %8.2fdB\n', 10*log10(var(x*scale_y)/noiseVar) ) ;

noiseVar = (y-x)'*(y-x)/length(x) ;
fprintf('Noise variance: %8.4f\n', noiseVar ) ;
fprintf('SNR: %8.2fdB\n', 10*log10(var(x)/noiseVar) ) ;

[~,~,~,rxx0] = lpcs( x, code(1:16368), 0 ) ;
[freq,E,Hjw_max,rxx_noise] = lpcs( y, code(1:16368), signoise ) ;

% get frequency
[p1,ca_shift] = max(E) ;
f = freq(ca_shift) ;
fprintf('ca_shift:%d\n', 16368-ca_shift+1 ) ;
fprintf('freq:%8.2f\n', f*16368/2/pi ) ;

%plot(real(poles.*conj(poles)))

figure(1)
hold off ;
plot(rxx0,'b-^');
hold on ;
plot(rxx_noise,'r-+') ;
title('rxx(\tau)','FontSize',12) ;
xlabel('\tau','FontSize',12) ;
legend('Ideal Rxx(\tau)','Estimated Rxx(\tau)') ;
grid on ;

figure(2)
hold off ;
plot(E); set(gca,'FontSize',14) ;
title('Frequency response at poles','FontSize',12) ;
xlabel('Code offset','FontSize',12) ;
grid on ;
