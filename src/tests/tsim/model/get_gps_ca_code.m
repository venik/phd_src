% /*  PRN - sattelite number
%     fd - sampling frequency [Hz]
%     nSamples - number of code samples
% */
function code = get_gps_ca_code(PRN,fd,nSamples)

% get period of PRN sequence
codeSeq = get_ca_code( 1023, PRN) ;

codeFrequency = 1023000 ; % Hz

timePoints = 1000*(0:nSamples-1)/fd ; %[miliseconds]
timePoints = timePoints-floor(timePoints) ; % Modulo 1 ms
code = codeSeq(floor((timePoints/1000)*codeFrequency)+1) ;
