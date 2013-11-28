% Function to compute the persistence diagram on an undirected graph G(E,V)
% Edges must be given as a Ex2 matrix of vertex ids (1-indexed).  The
% function f must be given as a Vx1 vector of real numbers. The persistence
% is always computed for function maxima. 
%
% The output consists of the indices of local maxima, and their associated
% persistence values. Note that for a vertex i with persistence p, 
% birth(i) = f(i), death(i) = f(i) + p.
function [I P] = graph_persistence(edges, f)
    if (size(edges,2) ~= 2)
        error('edges must be a Ex2 matrix');
    elseif (size(f,2) ~= 1)
        error('f must be a Vx1 matrix');
    elseif (min(min(edges))<1 || max(max(edges)) > length(f))
        error('edge indices must be between 1 and V');
    end
    
    [I P] = comp_graph_persistence(double(edges'), f);
end