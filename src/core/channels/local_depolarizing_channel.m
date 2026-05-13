function X_out = local_depolarizing_channel(X, p)
% LOCAL_DEPOLARIZING_CHANNEL  Apply local isotropic depolarization to one qubit.
%
% Objective:
%   Apply the single-qubit depolarizing operator map D_p to a 2x2
%   single-qubit operator X.
%
% Input:
%   X - 2x2 single-qubit operator or density matrix
%   p - depolarization parameter, with 0 <= p <= 1
%
% Output:
%   X_out - 2x2 depolarized operator
%
% Notes:
%   The channel follows the operator-map convention:
%
%       D_p(X) = (1-p) X + p (I_2/2) Tr(X)
%
%   For a normalized density matrix ρ, this reduces to:
%
%       D_p(ρ) = (1-p)ρ + p I_2/2
%
%   In Bloch-vector form:
%
%       ρ = 1/2 (I + r · σ)
%       D_p(ρ) = 1/2 (I + (1-p) r · σ)
%
%   Hence:
%       p = 0  -> identity channel
%       p = 1  -> complete depolarization
%
%   This function acts on a single qubit only. Two-arm depolarization on a
%   bipartite state is implemented separately.

    % =========================
    % Robustness checks
    % =========================

    if nargin ~= 2
        error('local_depolarizing_channel:InvalidNumInputs', ...
              'Expected 2 input arguments: X and p.');
    end

    if ~isnumeric(X)
        error('local_depolarizing_channel:InvalidType', ...
              'X must be numeric.');
    end

    if ~isequal(size(X), [2, 2])
        error('local_depolarizing_channel:InvalidSize', ...
              'X must be a 2x2 matrix.');
    end

    tol = 1e-12;

    if norm(X - X', 'fro') > tol
        error('local_depolarizing_channel:NonHermitianInput', ...
              'X must be Hermitian within numerical tolerance.');
    end

    if ~isnumeric(p) || ~isscalar(p) || ~isreal(p)
        error('local_depolarizing_channel:InvalidParameterType', ...
              'p must be a real numeric scalar.');
    end

    if p < 0 || p > 1
        error('local_depolarizing_channel:InvalidParameterRange', ...
              'p must satisfy 0 <= p <= 1.');
    end


    % =========================
    % Main computation
    % =========================

    I2 = eye(2, 'like', X);

    X_out = (1-p) * X + p * (I2 / 2) * trace(X);

    % Numerical clean-up
    X_out = (X_out + X_out') / 2;

end