#!/usr/bin/env python3
import argparse
import subprocess
import os

def checkDir(inDir, outDir, depth=0, max_depth=2147483647):
    if depth>max_depth:
        return
    global keepDirs
    global fileDict
    files=subprocess.run(["ls", inDir], capture_output=True, text=True).stdout.split();
    for i in files:
        if os.path.isdir(inDir+"/"+i):
            checkDir(inDir+"/"+i, outDir+"/"+i, depth+1, max_depth);
        if os.path.isfile(inDir+"/"+i):
            if keepDirs:
                subprocess.run(["mkdir", outDir])
                subprocess.run(["cp", inDir+"/"+i, outDir+"/"+i])
            else:
                global outDirFixed
                if os.path.exists(outDirFixed+"/"+i):
                    if "."in i:
                        fn=list(i)
                        fn.insert(i.find("."), str(fileDict.get(i)))
                        fn="".join(fn)
                    else:
                        fn=i+"1"
                    subprocess.run(["mv", outDirFixed+"/"+i, outDirFixed+"/"+fn])
                subprocess.run(["cp", inDir+"/"+i, "-t", outDirFixed])
                fileDict[i]=fileDict.get(i, 0)+1

arg=argparse.ArgumentParser();

arg.add_argument("inp", type=str);
arg.add_argument("out", type=str);
arg.add_argument("--max_depth", type=int, default=None);
args=arg.parse_args();

outDirFixed=args.out
fileDict={}

subprocess.run(["rm", "-r", args.out])
subprocess.run(["mkdir", args.out])
if args.max_depth==None:
    md=2147483647
    keepDirs=False
else:
    md=args.max_depth
    keepDirs=True

checkDir(os.getcwd()+"/"+args.inp, os.getcwd()+"/"+args.out, 0, md)
