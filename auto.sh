#/bin/bash/
FILE1=input.txt
if [ -f $FILE1 ];
then
   echo "File $FILE1 exists."
else
   echo "File $FILE1 does not exist. Exiting script..."
  exit 
fi
FILE2=time_energy.txt
if [ -f $FILE2 ];
then
   echo "File $FILE2 exists. Script continue...."
else
   echo "File $FILE2 does not exist. Exiting script..."
  exit 
fi

# embeded manipulate.c is below.
>manipulate.c
cat >> manipulate.c << EOF
#include <stdio.h>
#include <math.h>
#include <string.h>
#define weight 0.6504750
struct element 
{ 
  int ip,Z,A;
  double t12,dndti,dndtf,dndti_weighted,dndtf_weighted;
};
int main ()
{
struct element val[100];
FILE *inp,*opt;
int reccount = 0;
int x = 0,c1,xmax;
double c2,c3,c4,c5,c6,Total_dndti_weighted = 0, Total_dndtf_weighted = 0;
opt = fopen("cout.txt","a");
inp = fopen("out.txt", "r");
	if(!inp)
	{
		printf("Unable ot open file\n");
	}
while (fscanf(inp,"%d %lf %lf %le %le %le \n",&c1,&c2,&c3,&c4,&c5,&c6) != EOF)
	{

         val[x].ip= c1;
         val[x].Z = c2;  
         val[x].A= c3;
         val[x].t12= c4;
         val[x].dndti = c5;  
         val[x].dndtf = c6;  
//	printf("val.ip = %d\n", val[x].ip);
//	printf("val.Z = %d\n",val[x].Z);

		x++;
	xmax = x;
	}	
	fclose(inp);
for (x=0;x<xmax;x++)  
{
	val[x].dndti_weighted = val[x].dndti * weight;
	val[x].dndtf_weighted = val[x].dndtf * weight;
	Total_dndti_weighted += val[x].dndti_weighted;
	Total_dndtf_weighted += val[x].dndtf_weighted;
}
fprintf (opt,"Total_dndti_weighted=\t%le\n",Total_dndti_weighted);
fprintf (opt,"Total_dndtf_weighted=\t%le\n",Total_dndtf_weighted);
fprintf (opt,"ip \t Z \t A \t t(1/2) \t dndti \t\t dndtf \t\t dndti_weighted   dndtf_weighted \n");
for (x=0;x<xmax;x++) 	fprintf(opt,"%d \t %d \t %d \t %le \t %le \t %le \t %le \t %e \n",val[x].ip,val[x].Z,val[x].A,val[x].t12,val[x].dndti,val[x].dndtf,val[x].dndti*weight,val[x].dndtf*weight); 
fclose(opt);
//printf("%d \n",system("ls")); 
//printf("weight = %lf",weight);

return 0;
}
EOF

index=0
awk '{print $1}' input.txt > elements 
awk '{print $2}' input.txt> weights
while read line 
do 
elements[$index]="$line"
index=$(($index+1))
done < ./elements
index=0
while read line 
do 
weights[$index]="$line"
index=$(($index+1))
imax=$index
done < ./weights
printf "Total activity contribution from each element\n" >summary_cosmo.txt
printf "\tZ\t weight \t dndti \t dndtf\n">>summary_cosmo.txt
awk '{SUM += $1}END { print "Total weight ="SUM " Note: Total weight should be equal to 1"  }' weights 
for ((i=0;i<imax;i++))  
do
awk 'NR==1' time_energy.txt > "${elements[$i]}"_input.txt 
echo "${elements[$i]}" >> "${elements[$i]}"_input.txt
more ./include/"${elements[$i]}".txt >>"${elements[$i]}"_input.txt
more ./include/"$[${elements[$i]}+1]".txt >>"${elements[$i]}"_input.txt
more ./include/"$[${elements[$i]}-1]".txt >>"${elements[$i]}"_input.txt
awk 'NR==2' time_energy.txt >> "${elements[$i]}"_input.txt 
awk 'NR==3' time_energy.txt >> "${elements[$i]}"_input.txt 
../cosmo < "${elements[$i]}"_input.txt > "${elements[$i]}"_log_cosmo.txt
cp cosmo.tvt "${elements[$i]}"_cosmo.tvt
awk '$0~s{p=1;next}/^$/{p=0}p' s="dndti        dndtf" "${elements[$i]}"_cosmo.tvt >out.txt
awk 'match($0,"define weight")==0{print $0}' manipulate.c >tmpfile && mv tmpfile manipulate.c
sed -i "4i #define weight "${weights[$i]}"" manipulate.c 
cc manipulate.c -o manipulate
./manipulate
printf "\t${elements[$i]}\t${weights[$i]}\t" >> summary_cosmo.txt
awk '{SUM += $7}END {printf "%5.5e\t", SUM}' cout.txt >> summary_cosmo.txt
awk '{SUM += $8}END {printf "%5.5e\n", SUM}' cout.txt >> summary_cosmo.txt
mv out.txt "${elements[$i]}"_out.txt
rm cout.txt 
done
rm -f _cosmo.txt cosmo.tvt  weights elements
#rm -f **_out.txt _cosmo.txt cosmo.tvt weights elements
printf "\n\n\nTotal_dndti=" >> summary_cosmo.txt
awk '{SUM += $3}END {printf "\t%5.5e\n", SUM}' summary_cosmo.txt >> summary_cosmo.txt
printf "\nTotal_dndtf=" >> summary_cosmo.txt
awk '{SUM += $4}END {printf "\t%5.5e\n", SUM}' summary_cosmo.txt >> summary_cosmo.txt
printf 'Exposure time,  decay time (days) -->\t ' >sumtmp 
awk 'NR==1' time_energy.txt >> sumtmp 
printf '\nBegining bombarding energy,delta energy,number of energy steps -->\t '>> sumtmp 
awk 'NR==3' time_energy.txt >> sumtmp 
printf '\n\n' >>sumtmp
cat sumtmp summary_cosmo.txt > totsumtmp && mv totsumtmp summary_cosmo.txt
rm -f sumtmp *_out.txt *_log_cosmo.** manipulate.c manipulate 
