function X_out = composite_fiber_channel(X, theta, p_A, p_B)
% COMPOSITE_FIBER_CHANNEL  Apply phase evolution and two-arm depolarization.
%
% Objective:
%   Apply the deterministic composite fiber operator map:
%
%       X_out = (D_pA ⊗ D_pB)[U_θ X U_θ†]
%
%   where U_θ is the reduced phase unitary and D_pA, D_pB are local
%   depolarizing maps acting on arms A and B.
%
% Input:
%   X     - 4x4 bipartite two-qubit operator or density matrix
%   theta - relative phase parameter
%   p_A   - depolarization parameter on subsystem A, with 0 <= p_A <= 1
%   p_B   - depolarization parameter on subsystem B, with 0 <= p_B <= 1
%
% Output:
%   X_out - 4x4 output operator after composite fiber evolution
%
% Notes:
%   The model combines:
%       - coherent phase evolution
%       - local incoherent depolarization
%
%   The function is written as an operator map. Therefore, X is not required
%   to be a normalized density matrix.
%
%   If X is a valid density matrix, then X_out is also a valid density
%   matrix within numerical precision.
%
%   Under the isotropic depolarizing approximation, the two effects commute.
%   Here the phase evolution is applied first for physical readability.

    % =========================
    % Robustness checks
    % =========================

    if nargin ~= 4
        error('composite_fiber_channel:InvalidNumInputs', ...
              'Expected 4 input arguments: X, theta, p_A, p_B.');
    end

    if ~isnumeric(X)
        error('composite_fiber_channel:InvalidType', ...
              'X must be numeric.');
    end

    if ~isequal(size(X), [4, 4])
        error('composite_fiber_channel:InvalidSize', ...
              'X must be a 4x4 matrix.');
    end

    if any(~isfinite(X), 'all')
        error('composite_fiber_channel:InvalidValues', ...
              'X must contain only finite values.');
    end

    if ~isnumeric(theta) || ~isscalar(theta) || ~isreal(theta) || ~isfinite(theta)
        error('composite_fiber_channel:InvalidTheta', ...
              'theta must be a finite real numeric scalar.');
    end

    if ~isnumeric(p_A) || ~isscalar(p_A) || ~isreal(p_A) || ~isfinite(p_A)
        error('composite_fiber_channel:InvalidParameterA', ...
              'p_A must be a finite real numeric scalar.');
    end

    if ~isnumeric(p_B) || ~isscalar(p_B) || ~isreal(p_B) || ~isfinite(p_B)
        error('composite_fiber_channel:InvalidParameterB', ...
              'p_B must be a finite real numeric scalar.');
    end

    if p_A < 0 || p_A > 1
        error('composite_fiber_channel:InvalidRangeA', ...
              'p_A must satisfy 0 <= p_A <= 1.');
    end

    if p_B < 0 || p_B > 1
        error('composite_fiber_channel:InvalidRangeB', ...
              'p_B must satisfy 0 <= p_B <= 1.');
    end


    % =========================
    % Main computation
    % =========================

    U_A = phase_unitary(theta);
    U_theta = tensor_product(U_A, eye(2,2));    % U_theta = U_A ⊗ I

    % Phase Evolution:
    X_phase = U_theta * X * U_theta';

    % Local two-arm depolarization:
    X_out = two_arm_depolarizing_channel(X_phase, p_A, p_B);

end