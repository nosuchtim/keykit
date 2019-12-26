#sequences must be of same size x. size of result is equal to x*(2^x)
function morphabseq(a,b){
	c=[] n=lcm(sizeof(a),sizeof(b)) out=[]
	for(x=0;x<pow(2,n);x++){ c=juxt(c,nnbits(x,n)) }
	for(x in c){if(c[x]){out[x]=b[x%sizeof(b)]}else{out[x]=a[x%sizeof(b)]}}
	return(out)
}

function bindev(){
	out=[] s=[]
	if(typeof(argv(0))=="integer"){for(n=0;n<nargs();n++){s[n]=argv(n)}}else{s=argv(0)}
	a=sizeof(s)
	for(n=0;n<pow(2,a);n++){
    	out[n]=0 b=nnbits(n,a)
    	for(m in b){if(b[m]){out[n]+=s[m]}}
	} return(out) }

#converts n to a binary sequence of length nbits. n<2^nbits
function nnbits(n, nbits){
	if(n<pow(2,nbits)){
		out=[] b=n for(a=0;a<nbits;a++){out[a]=0}
		while(b!=0){ x=integer(log10(b)/log10(2)) b-=pow(2,x) out[x]=1}
        	return(out)}else{ print("... too few bits...") }
}

#mode represents the number of bits per space-separated numerical entries in string parameter str
#modes 4 & 8 are hexadecimal, modes 3 & 6 are octal, All others are decimal.
function ntobinseq(mode,str){
	out=[] c=[] tr(c,split(str)) prefix=""
	if(mode==3){ prefix="0" }
	if(mode==6){ prefix="0" }
	if((mode==4)||(mode==8)){ prefix="0x" }
	for(n in c){ c[n]=revseq(nnbits(integer(prefix+c[n]),mode)) tr(out, juxt(out, c[n])) }
	return(out)

}

#phrase cut into a sequence combined with a binary sequence giving the time (each bit is a step)
function phbin(ph,mode,str){
	out='' c=0 pha=phtoseq(ph) a=ntobinseq(mode,str) b=sizeof(split(str))
	e=lcm(asum(a),sizeof(pha)) z=0
	while(c!=e){ if(a[z%sizeof(a)]==1){ out=out|delay(pha[c%sizeof(pha)], z*Td) c+=1 } z++ }
	out.length=(lcm(sizeof(pha),asum(a))/asum(a))*b*(sizeof(a)/b)*Td
	return(out)
}

#each bit defines a window of bitlen steps turned on or off depending on its value
function bingate(ph, mode, str, bitlen){
	a=ntobinseq(mode,str) c=[] ite=1 tr(c,split(str))
	c=chopl(ph, bitlen)
	for(n in c){if(a[n%sizeof(a)]==0){c[n]-=c[n]}}
	out=seqtoph(c) out.length=ph.length
    return(out)
}


#0 you get a, 1 you get b. bitlen is the length of one bit in steps
function binab(a,b,mode,str,bitlen){
	return(bingate(b,mode,str,bitlen)|(a-bingate(a,mode,str,bitlen)))
}

#0 you get a, 1 you get b
function binabseq(a,b,mode,str){
	out=[] bits=ntobinseq(mode,str) l=lcm(sizeof(a),sizeof(b),sizeof(bits))
	for(n=0;n<l;n++){ if(bits[n%sizeof(bits)]==0){ out[n]=a[n%sizeof(a)] }else{ out[n]=b[n%sizeof(b)] } }
	return(out)
}

#numbers determine the rows (or columns if you prefer to see it this way) of a binary matrix that
#determines whether of not a phrase plays at a certain moment. each column (or row if you prefer
#to see it this way) represents a duration of bitlen.
#for example:
#      "0 1 2 3" with a pha of size 2
#pha(0) 0 1 0 1
#pha(1) 0 0 1 1
#result's length is equal to the least common multiplicator between the greatest length of the
#phrases and the number of numbers in str times numlen
function phsbin(pha,str,numlen){
	out='' a=[] b=[] tr(a,revseq(pha)) c=sizeof(a)
	d=0 for(n in pha){if(d<pha[n].length){d=pha[n].length}}
	b=ntobinseq(c,str) tln=lcm(d, (sizeof(split(str)))*Td*numlen)
	for(n in a){ a[n]=chopl(repleng(a[n],tln),numlen) }
	for(n=0;n<sizeof(pha)*(tln/(numlen*Td)); n++){if(!b[n%sizeof(b)]){ a[n%c][n/c]-=a[n%c][n/c] }}
	for(n in a){ out|=seqtoph(a[n]) } out.length=tln
	return(out)
}

function binfo(ph,mode){
	if((ph.length/Td)%mode!=0){print("Error, (phrase.lenght/Td)%mode!=0") return(0)}
	k=ph.length/(Td*mode) out=""
	a=chopl(onlynotes(ph),1)
	b=[] c='' c.length=Td
	for(i=0;i<k;i++){
		b[i]=0
		for(j=0;j<mode;j++){
			if(a[j+i*mode]!=c){b[i]+=pow(2,mode-(1+j))}
		}
		if((mode==6)||(mode==4)||(mode==8)){ out+=convertn(b[i],mode)+" " }else{out+=string(b[i])+" "}
	}
	print(out)
	return(out)

}

function convertn(n,mode){
	h=seq(0,1,2,3,4,5,6,7,8,9,"A","B","C","D","E","F")
	if(mode==4){return(string(h[n]))}
	if(mode==8){return(string(h[n/16])+string(h[n%16]))}
	if(mode==6){return(string(n/8)+string(n%8))}
}