function E_F = compute_entanglement_of_formation(rho)
% COMPUTE_ENTANGLEMENT_OF_FORMATION  Compute two-qubit entanglement of formation.
%
% Objective:
%   Evaluate the entanglement of formation
%
%       E_F(ρ) = h((1 + sqrt(1 - C(ρ)^2))/2)
%
%   where C(ρ) is the two-qubit concurrence and h(x) is the binary entropy.
%
% Input:
%   rho - 4x4 two-qubit density matrix
%
% Output:
%   E_F - entanglement of formation in [0,1]

    % =========================
    % Robustness checks
    % =========================

    if nargin ~= 1
        error('compute_entanglement_of_formation:InvalidNumInputs', ...
              'Expected 1 input argument.');
    end

    if ~isnumeric(rho) || ~isequal(size(rho), [4, 4])
        error('compute_entanglement_of_formation:InvalidInputSize', ...
              'rho must be a numeric 4x4 matrix.');
    end


    % =========================
    % Main computation
    % =========================

    C = compute_concurrence(rho);

    % Clamp concurrence to avoid sqrt(negative) from roundoff.
    C = min(max(real(C), 0), 1);

    entropy_argument = (1 + sqrt(1 - C^2)) / 2;

    E_F = binary_entropy(entropy_argument);

    % Remove tiny numerical excursions outside the physical interval.
    E_F = min(max(real(E_F), 0), 1);

end


function h = binary_entropy(x)
% BINARY_ENTROPY  Compute binary entropy using base-2 logarithms.

    x = min(max(real(x), 0), 1);

    if x == 0 || x == 1
        h = 0;
    else
        h = -x * log2(x) - (1 - x) * log2(1 - x);
    end

end