#Lightweight hacking together of single subject job scripts (.m & .sh) from template to quickly paraellise job submission (ie. append s=1 to template)
#Choice to send jobs (code always writes submitCmd.txt)
#========================

#5 Args
#fileName of templateScript
#outputDir
#nSubs (or anything iterable like ROIs)
#sendJobs (1 = yes, 0 = no)
#Character to iterate (typically 's' for subjects: s = 1 | 'r' for ROIs: r = 1)

#Usage: 
# python createJobScripts.py /imaging/ek03/createJobs/meg/removeOld.m /imaging/ek03/createJobs/tmp 1
# python /imaging/ek03/submitJobs.py /imaging/camcan/sandbox/ek03/APOE/meg/broadband_forRik3/wrapper_singleSubject.m /imaging/camcan/sandbox/ek03/APOE/meg/broadband_forRik3/job 1 1
# python /imaging/ek03/submitJobs.py /imaging/camcan/sandbox/ek03/APOE/meg/wrapper_singleSubject.m /imaging/camcan/sandbox/ek03/APOE/meg/job 608 1
# python /imaging/ek03/submitJobs.py /imaging/camcan/sandbox/ek03/APOE/meg/wrapper_ROI.m /imaging/camcan/sandbox/ek03/APOE/meg/job 608 1
# python /imaging/ek03/submitJobs.py /imaging/ek03/MVB/FreeSelection/pp/wrapper_singleROI.m /imaging/ek03/MVB/FreeSelection/pp/jobs 24 1 r

import sys

fN = (sys.argv[1])
outDir = (sys.argv[2])
nSubs = int((sys.argv[3]))
sendJobs = int((sys.argv[4]))
charToIterate = (sys.argv[5])

print("\nModifying copies of template:\n%s\n\nIn destination:\n%s\n\nScripts created for # Subs:\n%d\n" % (fN,outDir,nSubs))

#Read template
f = open(fN,"r")
template = f.read()
f.close()

for i in range(1,nSubs+1):
    #Create job*.m
    #line = "%s = %d\n" % (charToIterate, i)
    line = "%s = %d\n" % (charToIterate,i)
    f = open("%s/job%d.m" % (outDir,i),"w") 
    f.write(line) 
    f.write(template)
    f.close

    #Create job*.sh
    line = "#!/bin/bash\n#SBATCH -J job%d\n#SBATCH -o job%d.out\n\n/hpc-software/matlab/r2019a/bin/matlab -nodesktop -nosplash cd %s -r job%d" % (i,i,outDir,i)
    f = open("%s/job%d.sh" % (outDir,i),"w") 
    f.write(line)
    f.close

print("Replacing old submission command file:\n%s/submitCmd.txt\n" % (outDir))
import os, time

#delete old version
if os.path.isfile("%s/submitCmd.txt" % (outDir)):
    os.remove("%s/submitCmd.txt" % (outDir))
    
#write new version
for i in range(1,nSubs+1):
    line = "sbatch job%d.sh\n" % (i)
    f = open("%s/submitCmd.txt" % (outDir),"a+")
    f.write(line)
    f.close
    if sendJobs == 1:
        print("sending jobs")
        os.chdir(outDir)
        if os.getcwd() == outDir:
            time.sleep(0.01)
            os.system(line)