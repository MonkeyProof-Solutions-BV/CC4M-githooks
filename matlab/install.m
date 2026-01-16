function varargout = install(usePPI)
    % INSTALL hooks support for GIT
    %

    % Copyright 2026 MonkeyProof Solutions BV

    arguments (Input)
        % usePPI (true/false) When true (default), matlabengine is installed from PyPi, otherwise installed from MATLAB
        % installation.
        usePPI logical = true
    end

    arguments (Output)
        hasFailed
        msg
    end

    % Define locations
    [~, versionInfo] = monkeyproof.cc4m.utils.getEnvironmentInfo();
    targetDir        = fullfile(userpath, 'cc4m', 'python', versionInfo.MATLABVersionNr);
    activateCall     = fullfile(targetDir, 'Scripts', 'activate');
    [~, ~]           = mkdir(targetDir);
    pythonDir        = fullfile(pwd, '..', 'cc4m_githooks');

    % Make sure Python environment available.
    disp("Checking if Python is available.")
    pe = pyenv();
    if isempty(pe.Version)
        % No Python available
        hasFailed = true;
        disp("No Python is available.")
        msg = "No Python installed or available via MATLAB.";
    else
        % Python found
        pyCmd = pe.Executable;

        % Test if environment already exists
        pipCommand = "" + activateCall  + " && " + "pip list";
        [hasFailed, msg] = system(pipCommand);

        if hasFailed
            % No environment yet.
            disp("Installing Python environment.")

            % Create venv
            pipCommand = "cd """ + targetDir  + """ && " + pyCmd + " -m venv """ + targetDir + """ && " + activateCall;

            % Install the engine
            if usePPI
                % From Python Package Index
                pipCommand = pipCommand + ...
                    " && " + "pip install matlabengine>=" + versionInfo.MATLABVersionNr;
            else
                % From local files
                pipCommand = pipCommand + ...
                    " && " + "cd """ + fullfile(matlabroot, 'extern', 'engines', 'python') + """" + ...
                    " && " + "python setup.py build --build-base=""" + targetDir + """"; % --build-base=""" + targetDir + """
            end
            [hasFailed, msg] = system(pipCommand);
        end

    end

    % Install Python - GIT integration files
    if ~hasFailed
        disp("MATLAB engine installed. Now adding CC4M integration.")

        pipCommand = activateCall  + " && " + "pip install " +pythonDir;
        [hasFailed, msg] = system(pipCommand);

        if hasFailed
            disp("CC4M integration could not be installed!")
            disp(msg)
        else
            disp("CC4M integration installed.")

            pipCommand = "" + activateCall  + " && " + "pip list";
            [hasFailed, msg] = system(pipCommand);
        end
    end

    % Install Required MATLAB files - in the default userpath
    if ~hasFailed
        disp("Now adding CC4M MATLAB code.")
        destFolder = monkeyproof.cc4m.utils.userpath();
        [isOk, msg] = copyfile('precommit_example.m', destFolder, 'f');
    end

    for iOut = 1:nargout
        switch iOut
            case 1
                varargout{1} = isOk;

            case 2
                varargout{2} = msg;

        end
    end

end