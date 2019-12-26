function ack(a,b,t) {
	if ( a == 0 ) return(b + 1)
	if ( b == 0 ) return(ack(a-1,1))
	t = ack(a,b-1)
	return(ack(a-1, t))
}

R1=R2=R3=R4=R5=0

function f1(){p=repeat('a,b,c,d',40);p=reverse(flip(p));p=p{(??.number%3)==1};R1=sizeof(p);}
task f1()
function f2(){ R2=ack(2,3);}
task f2()
function f3(){R3=ack(3,2);}
task f3()
function f4(){R4=ack(3,3);}
task f4()
function f5(){t=0;for(n=0;n<1000;n++)t+=n;R5=t;}
task f5()

while ( R1>=0 || R2>=0 || R3>=0 || R4>=0 || R5>=0 ) {
	if ( R1>0 ) {R1 = -R1}
	if ( R2>0 ) {R2 = -R2}
	if ( R3>0 ) {R3 = -R3}
	if ( R4>0 ) {R4 = -R4}
	if ( R5>0 ) {R5 = -R5}
}
print(R1,R2,R3,R4,R5)
