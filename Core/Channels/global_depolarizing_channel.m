function rho_out = global_depolarizing_channel(rho, p)
% GLOBAL_DEPOLARIZING_CHANNEL  Apply a global isotropic depolarizing channel.
%
% Objective:
%   Apply the global depolarizing map to a density matrix ρ:
%
%       ρ_out = (1 - p) * ρ + (p / d) * I_d
%
%   where d is the Hilbert-space dimension of ρ.
%
% Input:
%   rho - dxd complex density matrix representing a quantum state
%   p   - real scalar depolarization parameter, with 0 <= p <= 1
%
% Output:
%   rho_out - dxd complex density matrix after global depolarization
%
% Notes:
%   This function acts on the full density matrix as a single global system.
%   For a two-qubit state, d = 4 and the map becomes:
%
%       ρ_out = (1 - p) * ρ + (p / 4) * I_4
%
%   This is not the same as applying independent local depolarizing channels
%   to subsystems A and B.

    % =========================
    % Robustness checks
    % =========================

    if nargin ~= 2
        error('global_depolarizing_channel:InvalidNumInputs', ...
              'Expected exactly 2 input arguments: rho and p.');
    end

    if ~isnumeric(rho)
        error('global_depolarizing_channel:InvalidType', ...
              'rho must be a numeric matrix.');
    end

    if isempty(rho)
        error('global_depolarizing_channel:EmptyInput', ...
              'rho must not be empty.');
    end

    if ~ismatrix(rho)
        error('global_depolarizing_channel:InvalidDimensions', ...
              'rho must be a 2-D matrix.');
    end

    [num_rows, num_cols] = size(rho);

    if num_rows ~= num_cols
        error('global_depolarizing_channel:InvalidSize', ...
              'rho must be a square density matrix.');
    end

    if any(~isfinite(rho), 'all')
        error('global_depolarizing_channel:InvalidValuesRho', ...
              'rho must not contain NaN or Inf values.');
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

    if norm(rho - rho', 'fro') > tolerance
        error('global_depolarizing_channel:NonHermitianInput', ...
              'rho must be Hermitian within numerical tolerance.');
    end

    if abs(trace(rho) - 1) > tolerance
        error('global_depolarizing_channel:InvalidTrace', ...
              'rho must have trace equal to 1 within numerical tolerance.');
    end


    % =========================
    % Main computation
    % =========================

    d = num_rows;
    I_d = eye(d, d, 'like', rho);

    rho_out = (1 - p) * rho + (p / d) * I_d;

    % Remove small numerical anti-Hermitian residues.
    rho_out = (rho_out + rho_out') / 2;

end