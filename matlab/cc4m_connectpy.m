function name = cc4m_connectpy()
    % CONNECT undefined
    %   undefined

    if ~matlab.engine.isEngineShared()
        matlab.engine.shareEngine("CC4M_MATLAB_SESSION")
    else
        % ok
    end

    name = matlab.engine.engineName;
end