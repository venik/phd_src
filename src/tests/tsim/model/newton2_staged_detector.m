function [preciseFreq, precisePower] = newton2_staged_detector(signal2ms, initialFreq, samplingFreq)

[preciseFreq, precisePower] = newton_solver2( signal2ms, initialFreq, -1, samplingFreq, 5,6, 5 ) ;
if (preciseFreq>5000)
    error('Error on stage 1') ;
end
[preciseFreq, precisePower] = newton_solver2( signal2ms, preciseFreq, precisePower, samplingFreq, 9,10, 5 ) ;
if (preciseFreq>5000)
    error('Error on stage 2, preciseFreq=%f\n',preciseFreq) ;
end
[preciseFreq, precisePower] = newton_solver2( signal2ms, preciseFreq, precisePower, samplingFreq, 15,16, 5 ) ;
if (preciseFreq>5000)
    error('Error on stage 3') ;
end
