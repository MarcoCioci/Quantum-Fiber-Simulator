function rho_A = partial_trace_B(rho_AB)
% PARTIAL_TRACE_B  Trace out subsystem B from a two-qubit density matrix.
%
% Objective:
%   Compute the reduced density operator of subsystem A from the bipartite
%   density matrix ρ_AB by performing the partial trace over subsystem B.
%
% Input:
%   rho_AB - 4x4 bipartite density matrix representing a two-qubit state
%            in the computational basis:
%            {|00⟩, |01⟩, |10⟩, |11⟩}
%
% Output:
%   rho_A  - 2x2 reduced density matrix of subsystem A
%
% Notes:
%   The function assumes a two-qubit system with basis ordering:
%       |00⟩, |01⟩, |10⟩, |11⟩
%   so that:
%       ρ_A = Tr_B(ρ_AB)
%
%   This operation extracts the local state of subsystem A from the global
%   bipartite state.

    % =========================
    % Robustness checks
    % =========================

    if nargin < 1
        error('partial_trace_B:InvalidNumInputs', ...
              'Expected 1 input argument.');
    end

    if ~isnumeric(rho_AB)
        error('partial_trace_B:InvalidType', ...
              'rho_AB must be numeric.');
    end

    if ~ismatrix(rho_AB)
        error('partial_trace_B:InvalidShape', ...
              'rho_AB must be a 2-D matrix.');
    end

    if ~isequal(size(rho_AB), [4, 4])
        error('partial_trace_B:InvalidSize', ...
              'rho_AB must be a 4x4 matrix for a two-qubit system.');
    end

    if norm(rho_AB - rho_AB', 'fro') > 1e-12
        warning('partial_trace_B:NonHermitianInput', ...
                ['rho_AB is not exactly Hermitian within tolerance. ', ...
                 'Check whether the input is a valid density matrix.']);
    end

    trace_rho = trace(rho_AB);
    if abs(trace_rho - 1) > 1e-12
        warning('partial_trace_B:TraceNotOne', ...
                ['rho_AB does not have unit trace within tolerance. ', ...
                 'Current trace is %g + %gi.'], real(trace_rho), imag(trace_rho));
    end


    % =========================
    % Main computation
    % =========================
    % Basis ordering:
    %   |00>, |01>, |10>, |11>
    %
    % Partial trace over subsystem B:
    %   (rho_A)_{a,a'} = sum_b <a,b| rho_AB |a',b>

    % Precompute bipartite computational basis states |ab>
    basis_AB = cell(2, 2);
    for a = 1:2
        for b = 1:2
            label = [num2str(a-1), num2str(b-1)];  % '00','01','10','11'
            basis_AB{a, b} = computational_basis(label);
        end
    end

    rho_A = zeros(2, 2, 'like', rho_AB);

    for a = 1:2
        for a_prime = 1:2
    
            element_sum = 0;
    
            for b = 1:2
                ket_left  = basis_AB{a, b};
                ket_right = basis_AB{a_prime, b};
    
                element_sum = element_sum + ...
                    ket_left' * rho_AB * ket_right;
            end
    
            rho_A(a, a_prime) = element_sum;
        end
    end

end