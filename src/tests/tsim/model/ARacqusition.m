function acqResults = ARacqusition(signal,settings)
fd = settings.samplingFreq ;
numSamples = round(fd/1000) ; % get fourier size, it corresponds to 1ms

acqResults.carrFreq     = zeros(1, 32) ;
% C/A code phases of detected signals
acqResults.codePhase    = zeros(1, 32) ;
% Correlation peak ratios of the detected signals
acqResults.peakMetric   = zeros(1, 32) ;

x = signal(1:numSamples) ;
x = x(:) ; % get column vector
for PRN=1:32

    ca = get_gps_ca_code(PRN,fd,numSamples) ;
    ca = ca(:) ;
    % get input signal variance
    rx0 = sum(signal.*conj(signal))/length(signal) ;
    
    % get rx1 for all ca phases
    xx = x.*conj([x(2:end);x(1)]) ;
    cc = ca.*[ca(2:end);ca(1)] ;
    XX = fft(xx) ;
    CC = fft(cc) ;
    rx1 = ifft(XX.*conj(CC))/(length(CC)) ;
    
    % get rx2 for all ca phases
    xx = x.*conj([x(3:end);x(1:2)]) ;
    cc = ca.*[ca(3:end);ca(1:2)] ;
    XX = fft(xx) ;
    CC = fft(cc) ;
    rx2 = ifft(XX.*conj(CC))/(length(CC)) ;

    resonanceFreq = zeros(size(rx1)) ;
    resonanceFreqResponses = zeros(size(rx1)) ;
    for caPhase=1:numSamples
        b = ar_model([rx0; rx1(caPhase); rx2(caPhase)]) ;
        [~, omega0, Hjw0] = get_ar_pole(b) ;
        %fprintf('Freq: %6.2f, Hjw0: %5.2fdB\n',omega0/2/pi*ifsmp.fd, 10*log10(Hjw0*conj(Hjw0))) ;
        resonanceFreq(caPhase) = omega0/2/pi*fd ;
        resonanceFreqResponses(caPhase) = Hjw0.*conj(Hjw0) ;
    end
    
    [peakSize, codePhase] = max(resonanceFreqResponses) ;
    secondPeakSize = max([resonanceFreqResponses(1:codePhase-1);resonanceFreqResponses(codePhase+1:end)]) ;
    
    acqResults.peakMetric(PRN) = peakSize/secondPeakSize ;
%    acqResults.peakMetric(PRN) = peakSize ;
    
    if acqResults.peakMetric(PRN)>1.01
        acqResults.carrFreq(PRN) = resonanceFreq(codePhase) ;
        acqResults.codePhase(PRN) = codePhase ;
        if strcmpi(settings.plotOptions,'on')
%            freqPoints = (-fd/2:fd/100:fd/2) ;
            freqPoints = (0:fd/500:fd/2) ;
            % get signal spectr
            pwelchSignal = signal(1:numSamples*3) ; pwelchSignal = pwelchSignal(:) ;
            pwelchCode = get_gps_ca_code(PRN,fd,numSamples*4) ; pwelchCode = pwelchCode(:) ;
            pwelchSignal = pwelchSignal.*pwelchCode(1+(numSamples-codePhase):numSamples*3+(numSamples-codePhase)) ;
            %pwelchFFT = length(freqPoints) ;
            [pwelchSpectr,pwelchFreq] = pwelch(pwelchSignal,1024,800,1024,fd) ;
            hold off ;
            plot(pwelchFreq/1e3, 10*log10(pwelchSpectr)+70,'LineWidth',2) ;
            b = ar_model([rx0; rx1(codePhase); rx2(codePhase)]) ;
            %[~, ~, Hjw0] = get_ar_pole(b) ;
            omega = freqPoints*2*pi/fd ;
            Hjw = 1.0./( -b(2)*exp(-2j*omega) - b(1)*exp(-1j*omega) + 1.0 ) ;
            hold on ;
            plot(freqPoints/1e3,10*log10(Hjw.*conj(Hjw)),'r-','LineWidth',2) ;
            grid on ;
            xlabel('„астота, к√ц', 'FontSize',12) ;
        end
    end
    
end