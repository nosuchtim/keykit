
class sc{
	method init(){
		$.pmap=[] $.mpmap=[] $.scseq=[]

		#scales
		$.scales=["s234"=seq(0,2,5,9),
		"harmin"=seq(0,2,3,5,7,8,11),
		"melmin"=seq(0,2,3,5,7,9,11),
		"orient"=seq(0,2,4,7,9),
		"egypt"=seq(0,1,4,5,7,8,11),
		"pent"=seq(0,2,4,7,11),
		"jazz"=seq(0,3,5,6,7,10),
  		"maj"=seq(0,2,4,5,7,9,11)]

		$.set(varg(argv(0,nargs())))
	}

	method print(){ print($.scseq) print(sizeof($.pmap)) }

	#forms: set(scale, root), set(array), set(phrase)
	method set() {
		$.scseq=[] a=0 b=0 c=1 $.pmap=[] $.mpmap=[]
		if(typeof(argv(0))=="string"){
			tr($.scseq,$.scales[argv(0)]) arraysort($.scseq)
			for(n in $.scseq){ $.scseq[n]=($.scseq[n]+argv(1))%12 } arraysort($.scseq)
		}
		if(typeof(argv(0))=="phrase"){
                	c=[] a=0 b=0 x=0 p=argv(0) for(n=1;n<=sizeof(p);n++){p%n.pitch=(p%n.pitch)%12}
                	for(n in p){ c[n.pitch]=0 } for(n in c){$.scseq[x]=n x+=1} arraysort($.scseq)
		}

		if(typeof(argv(0))=="array"){
			tr($.scseq,argv(0)) arraysort($.scseq)
		}
		while(c){
			a=$.scseq[b%sizeof($.scseq)]+(1+($.scseq[sizeof($.scseq)-1]/12))*12*(b/sizeof($.scseq))
			if(a<128){$.pmap[b]=a b+=1}else{c=0}
		}
		for(n in $.pmap){$.mpmap[$.pmap[n]]=n}
	}

	method play(){out='' for(n in $.scseq){  out+=phrase("'p"+string($.scseq[n]+60)+"'")  } return(out)}

	#Transpose on scale (ph is on scale, so is the output)
	method trans(ph, t) {
		if(typeof(t)=="integer"){
			out='' d=''
			for(n in ph){ d=n d.pitch=($.pmap[$.mpmap[d.pitch]+t]) out|=d }
			out.length=ph.length
		}else{
			out='' a=[] tr(a,t) if(argv(2)!=""){ ite=argv(2) }else{ ite=1 }
			for(n=1;n<ite;n++){ tr(a,juxt(a,t)) }
			b=sizeof(a) c=ph.length/b
			for(n=0;n<b;n++){ out|=$.trans(ph{(??.time>=n*c) && (??.time<((n+1)*c))} ,a[n]) }
		}
		return(out)
	}



	#GENerate : Pitch index sequence, Duration (in steps) sequence, [Total length in steps]
	method gen(p,d) { out=''
		if(typeof(d)=="array"){
			if(typeof(p)=="array"){
				for(a=0;a<lcm(sizeof(d),sizeof(p));a++){
					if(typeof(p[a%sizeof(p)])=="array"){
						c='' for(b in p[a%sizeof(p)]){ c|=$.gen(p[a%sizeof(p)][b],d[a%sizeof(d)]) }
						out+=c
					}else{
						out+=phrase("'p"+string($.pmap[p[a%sizeof(p)]])+"d"+string(Td*d[a%sizeof(d)])+"'")}
				}

			}else{
				for(a=0;a<sizeof(d);a++){ out+=phrase("'p"+string($.pmap[p])+"d"+string(Td*d[a%sizeof(d)])+"'") }
			}
		}
		else{
			if(typeof(p)=="array"){
				for(a=0;a<sizeof(p);a++){
					if(typeof(p[a%sizeof(p)])=="array"){
						c='' for(b in p[a%sizeof(p)]){ c|=$.gen(p[a%sizeof(p)][b],d) }
						out+=c
					}else{
						out+=phrase("'p"+string($.pmap[p[a%sizeof(p)]])+"d"+string(Td*d)+"'")
					}
				}

			}else{
				out+=phrase("'p"+string($.pmap[p])+"d"+string(Td*d)+"'")
			}
		}
		if(argv(2)!=""){ out=chop(out,argv(2)) }
		return(out)
	}


	method flip(ph){
		out='' a='' l=$.mpmap[lowest(ph)] h=$.mpmap[highest(ph)]
		for(n in onlynotes(ph)){ a=n m=$.mpmap[a.pitch] a.pitch=$.pmap[(h-(m-l))] out|=a }
	       	out.length=ph.length
	       	out|=nonnotes(ph)
		return(out)
	       	}

	#wraps values so that they fit in [mini,mini+amp[
	method wrap(inp,mini,amp){

        	b=[] out='' c=0 d=onlynotes(inp)
        	for(n in d){b[c]=$.mpmap[n.pitch] c+=1}
        	b=wrap(b,mini,amp)
        	for(n=1;n<=sizeof(d);n++){d%n.pitch=$.pmap[b[n-1]]}
        	out=d|nonnotes(inp)
        	return(out)

	}

	#bounces values so that they fit in [mini,mini+amp[
	method bounce(inp,mini,amp){
        	b=[] out='' c=0 d=onlynotes(inp)
        	for(n in d){b[c]=$.mpmap[n.pitch] c+=1}
        	b=bounce(b,mini,amp)
	       	for(n=1;n<=sizeof(d);n++){d%n.pitch=$.pmap[b[n-1]]}
	       	out=d|nonnotes(inp)
	       	return(out)
	}

}
