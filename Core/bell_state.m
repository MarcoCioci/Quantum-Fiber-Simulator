function psi = bell_state(type)
% BELL_STATE  Generate a Bell state of a two-qubit system.
%
% Objective:
%   Return one of the four maximally entangled Bell states,
%   selected via the input parameter 'type'.
%
%   The states are defined in the computational basis:
%
%       {|00>, |01>, |10>, |11>}
%
% Input:
%   type  - string or char specifying the Bell state:
%           'psi_plus', 'psi_minus', 'phi_plus', 'phi_minus'
%
% Output:
%   psi   - 4x1 complex column vector representing the chosen Bell state
%
% Notes:
%   The output state is normalized by construction.
%   This function is the standard entry point for state preparation
%   in the simulator.

    % =========================
    % Robustness checks
    % =========================

    if nargin ~= 1
        error('bell_state:InvalidNumInputs', ...
            'Expected exactly 1 input argument: type.');
    end

    if ~(ischar(type) || isstring(type))
        error('bell_state:InvalidType', ...
            'type must be a string or character array.');
    end

    type = char(type);  % normalize input

    
    % =========================
    % Main computation
    % =========================

    % Computational basis states
    ket_00 = computational_basis('00');
    ket_01 = computational_basis('01');
    ket_10 = computational_basis('10');
    ket_11 = computational_basis('11');

    switch type

        case 'psi_plus'
            psi = ket_01 + ket_10;

        case 'psi_minus'
            psi = ket_01 - ket_10;

        case 'phi_plus'
            psi = ket_00 + ket_11;

        case 'phi_minus'
            psi = ket_00 - ket_11;

        otherwise
            error('bell_state:InvalidState', ...
                ['Invalid Bell state type. Use one of: ', ...
                 'psi_plus, psi_minus, phi_plus, phi_minus.']);
    end

    psi = psi / sqrt(2);   % normalization
    psi = complex(psi);    % enforce complex type

end