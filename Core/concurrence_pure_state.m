function C = concurrence_pure_state(psi)
% CONCURRENCE_PURE_STATE  Compute the concurrence of a normalized pure two-qubit state.
%
% Objective:
%   Given a pure two-qubit state vector
%
%       |psi> = a|00> + b|01> + c|10> + d|11>,
%
%   compute the concurrence using the closed-form expression
%
%       C = 2 * |a*d - b*c|.
%
%   This is the natural first implementation for Chapter 4.4 because it
%   directly covers the Bell state and the phase-evolved Bell-like state,
%   and provides the reference result before introducing the mixed-state
%   density-matrix formalism.
%
% Input:
%   psi - 4x1 complex column vector representing a normalized pure two-qubit
%         state in the computational basis:
%
%         {|00>, |01>, |10>, |11>}
%
% Output:
%   C   - concurrence value, expected to satisfy 0 <= C <= 1 up to small
%         numerical tolerance.
%
% Notes:
%   Assumptions:
%   - The input state must represent a pure two-qubit state.
%   - The state must be normalized.
%
%   Context in simulator:
%   - Bell states should give C = 1.
%   - The state (|01> + exp(i*theta)|10>)/sqrt(2) should also give C = 1
%     for every theta.
%   - Product states should give C = 0.

    % =========================
    % Robustness checks
    % =========================

    if nargin < 1
        error('concurrence_pure_state:InvalidNumInputs', ...
              'Expected 1 input argument.');
    end

    if ~isnumeric(psi)
        error('concurrence_pure_state:InvalidType', ...
              'psi must be numeric.');
    end

    if ~isvector(psi)
        error('concurrence_pure_state:InvalidShape', ...
              'psi must be a vector.');
    end

    if numel(psi) ~= 4
        error('concurrence_pure_state:InvalidSize', ...
              'psi must contain exactly 4 elements for a two-qubit pure state.');
    end

    if size(psi,2) ~= 1
        error('concurrence_pure_state:InvalidOrientation', ...
              'psi must be provided as a 4x1 column vector.');
    end

    if any(~isfinite(real(psi))) || any(~isfinite(imag(psi)))
        error('concurrence_pure_state:InvalidEntries', ...
              'psi must contain only finite entries.');
    end

    norm_psi = norm(psi);

    if norm_psi == 0
        error('concurrence_pure_state:ZeroVector', ...
              'psi must not be the zero vector.');
    end

    tolerance = 1e-12;

    if abs(norm_psi - 1) > tolerance
        error('concurrence_pure_state:NonNormalizedState', ...
              'psi must be normalized to unit norm within tolerance.');
    end


    % =========================
    % Main computation
    % =========================

    a = psi(1);
    b = psi(2);
    c = psi(3);
    d = psi(4);

    C = 2 * abs(a*d - b*c);

    % Guard against tiny numerical drift outside [0, 1]
    tolerance = 1e-12;

    if C > 1 + tolerance
        error('concurrence_pure_state:InvalidConcurrenceValue', ...
              'Computed concurrence lies outside the admissible range [0, 1].');
    else
        C = min(max(C, 0), 1);
    end
end
