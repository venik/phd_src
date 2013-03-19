function init_rand(seed)
s = RandStream('mt19937ar','Seed', seed) ;
RandStream.setGlobalStream(s);