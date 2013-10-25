function x = load_primo_file(fname, nSamples)
x = [] ;
f = fopen(fname,'rb') ;
if f~=-1
    x = fread(f, nSamples, '*int8') ;
    fclose(f) ;
end