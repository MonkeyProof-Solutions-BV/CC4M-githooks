import matlab.engine
import subprocess
import sys
import os
import time

print(os.environ['PYTHONPATH'])

ENG_ID = "CC4M_MATLAB_SESSION"

def run(envDir, matlabExe, gitRootFolder, matlabCmd):
    names = matlab.engine.find_matlab()
    print(names)
    print(envDir)
    print(matlabExe)
    print(gitRootFolder)
    
    if ENG_ID in names:
        print ("engine found")
    else:
        cmd = '"' + matlabExe + '"' + '-nodesktop -nodisplay -r "matlab.engine.shareEngine(' + "'CC4M_MATLAB_SESSION'" + ')"'
        print (cmd)
        result = subprocess.call(cmd)
        print(result)

        # After starting it takes some time, before the engine can connect.
        engineFound = False

        while not result and not engineFound:
            print( "No engine Found yet - still starting...")
            names = matlab.engine.find_matlab()

            if ENG_ID in names:
                engineFound = True
            else:
                time.sleep(2)

    eng = matlab.engine.connect_matlab(ENG_ID)

    # Add folder that contains the CC4M calling routine to the path.
    eng.eval("addpath(monkeyproof.cc4m.utils.userpath())")

    # Perform the check.
    exitFlag = eng.eval(matlabCmd)
    eng.quit()

    if exitFlag == 1:
        return 1
    elif exitFlag == 2:
        return 2
    else:
        return 0
        
if __name__ == "__main__":
   exitFlag = run(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4])
   sys.exit(exitFlag)

