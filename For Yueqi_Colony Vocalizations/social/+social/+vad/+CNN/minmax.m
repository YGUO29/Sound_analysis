function A = minmax(A, xmin, xmax)
    amin = min(min(A));
    amax = max(max(A));
    A = (A-amin)/(amax-amin)*(xmax-xmin)+xmin;
end
