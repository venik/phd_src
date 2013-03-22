function [code_shift, estimatedFreq, p1, p1_noise] = simModel( Seed, snr_db, Opt )

init_rand( Seed ) ;

[x,y, sats, delays, signoise] = if_signal_model(snr_db) ;

%[qy, scale_y] = quantize_nbits( y, 3 ) ;
%qy = qy / scale_y ; % normalization
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

% noise
[~,E] = lpcs( y-x, code(1:16368), 0 ) ;
% get frequency
[p1_noise] = max(E) ;
if ~isempty(strfind(Opt,'ENoise'))
    figure(2) ;
    hold off ;
    plot(E); set(gca,'FontSize',14) ;
    title('Frequency response at poles','FontSize',12) ;
    xlabel('Code offset','FontSize',12) ;
    grid on ;
drawnow ;
end

% signal + noise
[freq,E,Hjw_max,rxx_noise] = lpcs( y, code(1:16368), 0.97*signoise ) ;
% get frequency
[p1,ca_shift] = max(E) ;
f = freq(ca_shift) ;
estimatedFreq = f*16368/2/pi ;
code_shift = 16368-ca_shift+1 ;
fprintf('code shift:%d\n', code_shift ) ;
fprintf('freq:%8.2f\n', estimatedFreq ) ;

if ~isempty(strfind(Opt,'ESignal'))
    figure(2) ;
    hold off ;
    plot(E); set(gca,'FontSize',14) ;
    title('Frequency response at poles','FontSize',12) ;
    xlabel('Code offset','FontSize',12) ;
    grid on ;
drawnow ;
end


%plot(real(poles.*conj(poles)))

if ~isempty(strfind(Opt,'rxx'))
    figure(1)
    hold off ;
    plot(rxx0,'b-^');
    hold on ;
    plot(rxx_noise,'r-+') ;
    title('rxx(\tau)','FontSize',12) ;
    xlabel('\tau','FontSize',12) ;
    legend('Ideal Rxx(\tau)','Estimated Rxx(\tau)') ;
    grid on ;
end

if ~isempty(strfind(Opt,'SigSpectr'))
    figure(3) ;
    
    ca_shift = -100 ;
    yc = y.*circshift(code, ca_shift) ;
    pwelch( yc, 1024,900,1024,16368000 ) ;
    
    %YC = fft(yc) ;
    %semilogy ( log10(real(YC(1:16368/2).*conj(YC(1:16368/2)))) ) ;
    
end

drawnow ;
