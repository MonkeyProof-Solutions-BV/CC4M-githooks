import matlab.engine
import subprocess
import sys
import os
import time

print(os.environ['PYTHONPATH'])

ENG_ID = "CC4M_MATLAB_SESSION"

def run(envDir, matlabExe, gitRootFolder, matlabCmd):
    #sys.path.append(envDir)

    

    #names ={"a", "b"}
    names = matlab.engine.find_matlab()
    print(names)
    print(envDir)
    print(matlabExe)
    print(gitRootFolder)
    
    if ENG_ID in names:
        print ("engine found")
        pass
    else:
        cmd = '"' + matlabExe + '"' + '-nodesktop -nodisplay -r "matlab.engine.shareEngine(' + "'CC4M_MATLAB_SESSION'" + ')"'
        print (cmd)
        result = subprocess.call(cmd)
        print(result)

        engineFound=False
        # After starting it takes some time, before the engine can connect
        while not result and not engineFound:
            print( "No engine Found yet - still starting...")
            names = matlab.engine.find_matlab()
            if ENG_ID in names:
                engineFound = True
            else:
                time.sleep(2)
            
        

    eng = matlab.engine.connect_matlab(ENG_ID)
    exitFlag = eng.eval(matlabCmd)
    eng.quit()
    if exitFlag == 1:
        return 1
    else:
        return 0



if __name__ == "__main__":
   exitFlag = run(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4])
   sys.exit(exitFlag)

