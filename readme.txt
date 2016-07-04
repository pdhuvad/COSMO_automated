This script calculates the total activity for given material.

Requirements: 
1)COSMO executable in the parent directory
2)“include” directory, 
3)input.txt file (see description)
4)time_energy.txt (see description)
5)auto.sh script


Discription of the Input files.
1)input.txt
This file has two columns, one the periodic number of the elements in the material , second their weight factor. 
For example stainless steel 316Ti is composed of following elements: Chromium  , Molybdenum  , Nickel  , Manganese  , Phosphorus  , Sulfur  , Silicon  , Carbon  , Nitrogen  , Titanium  , Iron  
Input file should look like this: 
_____________________________________________________________________
24	0.1700000
42	0.0250000
28	0.1200000
25	0.0250000
15	0.0002250
16	0.0001500
14	0.0037500
6	0.0004000
7	0.0005000
22	0.0045000
26	0.6504750
______________________________________________________________________

2)time_energy.txt
This file should haved three line 
Line 1) Exposure time, decay time (days)
Line 2) calculation mode, “a” fixed
Line 3) Begining bombarding energy,delta energy,number of energy steps

For example: 
__________________________________________________________________
45,365
a
40,20,300
__________________________________________________________________


With following two input file execute 
user$ /bin/bash/auto.sh

The script creates the input files for the COSMO,execute it and then writes the weighted activities in the summary_cosmo.txt file. 

For example above, Stainless steel 316Ti, summary_cosmo.txt file and manually calculated activities can be found in “example” directory for comparison. 


Note:
1)User should have permission to create and delete file in the working directory
2)auto.sh uses the C compiler, cc is default. If it is not available then please change it in the script accordingly. 
