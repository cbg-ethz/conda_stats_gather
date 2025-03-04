# -v headers="$(yq 'join(",")' make_csv.yaml)"
BEGIN{
	FS=",";
	split(headers,hlist,FS);
};
FNR==1{
	x="";f="";
	for(i=1;i<=NF;i++){
		hcur[$i]=$i
	};
	for(n in hlist){
		if(hlist[n] in hcur){
			;
		}else{
			x = x "," hlist[n];
			f = f ",0"
		}
	}
	print $0 x
};
FNR>1{
	print $0 f
}
