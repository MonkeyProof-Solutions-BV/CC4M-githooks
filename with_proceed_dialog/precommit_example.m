function precommit_example(filestring, configFile, options)
    % PRECOMMIT_EXAMPLE The MATLAB side of the GIT pre-commit hook example
    %
    % Requires CC4M >= v2.18.2
    %
    % Inputs - required:
    %
    % * filestring       (char)      Comma-separated list of all the files to be checked.
    % * configFile       (char)      Optional: (File)name of CC4M configuration
    %                                default: 'MonkeyProofMATLABCodingStandard'
    %
    % Inputs - named arguments
    %
    % * severityBlock    (double)    Lowest severity that blocks a commit (default:3)
    % * severityAllow    (double)    Lowest severity that reports violations, but allows to proceed (default:8)
    % * doOpenReport     (boolean)   If true (default), opens a the HTML report of the detected violations.
    % * isVerbose        (boolean)   If true (default), shows some more information in the shell.

    % Copyright 2025 MonkeyProof Solutions BV

    arguments
        filestring                  char
        configFile                  char                 = 'MonkeyProofMATLABCodingStandard'
        options.SeverityBlock       (1, 1)   double      = 3
        options.SeverityAllow       (1, 1)   double      = 8
        options.DoOpenReport        (1, 1)   logical     = true
        options.OpenReportInMatlab  (1, 1)   logical     = false
        options.IsVerbose           (1, 1)   logical     = true
    end

    clc %@ok<AVFUN-STAT-27> clean startup info
    files = strsplit(filestring, ',');

    [cc4mReportUrl, cc4mSummary] = monkeyproof.cc4m.start(...
        'file',             files, ...
        'configFile',       configFile, ...
        'runSeverities',    options.SeverityAllow);

    %% When to fail.
    % Here define when to fail for this repository.
    AllowCondition = cc4mSummary.Results.NrViolations > 0;
    BlockCondition = any([cc4mSummary.Results.PerCheck.SeverityLevel]) > options.SeverityBlock;

    if options.IsVerbose
        disp(cc4mReportUrl)
        disp(cc4mSummary.Results)
    else
        % Do not display anything.
    end

    if ~BlockCondition && ~AllowCondition
        % All fine.
        exitFlag = 0;
    else
        % If violations are found - potentially open the report.
        if options.DoOpenReport
            % Make sure files analyzed are on the path in order to make the links from the report work.

            if options.OpenReportInMatlab
                folders = localGetPathFolders(files); % Cell array with project path.

                % Command to adapt the path.
                addpathCmd = ['addpath(''', strjoin(folders, ''', '''), ''')'];

                % Start new matlab session to open the report - a new session is
                % used so that commit action can be finished immediately.
                system(['matlab -r ', addpathCmd, ',web(''', cc4mReportUrl, ''') &']);
            else
                web(cc4mReportUrl,  '-browser');
            end
        else
            % Do not open report.
        end

        if BlockCondition
            % Errors found.
            exitFlag = 1;
        else
            % AllowCondition == true
            drawnow()
            answer = questdlg([ ...
                'One or more coding guideline violations have been found in the staged files. ', ...
                'Do you want to proceed with the commit anyway?'...
                ], ...
                'Violations Detected – Proceed with Commit?');

            switch answer

                case 'Yes'
                    disp('Warning: Coding guideline violations were found, but the commit proceeded due to override.')
                    exitFlag = 0;

                otherwise
                    exitFlag = 1;
            end

        end
    end

    exit(exitFlag)
end


function folders = localGetPathFolders(files) %#ok<INUSD>
    folders = {};
end
