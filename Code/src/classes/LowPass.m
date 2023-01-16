classdef LowPass < FilterObject
    %TODO: Comeback and develop a more efficient implementation to help
    %support a real-time implementation. The design equations were taken
    %from Will Pirkle's DAFX book
    properties (Constant)
        order = 2
        Q = sqrt(2)/2;   %We don't want any peaks
    end
    
    methods
        function obj = LowPass(f_c)
            w = f_c/(SystemParams.audioRate/2);
            b = zeros(1, LowPass.order+1);
            a = zeros(1, LowPass.order+1);
            z_init = zeros(1, max(length(b), length(a))-1); 
            obj@FilterObject(b, a, z_init);
            obj.update_f_c(f_c);
        end       
        
        function update_f_c(obj, newValue)
            %Calculate intermediate variables
            %Page 272 in Pirkle Book
            theta_c = 2*pi*newValue / SystemParams.audioRate;
            d = 1/obj.Q;
            beta = 0.5 * (1 - d/2 * sin(theta_c)) / (1 + d/2 * sin(theta_c));
            gamma = (+5 + beta)*cos(theta_c);
            
            %In his book, he swaps the the a/b parts (so his b_n corresponds
            %to the IIR part, and his a_n corresponds to the FIR part)
            obj.b(1) = (.5 + beta - gamma)/2;
            obj.b(2) = (.5 + beta - gamma);
            obj.b(3) = (.5 + beta - gamma)/2;
            obj.a(1) = 1;
            obj.a(2) = -2*gamma;
            obj.a(3) = 2*beta;
        end
    end
end

