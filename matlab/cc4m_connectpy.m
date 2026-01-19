function name = cc4m_connectpy()
    % CC4M_CONNECTPY shared the MATLAB engine and returns the engine name.
    %
    % If the returned name is "CC4M_MATLAB_SESSION", this MATLAB session will be used by the CC4M Git hooks.

    % Copyright 2026 MonkeyProof Solutions BV

    if ~matlab.engine.isEngineShared()
        matlab.engine.shareEngine("CC4M_MATLAB_SESSION")
    else
        % ok
    end

    name = matlab.engine.engineName;
end