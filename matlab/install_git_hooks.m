function varargout = install_git_hooks(usePPI)
    % INSTALL_GIT_HOOKS install hooks support for GIT
    %
    % Installation procedure performs following tasks:
    % 
    % # Checks installation of CC4M
    % # Checks availablity of Python within MATLAB
    % # Create Python envoronment in CC4M subfolder of the default USERPATH folder
    % # 
    % Syntax:
    %
    %   install_git_hooks()
    %
    % In case shipped Python code for the matlabengine shall be installed, instead of the package on PyPi.org use:
    %
    %   install_git_hooks(usePPI=false) 

    % Copyright 2026 MonkeyProof Solutions BV

    arguments (Input)
        % usePPI (true/false) When true (default), matlabengine is installed from PyPi, otherwise installed from MATLAB
        % installation.
        usePPI logical = true
    end

    % Define locations.
    [~, versionInfo] = monkeyproof.cc4m.utils.getEnvironmentInfo();
    targetDir        = fullfile(userpath, 'cc4m', 'python', versionInfo.MATLABVersionNr);
    activateCall     = fullfile(targetDir, 'Scripts', 'activate');
    [~, ~]           = mkdir(targetDir);
    pythonDir        = fullfile(pwd, '..', 'cc4m_githooks');

    % Make sure CC4M is installed
    if isempty(ver('cc4m'))
        error("GITHOOKS:INSTALL:NO_CC4M", "CC4M not installed.\n")
    elseif verLessThan('cc4m', '2.21')
        error("GITHOOKS:INSTALL:CC4M_TO_OLD", "Could not install the CC4M integration:\n")
    else
        disp('CC4M available')
    end

    % Make sure Python environment available.
    disp("Checking if Python is available.")
    pe = pyenv();

    if isempty(pe.Version)
        % No Python available.
        hasFailed = true;
        disp("No Python is available.")
        msg = "No Python installed or available via MATLAB.";
    else
        % Python found.

        fprintf(1, "Python %s found.", pe.Version);
        pyCmd = pe.Executable;

        % Test if environment already exists.
        pipCommand = "" + activateCall  + " && " + "pip list";
        [hasFailed, msg] = system(pipCommand);

        if hasFailed
            % No environment yet.
            disp("Installing Python environment.")

            % Create venv.
            pipCommand = "cd """ + targetDir  + """ && " + pyCmd + " -m venv """ + targetDir + """ && " + activateCall;

            % Install the engine.
            if usePPI
                % From Python Package Index.
                pipCommand = pipCommand + ...
                    " && " + "pip install matlabengine>=" + versionInfo.MATLABVersionNr;
            else
                % From local files.
                pipCommand = pipCommand + ...
                    " && " + "cd """ + fullfile(matlabroot, 'extern', 'engines', 'python') + """" + ...
                    " && " + "python setup.py build --build-base=""" + targetDir + """"; % --build-base=""" + targetDir + """
            end

            [hasFailed, msg] = system(pipCommand);
        end
    end

    % Install Python - Git integration files.
    if ~hasFailed
        disp("MATLAB engine installed. Now adding CC4M integration.")

        pipCommand = activateCall  + " && " + "pip install " +pythonDir;
        [hasFailed, msg] = system(pipCommand);

        if hasFailed
            error("GITHOOKS:INSTALL:NO_CC4M_GITHOOKS", "Could not install the CC4M integration:\n\n  %s\n", msg)
        else
            disp("CC4M integration installed.")

            pipCommand = "" + activateCall  + " && " + "pip list";
            [hasFailed, msg] = system(pipCommand);
        end
    else
        error("GITHOOKS:INSTALL:NO_ENGINE", "Could not install the matlabengine:\n\n  %s\n", msg)
    end

    % Install Required MATLAB files in the default userpath.
    disp("Now adding CC4M MATLAB code.")
    destFolder = monkeyproof.cc4m.utils.userpath();
    [isOk, msg] = copyfile('precommit_example.m', destFolder, 'f');


    for iOut = 1:nargout
        switch iOut
            
            case 1
                varargout{1} = isOk;

            case 2
                varargout{2} = msg;

        end
    end

end