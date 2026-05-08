function flag = is_normalized(psi, tolerance)
% IS_NORMALIZED  Check normalization of a quantum state vector.
%
% Objective:
%   Verify whether a state vector satisfies:
%
%       ⟨ψ|ψ⟩ = 1
%
%   within a specified numerical tolerance.
%
% Input:
%   psi - numeric column vector representing a quantum state ket |ψ⟩
%         of dimension 2^n x 1
%
%   tolerance - numerical tolerance (optional, default = 1e-12)
%
% Output:
%   flag - logical value (true if normalized)
%
% Notes:
%   This function enforces the ket convention:
%
%       ψ must be a column vector (2^n x 1)
%
%   Row vectors are NOT accepted, since they may represent bras ⟨ψ|.
%
%   The check is performed using:
%
%       |⟨ψ|ψ⟩ - 1|
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
        tolerance = 1e-12;
    end

    if ~isnumeric(psi)
        error('is_normalized:InvalidType', ...
            'psi must be numeric.');
    end

    if ~isvector(psi)
        error('is_normalized:InvalidShape', ...
            'psi must be a vector.');
    end

    if size(psi,2) ~= 1
        error('is_normalized:InvalidKetShape', ...
            'psi must be a column vector (2^n x 1). Row vectors are not accepted.');
    end

    dim = size(psi,1);

    if dim < 2 || abs(log2(dim) - round(log2(dim))) > 1e-12
        error('is_normalized:InvalidDimension', ...
            'Dimension of psi must be a power of 2.');
    end


    % =========================
    % Main computation
    % =========================

    norm_sq = psi' * psi;

    err = abs(norm_sq - 1);

    flag = (err < tolerance);

end