function flag = is_normalized(psi, tol)
% IS_NORMALIZED  Check normalization of a quantum state vector.
%
% Objective:
%   Verify whether a state vector satisfies:
%
%       psi' * psi = 1
%
%   within a specified numerical tolerance.
%
% Input:
%   psi - numeric state vector (row or column)
%   tol - numerical tolerance (optional, default = 1e-12)
%
% Output:
%   flag - logical value (true if normalized)
%
% Notes:
%   This function is intended for validation and diagnostics.
%
%   The check is performed using:
%
%       |psi' * psi - 1|
%
%   which should be close to zero for a normalized state.

    % =========================
    % Robustness checks
    % =========================

    if nargin < 1
        error('is_normalized:InvalidNumInputs', ...
            'At least one input argument (psi) is required.');
    end

    if nargin < 2
        tol = 1e-12;
    end

    if ~isnumeric(psi) || ~isvector(psi)
        error('is_normalized:InvalidType', ...
            'psi must be a numeric vector.');
    end

    
    % =========================
    % Main computation
    % =========================

    psi = psi(:);

    norm_sq = psi' * psi;
    err = abs(norm_sq - 1);

    flag = (err < tol);

end