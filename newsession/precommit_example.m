function precommit_example(filestring, configFile, severityBoundary, doOpenReport, isVerbose)
    % PRECOMMIT_EXAMPLE The MATLAB side of the Git pre-commit hook example
    %
    % Requires CC4M >= v2.18.2
    %
    % Inputs - required:
    %  
    % * filestring       (char)      Comma-separated list of all the files to be checked.
    %
    % Inputs - optional
    % * configFile       (char)      (File)name of CC4M configuration (default: 'MonkeyProofMATLABCodingStandard').
    % * severityBoundary (double)    Lowest severity that blocks a commit (default:3).
    % * doOpenReport     (boolean)   If true (default), opens a the HTML report of the detected violations.
    % * isVerbose        (boolean)   If true (default), shows some more information in the shell.

    % Copyright 2025 MonkeyProof Solutions BV

    arguments
        filestring                   char
        configFile                   char        = 'MonkeyProofMATLABCodingStandard'
        severityBoundary    (1, 1)   double      = 3
        doOpenReport        (1, 1)   logical     = true
        isVerbose           (1, 1)   logical     = true
    end

    files = strsplit(filestring, ',');

    [cc4mReportUrl, cc4mSummary] = monkeyproof.cc4m.start(...
        'file',             files, ...
        'configFile',       configFile, ...
        'runSeverities',    severityBoundary);

    %% When to fail
    % Here define when to fail for this repository.

    failCondition = cc4mSummary.Results.NrViolations > 0;               % violations found

    if isVerbose
        disp(cc4mReportUrl)
        disp(cc4mSummary.Results)
    end

    if failCondition

        if doOpenReport
            % Make sure files analysed are on the path in order to make the links from the report work.

            folders = {}; % Cell array with project path.

            % Command to adapt the path.
            addpathCmd = ['addpath(''', strjoin(folders, ''', '''), ''')'];

            % Start new matlab session to open the report - a new session is 
            % used so that commit action can be finished immediately.
            system(['matlab -r ',  addpathCmd, ',web(''', cc4mReportUrl, ''') &']);
        end

        exit(1)
    else
        exit(0)
    end
end
