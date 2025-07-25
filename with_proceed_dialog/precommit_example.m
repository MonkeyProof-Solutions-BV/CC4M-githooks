function precommit_example(filestring, configFile, severityBoundary, doOpenReport, isVerbose)
    % PRECOMMIT_EXAMPLE The MATLAB side of the GIT pre-commit hook example
    %
    % Requires CC4M >= v2.18.2
    %
    % Inputs - required:
    %  
    % * filestring       (char)      Comma-separated list of all the files to be checked.
    %
    % Inputs - optional
    % * configFile       (char)      (File)name of CC4M configuration (default: 'MonkeyProofMATLABCodingStandard')
    % * severityBoundary (double)    Lowest severity that blocks a commit (default:3)   
    % * doOpenReport     (boolean)   If true (default), opens a the HTML report of the detected violations.
    % * isVerbose        (boolean)   If true (default), shows some more information in the shell.

    % Copyright 2025 Monkeyproof Solutions BV

    arguments
        filestring                  char
        configFile                  char        = 'MonkeyProofMATLABCodingStandard'
        severityBoundary    (1,1)   double      = 3
        doOpenReport        (1,1)   logical     = true
        isVerbose           (1,1)   logical     = true
    end

    clc
    files = strsplit(filestring, ',');

    [cc4mReportUrl, cc4mSummary] = monkeyproof.cc4m.start(...
        'file',             files, ...
        'configFile',       configFile, ...
        'runSeverities',    severityBoundary);

    %% When to fail
    % HERE define when to fail for this repository

    failCondition = cc4mSummary.Results.NrViolations > 0;               % violations found
    
    if isVerbose
        disp(cc4mReportUrl)
        disp(cc4mSummary.Results)
    end

    if failCondition

        if doOpenReport
            % Make sure files analysed are on the path in order to make the links from the report work.

            folders = {}; % cell array with project path

            % Command to adapt the path.
            addpathCmd = ['addpath(''', strjoin(folders, ''', '''), ''')'];

            % Start new matlab session to open the report - a new session is 
            % used so that commit action can be finished immediately.
            system(['matlab -r ',  addpathCmd ',web(''' cc4mReportUrl ''') &']);
        end

        % 
        drawnow()
        answer = questdlg('One or more coding guideline violations have been found in the staged files. Do you want to proceed with the commit anyway?','Violations Detected – Proceed with Commit?');
        switch answer
        
            case 'Yes'
                disp('Warning: Coding guideline violations were found, but the commit proceeded due to override.')
                exit(0)
            otherwise
                exit(1)
        end
                  
    else
        exit(0)
    end
end