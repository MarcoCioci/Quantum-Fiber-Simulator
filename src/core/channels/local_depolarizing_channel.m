function rho_out = local_depolarizing_channel(rho_in, p)
% LOCAL_DEPOLARIZING_CHANNEL  Apply local isotropic depolarization to one qubit.
%
% Objective:
%   Apply the single-qubit depolarizing channel D_p to a 2x2 density
%   operator ρ.
%
% Input:
%   rho_in - 2x2 single-qubit density matrix
%   p      - depolarization parameter, with 0 <= p <= 1
%
% Output:
%   rho_out - 2x2 depolarized density matrix
%
% Notes:
%   The channel follows the Bloch-vector contraction convention:
%
%       ρ = 1/2 (I + r · σ)
%       D_p(ρ) = 1/2 (I + (1-p) r · σ)
%
%   Hence:
%       p = 0  -> identity channel
%       p = 1  -> maximally mixed state I/2
%
%   This function acts on a single qubit only. Two-arm depolarization on a
%   bipartite state is implemented separately.

    % =========================
    % Robustness checks
    % =========================

    if nargin ~= 2
        error('local_depolarizing_channel:InvalidNumInputs', ...
              'Expected 2 input arguments: rho_in and p.');
    end

    if ~isnumeric(rho_in)
        error('local_depolarizing_channel:InvalidType', ...
              'rho_in must be numeric.');
    end

    if ~isequal(size(rho_in), [2, 2])
        error('local_depolarizing_channel:InvalidSize', ...
              'rho_in must be a 2x2 matrix.');
    end

    tol = 1e-12;

    if norm(rho_in - rho_in', 'fro') > tol
        error('local_depolarizing_channel:NonHermitianInput', ...
              'rho_in must be Hermitian within numerical tolerance.');
    end

    if abs(trace(rho_in) - 1) > tol
        error('local_depolarizing_channel:InvalidTrace', ...
              'rho_in must have trace equal to 1 within numerical tolerance.');
    end

    eigvals = eig((rho_in + rho_in') / 2);
    if min(real(eigvals)) < -tol
        error('local_depolarizing_channel:NonPositiveInput', ...
              'rho_in must be positive semidefinite within numerical tolerance.');
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

    rho_out = (1-p) * rho_in + p * eye(2,2) / 2;
    
    % Numerical Clean-Up:
    rho_out = (rho_out + rho_out') / 2;

end