function X_out = global_depolarizing_channel(X, p)
% GLOBAL_DEPOLARIZING_CHANNEL  Apply a global isotropic depolarizing channel.
%
% Objective:
%   Apply the global depolarizing operator map D_p to a dxd operator X:
%
%       D_p(X) = (1 - p) X + p (I_d / d) Tr(X)
%
%   where d is the Hilbert-space dimension.
%
% Input:
%   X - dxd complex operator or density matrix
%   p - real scalar depolarization parameter, with 0 <= p <= 1
%
% Output:
%   X_out - dxd globally depolarized operator
%
% Notes:
%   This function acts on the full operator space as a single global system.
%
%   For a normalized density matrix ρ, the map reduces to:
%
%       ρ_out = (1 - p) ρ + (p / d) I_d
%
%   For a two-qubit density matrix, d = 4:
%
%       ρ_out = (1 - p) ρ + (p / 4) I_4
%
%   This is not equivalent to applying independent local depolarizing
%   channels to subsystems A and B.

    % =========================
    % Robustness checks
    % =========================

    if nargin ~= 2
        error('global_depolarizing_channel:InvalidNumInputs', ...
              'Expected exactly 2 input arguments: X and p.');
    end

    if ~isnumeric(X)
        error('global_depolarizing_channel:InvalidType', ...
              'X must be a numeric matrix.');
    end

    if isempty(X)
        error('global_depolarizing_channel:EmptyInput', ...
              'X must not be empty.');
    end

    if ~ismatrix(X)
        error('global_depolarizing_channel:InvalidDimensions', ...
              'X must be a 2-D matrix.');
    end

    [num_rows, num_cols] = size(X);

    if num_rows ~= num_cols
        error('global_depolarizing_channel:InvalidSize', ...
              'X must be a square matrix.');
    end

    if any(~isfinite(X), 'all')
        error('global_depolarizing_channel:InvalidValuesX', ...
              'X must not contain NaN or Inf values.');
    end

    if ~isnumeric(p) || ~isscalar(p) || ~isreal(p)
        error('global_depolarizing_channel:InvalidParameter', ...
              'p must be a real numeric scalar.');
    end

    if ~isfinite(p)
        error('global_depolarizing_channel:InvalidValueP', ...
              'p must not be NaN or Inf.');
    end

    if p < 0 || p > 1
        error('global_depolarizing_channel:InvalidRange', ...
              'p must satisfy 0 <= p <= 1.');
    end

    tolerance = 1e-12;

    if norm(X - X', 'fro') > tolerance
        error('global_depolarizing_channel:NonHermitianInput', ...
              'X must be Hermitian within numerical tolerance.');
    end


    % =========================
    % Main computation
    % =========================

    d = num_rows;
    I_d = eye(d, d, 'like', X);

    X_out = (1 - p) * X + p * (I_d / d) * trace(X);

    % Remove small numerical anti-Hermitian residues.
    X_out = (X_out + X_out') / 2;

end