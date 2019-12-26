#differenciate sequence
function diff(a){ out=[] for(n=1;n<sizeof(a);n++){out[n-1]=a[n]-a[n-1]} return(out) }

#Integrate sequence
function inte(a,k){ out=[] out[0]=k for(n=1;n<=sizeof(a);n++){ out[n]=out[n-1]+a[n-1]} return(out) }

function factorial(n){out=1 for(x=2;x<=n;x++){out=out*x} return(out)}

function perm(k,n){
	b=[] c=stair(0,k) out=[]
	for(x=k;x>0;x--){b[k-x]=n%x}
	for(x in b){out[x]=c[b[x]] c=seqrem(c,out[x])}
	return(out)
}

function repcheck(s){
	out=0
	for(n=1;n<sizeof(s);n++){ if(s[n]==s[n-1]){out=1 print(n)} }
	if(out==0){print("no repetition")}
	else{print("repetition")}
	return(out)
}

#returns a sequence of length n^2...
#generate a random sequence with no duplicate then repeats it n times, 
#each time rotating it one less until the next logical step is the beginning
function randrot(n,min,amp){
	out=[] a=randseq(n, min,amp)
	for(b=0;b<n;b++){ out=juxt(out,rot(a,-b)) }
	return(out)
}


#sequence map
#without map - prints values and number of occurences
#with map - applies new values [a=x, b=y, c=z]
function sm(){
	if(argv(1)!=""){
		a=argv(0) b=[] tr(b,a) m=argv(1)
		for(n in m){ for(z in a){ if(a[z]==n){ b[z]=m[n] } } }
		return(b)
	}
	else{
		s=[] a=""
		for(n in argv(0)){ if(s[argv(0)[n]]==""){s[argv(0)[n]]=1}else{s[argv(0)[n]]+=1} }
		for(n in s){a+=string(n)+":"+string(s[n])+" "}
		print("\n"+"values:occurences "+a)
	}
}

function seqmin(s){ out=s[0] for(n in s){if(s[n]<out){out=s[n]}} return(out) }
function seqmax(s){ out=s[0] for(n in s){if(s[n]>out){out=s[n]}} return(out) }

function flipseq(s){ l=seqmin(s) h=seqmax(s) out=[] for(n in s){ out[n]=(h-(s[n]-l)) } return(out) }

#array sum
function asum(a){out=0 for(n in a){ out+=a[n] } return(out)}


#takes 'modulator' numbers as parameters -> m
#returns a numerical sequence whose length is the largest value of m -> x{0...n-1}
#x=x%m0%m1... of course modulators are applied in decreasing order
function mods(){
	a=0 b='' mod=[] l=0 out=[]
	for(n=0;n<nargs();n++){ mod[n]=argv(n) } arraysort(mod)
	l=mod[sizeof(mod)-1] mod=chop(mod,sizeof(mod)-1)
	t=revseq(mod)
	for(n=0;n<l;n++){ a=n for(u in t){  a=a%t[u]  } out[n]=a }
	return(out)
}

#juxtaposes sequences
function juxt(){ out=[] c=0
	for(n=0;n<nargs();n++){ for(v in argv(n)){ out[c]=argv(n)[v] c=c+1 } } return(out) }


#shuffles sequence
function shuffseq(arr) {
	sz = sizeof(arr)
	mid = sz/2 t=[] for(n in arr){ t[n]=arr[n] }
	if((sz%2)==0){ #pair
		for(n=0;n<mid;n++){ arr[n*2]=t[n] }
		for(n=0;n<mid;n++){ arr[(n*2)+1]=t[n+mid] }}
	else{ mid+=1 #impair
		for(n=0;n<mid;n++){ arr[n*2]=t[n] }
		for(n=0;n<(mid-1);n++){ arr[(n*2)+1]=t[n+mid] }} return(arr)}


#reverses sequence
function revseq(a){t=[] arr=[] tr(arr,a) for(n in arr){t[n]=arr[n]}
	for(n in arr){ arr[sizeof(arr)-(1+n)]=t[n] } return(arr) }

#returns a sequence
function seq(){ out=[] for(n=0;n<nargs();n++){ out[n]=argv(n) } return(out) }

#transfers a source array into a target
function tr(tg,src){for(n in src){tg[n]=src[n]}}

#applies a permutation to a sequence for a certain number of iterations
function spi(seq,perm,ite){
	out=[]  tr(out,seq) s=sizeof(out)
	for(n=1;n<ite;n++){for(m=0;m<s;m++){ out[m+(s*n)]=out[(s*(n-1))+perm[m]] }}
	return(out)
}

#starting at origin, adds 1 (or argv(2)) l times
function stair(o,l){ a=1 if(argv(2)!=""){ a=argv(2) } out=[] for(n=0;n<l;n++){out[n]=o+(n*a)} return(out)}
function tri(o,l){ a=1 if(argv(2)!=""){ a=argv(2) } return(juxt(stair(o,l,a),stair(o+l*a,l,-a))) }


function seqrem(s,n){ a=[] b=0
	for(x in s){ if(s[x]==n){ s[x]="" } }
	for(x in s){ if(s[x]!=""){ a[b]=s[x] b+=1 } } return(a)
}

#simple random sequence generator
function randseq0(n,mini,amp){
	out=[] maxi=(mini+amp-1)
	for(a=0;a<n;a++){out[a]=rand(mini,maxi)}
	return(out)
}

#random sequence generator... if specify no duplicate by giving anything as argument 3,
#make sure n is greater or equal to the amplitude...
#randseq(n, minimum, amplitude,[nodup])
function randseq1(n,mini,amp){
	m=stair(mini,amp) out=[]
	if(argv(3)==""){
		a=0
		while(a<n){
			out[a]=m[rand(sizeof(m))]
			if(a!=0){if(out[a-1]!=out[a]){a+=1}}else{a+=1}
		}
	}else{
		if(n>amp){print("...amp is too little...")}else{for(a=0;a<n;a++){ out[a]=m[rand(sizeof(m))] m=seqrem(m,out[a])}}
	}
	return(out)
}

#random sequence generator with parameters managing differences
#randseqd(n, mini, amp, minabsdiff, diffrangeamp, [illegaldiff])
function randseq2(n, mini, amp, minabsdiff, diffrangeamp){
	out=[] maxi=(mini+amp-1) c=0 a=[] illegaldiff=argv(5)
	for(x=0;x<diffrangeamp*2;x++){ a[x]=minabsdiff+(x%diffrangeamp) }
	for(x=0;x<diffrangeamp;x++){a[x]=-1*a[x]}
	out[0]=rand(mini,maxi) b=1
	while(b!=n){
		out[b]=out[b-1]+a[rand(sizeof(a))]
		if((out[b]>=mini)&&(out[b]<=maxi)&&(out[b]-out[b-1])!=illegaldiff){b+=1}}
	return(out)
}

function randseq3(min, amp, s, k){
	a=[]
	for(n=0;n<sizeof(s);n++){a[n]=s[n]*rand(min,min+amp-1)}
	return(inte(a,k))
}

#tests if k is in sequence s
function kisins(k,s){ a=0 n=0 while((a==0)&&(n<sizeof(s))){ if(s[n]==k){ a=1 } n+=1 } return(a) }

#articulate sequences
function as(s,k){ out=[] for(m in k){for(n in s){out[(m*sizeof(s))+n]=(k[m]+s[n])}} return(out)}

#sequences must be of same size
function mergeseq(){
	out=[] c=0
	for(a=0;a<sizeof(argv(0));a++){ for(b=0;b<nargs();b++){ out[c]=argv(b)[a] c+=1 }}
	return(out)
}

#add k to sequence
function saddk(s,k){
	out=[]
	if(typeof(k)=="integer"){
		tr(out,s)
		for(n in out){out[n]+=k}
		return(out)
	}
	if(typeof(k)=="array"){

		for(m in k){
			for(n in s){
				out[(m*sizeof(s))+n]=(k[m]+s[n])
			}
		}
		return(out)
	}
	print("invalid parameter")
}

#multiply sequence by integer k. k may also be an array.
#if so, for each n in k, smulk(n,k[n]) is juxtaposed to the result
function smulk(s,k){
	out=[]
	if(typeof(k)=="integer"){ tr(out,s) for(n in out){out[n]=(out[n]*k) } }
	if(typeof(k)=="array"){ for(n in k){ out=juxt(out,smulk(s,k[n])) } }
	return(out)
}

#using sequence i as indexes in s
function seqi(s,i){
         out=[]
         for(n in i){out[n]=s[i[n]]}
         return(out)
}

#generates a random mathematical composition of n using a percentage.
#the greater the percentage, the greater quantity of numbers.
#for some obscure reason, it won't work for values of n greater than 502 !?!?
function randcomp(n,pc){
	a=[] a[0]=1 c=[] d=0
	for(b=1;b<n;b++){if(rand(100)<pc){a[b]=1}else{a[b]=0}}
	a[n]=1
	for(b in a){if(a[b]==1){c[d]=b d+=1} }
	f=[]
	for(e=0;e<sizeof(c)-1;e++){f[e]=c[e+1]-c[e]}
	return(f)
}

function repseq(s,n){
	out=[]
	if(typeof(s)=="integer"){ for(a=0;a<n;a++){out[a]=s} return(out)}
	if(typeof(s)=="array"){ for(a=0;a<n;a++){out=juxt(out,s)} return(out) }
	print("invalid parameter")

}