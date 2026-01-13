function [hasFailed, msg] = installEngine(usePPI)
    %INSTALLENGINE undefined
    %   undefined
    arguments (Input)
        usePPI = false
    end

    arguments (Output)
        hasFailed
        msg
    end


    % Create "environment" folder
    [~, versionInfo] = monkeyproof.cc4m.utils.getEnvironmentInfo();
    targetDir        = fullfile(userpath, 'cc4m', 'python', versionInfo.MATLABVersionNr);
    activateCall     = fullfile(targetDir, 'Scripts', 'activate');
    [isOK, mkdirMsg] = mkdir(targetDir);

    %
    pe = pyenv();
    if isempty(pe.Version)
        % No Python available
        hasFailed = true;
        msg = "No Python Installed";
    else
        % Python found
        pyCmd = pe.Executable;

        % Test if environment already exists
        pipCommand = "" + activateCall  + " && " + "pip list";
        [hasFailed, msg] = system(pipCommand)


        % Create venv
        pipCommand = "cd """ + targetDir  + """ && " + pyCmd + " -m venv """ + targetDir + """ && " + activateCall;

        % Install the engine
        if usePPI
            % From Python Package Index
            pipCommand = pipCommand + ...
                " && " + pyCmd + " -m pip install --target " + targetDir + " matlabengine>=" + versionInfo.MATLABVersionNr;
        else
            % From local files
            pipCommand = pipCommand + ...
                " && " + "cd """ + fullfile(matlabroot, 'extern', 'engines', 'python') + """" + ...
                " && " + "python setup.py build --build-base=""" + targetDir + """"; % --build-base=""" + targetDir + """
        end
        [hasFailed, msg] = system(pipCommand);

        % Test if environment already exists
        pathCommand = "set PYTHONPATH=" + fullfile(targetDir, 'Lib') + ";%PYTHONPATH%"
        pipCommand = pathCommand + " && " + activateCall  + " && " + "pip list";
        [hasFailed, msg] = system(pipCommand)

    end

end