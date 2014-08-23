clc; clear all;
curPath = pwd() ;
cd('..\\..\\tsim\\model') ;
modelPath = pwd() ;
cd( curPath ) ;
addpath(modelPath) ;

delta1 = 10; %дельта смещения
fs = 5.456e6 ;
%freq = 4.092e6 ;
N = 5456 ;
PRN = 31 ;

fourier_length = 8 * N ;   

y_base = load_primo_file('101112_0928GMT_primo_fs5456_fif4092.dat', N * 200);
y_base = double (y_base);

prob = zeros(4, 1) ;
mean_time = zeros(4, 1) ;
times = zeros(4, 1) ;

matlabpool open 4 ;

parfor k = 1:4
    
    otstup = 0;
    sig = y_base ;

    while otstup < N * 150
    
    otstup = otstup + 50 ;
    res = 0 ;
    detected = 0;
    
    y = sig(otstup : end) ;

    cacode2= CACode(PRN);

    CAcode1 = cacode2.Bits;
    CAcode16 = zeros(1, 5456); 

    for i=1:5456
        CAcode16(i) = CAcode1(ceil(1023000/fs*i));  
    end

    %%%%%%%%%
    % DMA part
    CA_lo = repmat(CAcode16, 1, 2) ;
    sig_new = zeros(N, 1);

    for jj=0:2
        sig_new = sig_new + y(N * jj + 1 : N + N * jj) .* ...
            y(delta1 + N * jj + 1 : N + delta1 + N * jj) ;
    end;

    new_CAcode16 = CA_lo(1:N) .* CA_lo(1 + delta1 : N + delta1) ;

    % скоррелировали  CA код спутника со сгенерированным кодом
    q = ifft(fft(new_CAcode16(1:N)) .* conj(fft(sig_new(1:N).'))) ;

    acx = q .* conj(q);
    [value_x, index_x] = max(acx);

    fprintf('PRN: %02d\tCA phase: %d\tE/sigma: %.2f dB\n', ...
        PRN, index_x, 10*log10(value_x / std(acx)));
    %plot(acx); return ;

    %%%%%%%%%
    % AR part
    %x = y(index_x : N + index_x - 1) .* CAcode16.';
    x = y(1:N) .* CA_lo(index_x : N + index_x - 1).';

    if k == 1
        x = x(1:N) ;
        else if k == 2
            x = x(1:N) .* hann(N, 'periodic') ;
            else if k == 3
                x = x(1:N) .* hamming(length(N)) ;
                else if k ==4
                        x = x(1:N) .* blackman(length(N)) ;
                    else
                        assert();
                    end ; % 4
                end ; %3
            end ; %2
        end ; % 1    
            
    X = fft(x(1:N), fourier_length);
    X2 = X.*conj(X);
    X8 = X2 .^ 8 ./ (10^40);
    r = ifft(X8);
    %plot(X8);

    R = [r(1) r(2);r(2) r(1)];
    a = R\[r(2);r(3)];
    Z = roots([1;-a]);

    freq_z = fs - fs * angle(Z(1)) / (2*pi);

    %fprintf('freq after AR: %.2f\n', freq_z);
    %return;

    times(k) = times(k) + 1 ;
    
    if abs(4.092e6 - freq_z) > 5e3
        fprintf('%d: miss with freq %.2f\n', k, freq_z) ;
    else
        fprintf('%d: freq after AR: %.2f\n', k, freq_z);
        detected = 1;
    end
    
    %%%%%%%%%
    % DLL/PLL part
    if detected == 1
        settings = initSettings();
        ss = FileSource(settings.fileName, 'int8', 'r');

        tracker = Tracker(PRN, ss);
        tracker.Init(otstup + (N - index_x), freq_z);

        proc_time = settings.processTime;

        I = zeros(proc_time, 1);
        Q = zeros(proc_time, 1);
        CarrierFrequency = 0;
        CodeError = zeros(proc_time, 1);
        CarrierError = zeros(proc_time, 1);
        time = 1;

        while true
            tracker.Execute();

            if strcmp(tracker.State, 'nodata')
                break
            end

            I(time) = tracker.I;
            Q(time) = tracker.Q;
            CodeError(time) = tracker.codeErr;
            CarrierError(time) = tracker.carrErr;

            if time == settings.processTime
                break
            else
                time = time + 1;
            end

            num_var = 10 ;
            if time > num_var
                ss = sum(CarrierError(time: -1: time-num_var).^2) / num_var ;
                %fprintf('\t sum %.2f\n', ss) ;

                if ss < 0.01
                    fprintf('lock, time: %d\n', time) ;
                    res = 1 ;
                    break ;
                end ; % if ss
            end ; % if time
            
        end ; % while true        
    end ; % if detected
    
    if res == 1
        prob(k) = prob(k) + 1 ;
        mean_time(k) = mean_time(k) + time ;
    end ;
    
    end ; % outside
end ; % for k

matlabpool close ;

fprintf('PRN:%d\n', PRN);
fprintf('Fourier length: %d times %d\n', fourier_length / N, times(1)) ;

mean_time = mean_time ./ prob ;
fprintf('Mean time of lock: Rect:%.2f Hann:%.2f Hamming:%.2f Blackman:%.2f\n', mean_time(1), mean_time(2), mean_time(3), mean_time(4)) ;

prb = prob ./ times ;
fprintf('Probability: Rect:%.2f Hann:%.2f Hamming:%.2f Blackman:%.2f\n', prb(1), prb(2), prb(3), prb(4)) ;
fprintf('\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n') ;

% remove model path
rmpath(modelPath) ;