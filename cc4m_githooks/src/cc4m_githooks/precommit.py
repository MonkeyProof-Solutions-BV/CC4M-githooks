import matlab.engine
import subprocess
import sys
import os
import time
import io

print(os.environ['PYTHONPATH'])

ENG_ID = "CC4M_MATLAB_SESSION"

def run(envDir, matlabExe, gitRootFolder, matlabCmd):

    out = io.StringIO()
    err = io.StringIO()

    names = matlab.engine.find_matlab()
    
    if ENG_ID in names:
        print ("engine found")
    else:
        cmd = '"' + matlabExe + '"' + ' -nodesktop -minimize -r "matlab.engine.shareEngine(' + "'CC4M_MATLAB_SESSION'" + ')"'
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
    print ("call CC4M")
    try: 
        print (matlabCmd)
        exitFlag = eng.eval(matlabCmd,stdout=out,stderr=err)
        print (exitFlag)
        print (int(exitFlag))
        print (type(exitFlag))
        print ("CC4M done")

    except "MatlabExecutionError":
        exitFlag = 11
        print("MATLAB error")
    
    except "RejectedExecutionError":
        exitFlag = 12
        print("MATLAB engine error")
    
    except "SyntaxError":
        exitFlag = 13
        print("MATLAB syntax error")
    
    except "TypeError":
        exitFlag = 14
        print("MATLAB type error")

    finally:
        print(out.getvalue())
        print(err.getvalue())

    print ("leaving CC4M")
    print()
    eng.quit()

    return int(exitFlag)
        
if __name__ == "__main__":

    print ("inputs")
    print(sys.argv[0])  
    print(sys.argv[1])
    print(sys.argv[2])
    print(sys.argv[3])
    print(sys.argv[4])
    print ("inputs")
    exitFlag = run(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4])
    sys.exit(exitFlag)

