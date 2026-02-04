function exitFlag = precommit_example(filestring, configFile, options)
    % PRECOMMIT_EXAMPLE The MATLAB side of the Git pre-commit hook example.
    %
    % Requires CC4M >= v2.21
    %
    % Inputs - required:
    %
    % * filestring       (char)      Comma-separated list of all the files to be checked.
    %
    % Inputs - optional
    % * configFile       (char)      (File)name of CC4M configuration (default: 'MonkeyProofMATLABCodingStandard').
    %
    % Inputs - named
    % * SeverityBlock    (double)    Lowest severity that blocks a commit (default:1).
    % * SeverityAllow    (double)    Lowest severity that can block a commit (default:8).
    % * DoOpenReport     (boolean)   If true (default), opens a the HTML report of the detected violations.
    % * IsVerbose        (boolean)   If true (default), shows some more information in the shell.

    % Copyright 2026 MonkeyProof Solutions BV

    arguments
        filestring                  char
        configFile                  char                 = 'MonkeyProofMATLABCodingStandard'
        options.SeverityBlock       (1, 1)   double      = 1
        options.SeverityAllow       (1, 1)   double      = 8
        options.DoOpenReport        (1, 1)   logical     = true
        options.OpenReportInMatlab  (1, 1)   logical     = true
        options.IsVerbose           (1, 1)   logical     = true
        options.ChangedOnlyScope    (1, 1)   string      = "line"
    end

    try
        exitFlag = 1; %#ok<NASGU> initialize
        files    = strsplit(filestring, ',');

        % run CC4M
        [cc4mReportUrl, cc4mSummary] = monkeyproof.cc4m.start(...
            'file',             files, ...
            'configFile',       configFile, ...
            '-changedOnly', ...
            '-doNotOpenReport', ...
            'runSeverities',    options.SeverityAllow, ...
            'changedOnlyScope', char(options.ChangedOnlyScope));

        %% When to block or fail.
        % Here define when to fail for this repository.
        AllowCondition = cc4mSummary.Results.NrViolations > 0;

        if AllowCondition
            BlockCondition = any([cc4mSummary.Results.PerCheck.SeverityLevel] <= options.SeverityBlock);
        else
            BlockCondition = false;
        end

        if options.IsVerbose
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

            if options.DoOpenReport
                if options.OpenReportInMatlab
                    % TODO: Make sure files analyzed are on the path in order to make the links from the report work.

                    folders = {}; %#ok<NASGU> % TODO: Cell array with project path.

                    web(cc4mReportUrl);
                else
                    web(cc4mReportUrl,  '-browser');
                end
            end
        end
    catch ME
        disp (ME.message)
        disp ("---------------------------------------------------------")
        disp (ME.getReport())
        disp ("---------------------------------------------------------")
        exitFlag = 10;
    end
end