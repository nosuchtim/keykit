# 'co0'.pitch=24 => a='co3'

#applies the melody of mel_a to time_a
function mel_time(mel_ph,time_ph){
	a=[] b=[] c=0 i=[] out=''
	for(n in time_ph){a[n.time]=0} for(n in a){ b[c]=n c+=1 } arraysort(b)
	a=[] a=phtoseq(mel_ph) c=lcm(sizeof(a),sizeof(b)) tr(i,b) e=(c/sizeof(b))
	for(n=1;n<e;n++){ tr(i,juxt(i,saddk(b,n+time_ph.length))) }
	for(n in i){ out|=delay(a[n%sizeof(a)],i[n]) }
	out.length=e*time_ph.length
	return(out)
}


#pitch map
#without map - prints pitches and number of occurences
#with map - applies new pitches [a=x, b=y, c=z]
function pm(){
	if(argv(1)!=""){
		a=argv(0) b='' m=argv(1)
		for(n in m){ b|=transpose(a{??.pitch==n},m[n]-n) a-=a{??.pitch==n}}
		return(b|a)
	}
	else{
		s=[] a=""
		for(n in onlynotes(argv(0))){ if(s[n.pitch]==""){s[n.pitch]=1}else{s[n.pitch]+=1} }
		for(n in s){a+=string(n)+":"+string(s[n])+" "}
		print("\n"+"pitches occurences :"+"\n"+a)
	}
}

#octave map
function om(ph){
	if(argv(1)!=""){
		a=ph b='' m=argv(1)
		for(n in m){ b|=transpose(ph{(??.pitch%12)==n},m[n]-n) a-=ph{(??.pitch%12)==n}}
		return(b|a)
	}else{
		s=seq(0,0,0,0,0,0,0,0,0,0,0,0) a=""
		for(n in onlynotes(ph)){s[n.pitch%12]+=1}
		for(n in s){if(s[n]!=0){a+=string(n)+":"+string(s[n])+" "}}
		print("\n"+"octave : "+a)
	}
}

#prints number of steps of phrase a
function info(ph){ print("Td:"+string(Td)+" nsteps:"+ string(ph.length/Td) + " remaining:"+ string(ph.length%Td)+" nbnotes:"+string(sizeof(ph))) }


#phrase filter. f is filter as a sequence, t is type; "p" is pitch, "n" is note number,
#"t" is time in steps, "d" is duration in steps. The function returns an array. At index
#0 is the result when the concerned notes are kept, at index 1 is the result when the
#concerned notes are removed.
function filt(ph,f,t){
	out=[] a='' b='' g=[] tr(g,f) arraysort(g) m=g[sizeof(g)-1]

	if(t=="p"){
		for(n=0;n<(sizeof(g)-1);n++){ a|=ph{??.pitch%m==g[n]} }
		a.length=ph.length b=ph-a b.length=ph.length out[0]=a out[1]=b
	}
	if(t=="n"){
		for(n=1;n<=sizeof(ph);n++){ for(o=0;o<(sizeof(g)-1);o++){ if(((n-1)%m)==g[o]){a|=ph%n} } }
		a.length=ph.length b=ph-a b.length=ph.length out[0]=a out[1]=b
	}
	if(t=="t"){
		for(n=0;n<(sizeof(g)-1);n++){ a|=ph{(??.time/Td)%m==g[n]} }
		a.length=ph.length b=ph-a b.length=ph.length out[0]=a out[1]=b
	}
	if(t=="d"){
		for(n=0;n<sizeof(g);n++){ a|=ph{??.dur==g[n]*Td} }
		a.length=ph.length b=ph-a b.length=ph.length out[0]=a out[1]=b
	}
	return(out)
}


#window resize. phrase is cut in chunks of length 'a' steps that are pasted back together as if the
#chunks where of length 'b' steps. A kind of overlapping is possible if (b<a) is true.
function wr(ph,a,b){ p=[] p=chopl(ph,a) for(n in p){p[n].length=b*Td} return(seqtoph(p)) }

function swing(ph,ncl){
	out='' p=chopl(ph,1)
	for(n in p){if(n%2==1){p[n].time+=ncl}} out=seqtoph(p) out.length=ph.length return(out)
}

#shuffle phrase using chunks of length l in steps
function shuffl(ph,l){ n=ph.length/(l*Td)
	k=[] out='' k=shuffseq(chopl(ph,l)) out=seqtoph(k)
	out.length=ph.length return(out)
}


#cuts a in n parts then pastes it according to sequence
function phns(ph,n,s){
	out='' b=chopp(ph,n)
	for(a=0;a<sizeof(s);a++){ out+=b[s[a]] }
	return(out)
}


#returns the sequence of a cut in n equal parts
function chopp(ph,n){
	out=[] a=ph.length/n
	for(x=0;x<n;x++){ out[x]=delay(ph{(??.time>=(x*a))&&(??.time<((x+1)*a))},-(x*a)) out[x].length=a}
	return(out)
}


#returns the sequence of a cut in parts of length l
function chopl(ph,l){
	n=ph.length/(l*Td)
	out=[] a=ph.length/n
	for(x=0;x<n;x++){ out[x]=delay(ph{(??.time>=(x*a))&&(??.time<((x+1)*a))},-(x*a)) out[x].length=a}
	return(out)
}


#rotation in steps for phrases. also works for sequences
function rot(a, len){
	if(typeof(a)=="phrase"){
		out=seqtoph(rot(chopl(a,1),len))
		out.length=a.length return(out)
 	}
	if(typeof(a)=="array"){
		out=[]
 		for(n in a){ out[n]=a[(n+sizeof(a)-len)%sizeof(a)] }
        	return(out)
	}
	print("invalid parameter")
}


#pastes phrases in a sequence one after the other
function seqtoph(arr){ len=(sizeof(arr)) out=''
	for(n in arr){ out+=arr[n] } return(out) }


#returns a sequence of the sections of a phrase marqued by different times
function phtoseq(ph){
	a=[] c=0 t=[] out=[]
	for(b in ph){a[b.time/Td]=0}
	for(b in a){t[c]=b c+=1} t[c]=(ph.length/Td)
	for(n=0;n<c;n++){ out[n]=chop(ph,t[n+1]-t[n],t[n]) }
	return(out)
}



#Chops a piece of ln steps from a phrase or sequence , optionally starting at argv(2)
function chop(ph, ln){
	if(typeof(ph)=="phrase"){
		st=0
        	if(argv(2)!=""){st=argv(2)}
		a=ph{(??.time>=st*Td)&&(??.time<Td*(st+ln))}
		a.time-=st*Td a.length=ln*Td
		return(a)
	}
	if(typeof(ph)=="array"){
		a=0 if(argv(2)!=""){deb=argv(2)}else{ deb=0 } out=[]
		for(n in ph){ if((n<(ln+deb))&&((n)>=deb)){ out[a]=ph[n] a=a+1} }
		return(out)
	}
	print("invalid parameter")
}


function overwrite(a,b,pos){
	if(typeof(a)=="array"){out=[] tr(out,a) for(n=0;n<sizeof(b);n++){out[n+pos]=b[n]} return(out)}
	if(typeof(a)=="phrase"){out=a{(??.time<pos*Td)&&(??.time>=pos*Td+b.length)} out|=delay(b,pos*Td) return(out)}
	print("invalid parameter")
}

#GENerate : Pitch index sequence, Duration (in steps) sequence, [Total length in steps]
function gen(p,d) {
	out=''
	if(typeof(d)=="array"){
		if(typeof(p)=="array"){
			for(a=0;a<lcm(sizeof(d),sizeof(p));a++){
				if(typeof(p[a%sizeof(p)])=="array"){
					c='' for(b in p[a%sizeof(p)]){ c|=$.gen(p[a%sizeof(p)][b],d[a%sizeof(d)]) }
					out+=c
				}else{
					out+=phrase("'p"+string(p[a%sizeof(p)])+"d"+string(Td*d[a%sizeof(d)])+"'")}
			}
			}else{
			for(a=0;a<sizeof(d);a++){ out+=phrase("'p"+string(p)+"d"+string(Td*d[a%sizeof(d)])+"'") }
		}
	}
	else{
		if(typeof(p)=="array"){
			for(a=0;a<sizeof(p);a++){
				if(typeof(p[a%sizeof(p)])=="array"){
					c='' for(b in p[a%sizeof(p)]){ c|=$.gen(p[a%sizeof(p)][b],d) }
					out+=c
				}else{
					out+=phrase("'p"+string(p[a%sizeof(p)])+"d"+string(Td*d)+"'")
				}
			}
		}else{
			out+=phrase("'p"+string(p)+"d"+string(Td*d)+"'")
		}
	}
	if(argv(2)!=""){ out=chop(out,argv(2)) }
	return(out)
}

#wraps values so that they fit in [mini,mini+amp[
function wrap(inp,mini,amp){
	if(typeof(inp)=="phrase"){
        	b=[] out='' c=0 d=onlynotes(inp)
        	for(n in d){b[c]=n.pitch c+=1}
        	b=wrap(b,mini,amp)
        	for(n=1;n<=sizeof(d);n++){d%n.pitch=b[n-1]}
        	out=d|nonnotes(inp)
        	return(out)
	}
	if(typeof(inp)=="array"){
		a=[] out=[]
		for(n=0;n<amp;n++){a[n]=(mini+n)}
		for(n in inp){out[n]=a[(amp+inp[n]-mini)%amp]}
		return(out)
	}
	print("invalid parameter")
}

#bounces values so that they fit in [mini,mini+amp[
function bounce(inp,mini,amp){
	if(typeof(inp)=="phrase"){
        	b=[] out='' c=0 d=onlynotes(inp)
        	for(n in d){b[c]=n.pitch c+=1}
        	b=bounce(b,mini,amp)
        	for(n=1;n<=sizeof(d);n++){d%n.pitch=b[n-1]}
        	out=d|nonnotes(inp)
        	return(out)
	}
        if(typeof(inp)=="array"){
		a=[] b=[] c=[] out=[]
		for(n=0;n<amp;n++){ a[n]=(mini+n) }
		for(n=1;n<(amp-1);n++){b[n-1]=a[n]}
		c=juxt(a,revseq(b))
		for(n in inp){out[n]=c[(inp[n]-mini+(100*sizeof(c)))%sizeof(c)]}
		return(out)
	}
	print("invalid parameter")
}

function mergeph(l){
	k=nargs()-1
	a=[] out='' kl=argv(1).length/(l*Td)
	for(n=0;n<k;n++){a[n]=chopl(argv(n+1),l)}
	for(i=0;i<kl;i++){for(j=0;j<k;j++){out+=a[j][i]}}
	return(out)
}

function trans(ph, t) {
	if(typeof(t)=="integer"){
		out='' d=''
		for(n in ph){ d=n d.pitch=(d.pitch+t) out|=d }
		out.length=ph.length
	}else{
		out='' a=[] tr(a,t) if(argv(2)!=""){ ite=argv(2) }else{ ite=1 }
		for(n=1;n<ite;n++){ tr(a,juxt(a,t)) }
		b=sizeof(a) c=ph.length/b
		for(n=0;n<b;n++){ out|=trans(ph{(??.time>=n*c) && (??.time<((n+1)*c))} ,a[n]) }
	}
	return(out)
}