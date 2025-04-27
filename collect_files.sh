#!/usr/bin/env python3
import argparse
import subprocess
import os

def checkDir(inDir, outDir, depth=1, max_depth=2147483647):
    global keepDirs
    global fileDict
    global inDirRoot
    global outDirRoot
    files=subprocess.run(["ls", inDir], capture_output=True, text=True).stdout.split();
    for i in files:
        if os.path.isdir(inDir+"/"+i):
            if keepDirs:
                if depth<max_depth:
                    subprocess.run(["mkdir", "-p", outDir+"/"+i]);
                
            checkDir(inDir+"/"+i, outDir+"/"+i, depth+1, max_depth);
        if os.path.isfile(inDir+"/"+i):
            if keepDirs:

                outPath=inDir.replace("/"+inDirRoot, "")
                outPath=outPath.split("/")
                if len(outPath)>max_depth:
                    while len(outPath)>max_depth:
                        outPath=[outPath[0]]+outPath[2:]
                        print(outPath)
                        
                outPath="/".join(outPath)
                print(outDir, outPath)
                subprocess.run(["mkdir", "-p", outDirRoot+outPath]);
                subprocess.run(["cp", "-p", inDir+"/"+i, outDirRoot+outPath+"/"+i])
                
            else:
                if os.path.exists(outDirRoot+"/"+i):
                    if "."in i:
                        fn=list(i)
                        fn.insert(i.find("."), str(fileDict.get(i)))
                        fn="".join(fn)
                    else:
                        fn=i+str(fileDict.get(i))
                    subprocess.run(["mv", outDirRoot+"/"+i, outDirRoot+"/"+fn])
                subprocess.run(["cp", inDir+"/"+i, "-t", outDirRoot])
                fileDict[i]=fileDict.get(i, 0)+1

arg=argparse.ArgumentParser();

arg.add_argument("inp", type=str);
arg.add_argument("out", type=str);
arg.add_argument("--max_depth", type=int, default=None);
args=arg.parse_args();

os.chdir("/")

outDirRoot=args.out
inDirRoot=args.inp
fileDict={}
keepDirs=False;

print(args)
subprocess.run(["mkdir", "-p", args.out])
if args.max_depth==None:
    md=2147483647
else:
    md=args.max_depth
    keepDirs=True

checkDir(os.getcwd()+args.inp, os.getcwd()+args.out, 1, md)
