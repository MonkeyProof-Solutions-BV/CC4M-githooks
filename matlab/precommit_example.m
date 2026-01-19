function exitFlag = precommit_example(filestring, configFile, options)
    % PRECOMMIT_EXAMPLE The MATLAB side of the Git pre-commit hook example.
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

    % Copyright 2026 MonkeyProof Solutions BV

    arguments
        filestring                  char
        configFile                  char                 = 'MonkeyProofMATLABCodingStandard'
        options.SeverityBlock       (1, 1)   double      = 1
        options.SeverityAllow       (1, 1)   double      = 8
        options.DoOpenReport        (1, 1)   logical     = true
        options.OpenReportInMatlab  (1, 1)   logical     = false
        options.IsVerbose           (1, 1)   logical     = true
    end

    exitFlag = 1; %#ok<NASGU> initialize
    files    = strsplit(filestring, ',');

    % run CC4M
    [cc4mReportUrl, cc4mSummary] = monkeyproof.cc4m.start(...
        'file',             files, ...
        'configFile',       configFile, ...
        'runSeverities',    severityBoundary);

    %% When to block or fail.
    % Here define when to fail for this repository.
    AllowCondition = cc4mSummary.Results.NrViolations > 0;
    BlockCondition = any([cc4mSummary.Results.PerCheck.SeverityLevel]) > options.SeverityBlock;

    if isVerbose
        disp(cc4mReportUrl)
        disp(cc4mSummary.Results)
    end

    if ~BlockCondition && ~AllowCondition
        % All fine.
        exitFlag = 0;
    else

        if BlockCondition
            % Errors found.
            exitFlag = 1;
        else
            % AllowCondition == true
            exitFlag = 2;
        end

        if doOpenReport
            if options.OpenReportInMatlab
                % TODO: Make sure files analyzed are on the path in order to make the links from the report work.

                folders = {}; %#ok<NASGU> % TODO: Cell array with project path.
                % Command to adapt the path.
                %addpathCmd = ['addpath(''', strjoin(folders, ''', '''), ''')'];

                web(cc4mReportUrl);
            else
                web(cc4mReportUrl,  '-browser');
            end
        end
        
    end
end