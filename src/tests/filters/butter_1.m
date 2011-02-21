% Nyquist frequency, [Hz]
% The Nyquist frequency is half your sampling frequency.
Fnyq = 1500/2;

% The cut-off frequency of your Low pass filter. Note that this filter must be greater than 0 and less than Fnyq
%Fc=1/4; %[Hz]
Fc=10; %[Hz]

% Create a first-order Butterworth low pass
[b,a]=butter(2, Fc/Fnyq);

% clear unused variables
clear("Fnyq", "Fc");

% Create a 5 seconds signal with 3 components:
% a 1Hz omponent, a 200Hz sinusoidal component and some gaussian noise.
t=0:1/1500:5;
input=sin(2*pi*t) + sin(2*pi*200*t) + rand(size(t));

% Apply the filter to the input signal and plot input and output.
output=filter(b,a,input);
plot(t, [input; output])

%plot([abs(fft(input)); abs(fft(output))])
%find(abs(fft(input)) > 3000)
%find(abs(fft(output)) > 3000)
