function tau = compute_tangle(rho)
% COMPUTE_TANGLE  Compute the two-qubit tangle τ from concurrence.
%
% Objective:
%   Evaluate the tangle
%
%       τ(ρ) = C(ρ)^2
%
%   where C(ρ) is the two-qubit concurrence.
%
% Input:
%   rho - 4x4 two-qubit density matrix
%
% Output:
%   tau - tangle value in [0,1]

    % =========================
    % Robustness checks
    % =========================

    if nargin ~= 1
        error('compute_tangle:InvalidNumInputs', ...
              'Expected 1 input argument.');
    end

    if ~isnumeric(rho) || ~isequal(size(rho), [4, 4])
        error('compute_tangle:InvalidInputSize', ...
              'rho must be a numeric 4x4 matrix.');
    end


    % =========================
    % Main computation
    % =========================

    C = compute_concurrence(rho);

    tau = C^2;

    % Remove tiny numerical excursions outside the physical interval.
    tau = min(max(real(tau), 0), 1);

end