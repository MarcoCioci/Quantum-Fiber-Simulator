function psi = bell_state(type)
% BELL_STATE  Generate a Bell state of a two-qubit system.
%
% Objective:
%   This function returns one of the four maximally entangled Bell states,
%   selected via the input parameter 'type'. The states are defined in the
%   computational basis:
%
%       {|00⟩, |01⟩, |10⟩, |11⟩}
%
%   The supported Bell states are:
%
%       'psi_plus'   : (|01⟩ + |10⟩) / sqrt(2)
%       'psi_minus'  : (|01⟩ - |10⟩) / sqrt(2)
%       'phi_plus'   : (|00⟩ + |11⟩) / sqrt(2)
%       'phi_minus'  : (|00⟩ - |11⟩) / sqrt(2)
%
%   The output is a normalized 4x1 complex column vector representing the
%   selected state in C^2 ⊗ C^2.
%
%   This function generalizes the state preparation stage of the simulator,
%   allowing systematic comparison between different entangled resources
%   under the same propagation model.
%
% Input:
%   type  - string specifying the Bell state to generate
%
% Output:
%   psi   - 4x1 complex column vector representing the chosen Bell state
%
% Notes:
%   The basis ordering must be kept consistent across the entire simulator.
%   This function is intended as a core component of the state-preparation
%   module and should be used as the entry point for all simulations.

    switch type
        case 'psi_plus'
            psi = (1/sqrt(2)) * [0; 1; 1; 0] + 0*1i;

        case 'psi_minus'
            psi = (1/sqrt(2)) * [0; 1; -1; 0] + 0*1i;

        case 'phi_plus'
            psi = (1/sqrt(2)) * [1; 0; 0; 1] + 0*1i;

        case 'phi_minus'
            psi = (1/sqrt(2)) * [1; 0; 0; -1] + 0*1i;

        otherwise
            error('bell_state:InvalidType', ...
                'Invalid Bell state type. Use: psi_plus, psi_minus, phi_plus, or phi_minus.');
    end

end