
function myDegree(Q, i) # shouldnt allocate for mutable vertices
    return length(inneighbors(Q, i)) + length(outneighbors(Q, i))
end

@doc raw"""
    is_weakly_separated(n::Int, v::Vector{Int}, w::Vector{Int})

Test if two vectors `v` and `w` viewed as subsets of `{1 , ..., n}` are weakly separated.
"""
function is_weakly_separated(v::Vector{T}, w::Vector{S}) where {T, S <: Integer}
    n = max( maximum(v), maximum(w))
    x = setdiff(v, w)
    y = setdiff(w, v)
    i = 1
    
    # the following trys to find a < b < c < d contradicting the the ws of v and w
    while !(i in x) && !(i in y) 
        i += 1
        i+3 > n && return true
    end
    
    i in y && ( (x, y) = (y, x) )
    
    while !(i in y)
        i += 1
        i+2 > n && return true
    end
    
    while !(i in x) 
        i += 1
        i+1 > n && return true
    end
    
    while !(i in y) 
        i += 1
        i > n && return true
    end
    # if we get here, a, b, c, d have been found so v and w are not weakly separated
    return false
end

@doc raw"""
    is_weakly_separated(labels::Vector{Vector{Int}})

Test if the vectors contained in `labels` are pairwise weakly separated.
"""
function is_weakly_separated(labels::Vector{Vector{T}}) where T <: Integer
    len = length(labels)
    for i = 1:len-1
        for j = i+1:len
            if !is_weakly_separated(labels[i], labels[j])
                return false
            end
        end
    end

    return true
end

@doc raw"""
    frozen_label(k::Int, n::Int, i::Int)

Return the `i-th` frozen label.
"""
function frozen_label(k::Int, n::Int, i::Int, T::Type = Int)
    it = 1+i > k ? (1-k+i:i) : Iterators.flatten(( 1:i, n+i+1-k:n ))
    return collect(T, it)
end


@doc raw"""
    super_potential_label(k, n, i)

Return the `i-th` (left) label of the superpotential.
"""
function super_potential_label(k::Int, n::Int, i::Int, T::Type = Int)

    if i > k
        res = collect(T, 1-k+i:i)
        res[1] = i-k
        return res
    elseif i < k
        it = Iterators.flatten(( 1:i+1, n+i+2-k:n ))
        res = collect(T, it)
        res[i+1] = n+i-k
        return res
    else   
        res = collect(T, 2:k+1)
        res[k] = n
        return res
    end
end

@doc raw"""
    rectangle_label(k::Int, n::Int, i::Int, j::Int)

Return the label of the rectangle graph in row `i`
and column `j`. 
"""
function rectangle_label(k::Int, n::Int, i::Int, j::Int, T::Type = Int) 
    return collect(T, Iterators.flatten((i+1:i+j, n-k+j+1:n)))
end

@doc raw"""
    checkboard_label(k::Int, n::Int, i::Int, j::Int)

Return the label of the checkboard graph in row `i`
and column `j`. 
"""
function checkboard_label(k::Int, n::Int, i::Int, j::Int, T::Type = Int)
    y = cld(i+j, 2)

    if i == 0 || j == 0 || j == k || i == n-k
        a = i+1 - y
        b = i+j - y
        c = n - k + j+1 - y
        d = n - y

        it = Iterators.map( x-> mod1(x, n), Iterators.flatten(( a:b, c:d )))
        return sort!(collect(T, it))
    end

    a = mod1(i+1 - y, n)
    b = mod1(i+j - y, n)
    c = mod1(-k+j+1 - y, n)
    d = mod1(-y, n)

    if a > b
        it = Iterators.flatten((1:b , c:d, a:n))
    elseif c > d
        it = Iterators.flatten((1:d , a:b, c:n))
    else
        it = Iterators.flatten((a:b, c:d))
    end

    return collect(T, it)
end

@doc raw"""
    dual_rectangle_label(k::Int, n::Int, i::Int, j::Int)

Return the label of the dual rectangle graph in row `i`
and column `j`. 
"""
function dual_rectangle_label(k::Int, n::Int, i::Int, j::Int, T::Type = Int) # n is unnecessary, but included for consistency
    return collect(T, Iterators.flatten( (1:i, i+j+1:k+j) ))
end

@doc raw"""
    dual_checkboard_label(k::Int, n::Int, i::Int, j::Int)

Return the label of the dual checkboard graph in row `i`
and column `j`. 
"""
function dual_checkboard_label(k::Int, n::Int, i::Int, j::Int, T::Type = Int) 
    y = cld(i+j, 2)

    if i == 0 || j == 0 || i == k || j == n-k
        a = 1 - y
        b = i - y
        c = i+j+1 - y
        d = k+j - y

        it = Iterators.map( x-> mod1(x, n), Iterators.flatten(( a:b, c:d )))
        return sort!(collect(T, it))
    end

    a = mod1(1 - y, n)
    b = mod1(i - y, n)
    c = mod1(i+j+1 - y, n)
    d = mod1(k+j - y, n)

    if a > b
        it = Iterators.flatten((1:b , c:d, a:n))
    elseif c > d
        it = Iterators.flatten((1:d , a:b, c:n))
    else
        it = Iterators.flatten((c:d, a:b))
    end

    return collect(T, it)
end

@doc raw"""
    frozen_labels(k::Int, n::Int)

Return the frozen labels as a vector.
"""
function frozen_labels(k::Int, n::Int, T::Type = Int)
    return [frozen_label(k, n, i, T) for i in 1:n]
end

function super_potential_labels(k::Int, n::Int, T::Type = Int)
    return [super_potential_label(k, n, i, T) for i in 1:n]
end

@doc raw"""
    rectangle_labels(k::Int, n::Int)

Return the labels of the rectangle graph as a vector. 
The frozen labels are in positions `1` to `n`.
"""
function rectangle_labels(k::Int, n::Int, T::Type = Int) 
    it = Iterators.product(1:k-1, 1:n-k-1)
    N = k*(n-k)+1
    res = Vector{Vector{T}}(undef, N)

    for i in 1:n
        @inbounds res[i] = frozen_label(k, n, i, T)
    end

    for x in it
        @inbounds res[n + (x[2]-1)*(k-1) + x[1]] = rectangle_label(k, n, x[2], x[1], T)
    end

    return res
end

@doc raw"""
    checkboard_labels(k::Int, n::Int)

Return the labels of the checkboard graph as a vector. 
The frozen labels are in positions `1` to `n`.
"""
function checkboard_labels(k::Int, n::Int, T::Type = Int) 
    it = Iterators.product(1:k-1, 1:n-k-1)
    N = k*(n-k)+1
    res = Vector{Vector{T}}(undef, N)

    for i in 1:n
        @inbounds res[i] = frozen_label(k, n, i, T)
    end
    
    for x in it
        @inbounds res[n + (x[2]-1)*(k-1) + x[1]] = checkboard_label(k, n, x[2], x[1], T)
    end

    return res
end

@doc raw"""
    dual_rectangle_labels(k::Int, n::Int)

Return the labels of the dual-rectangle graph as a vector. 
The frozen labels are in positions `1` to `n`.
"""
function dual_rectangle_labels(k::Int, n::Int, T::Type = Int)
    it = Iterators.product(1:n-k-1, 1:k-1)
    N = k*(n-k)+1
    res = Vector{Vector{T}}(undef, N)

    for i in 1:n
        @inbounds res[i] = frozen_label(k, n, i, T)
    end

    for x in it
        @inbounds res[n + (x[2]-1)*(n-k-1) + x[1]] = dual_rectangle_label(k, n, x[2], x[1], T)
    end

    return res
end

@doc raw"""
    dual_checkboard_labels(k::Int, n::Int)

Return the labels of the dual-checkboard graph as a vector. 
The frozen labels are in positions `1` to `n`.
"""
function dual_checkboard_labels(k::Int, n::Int, T::Type = Int)
    it = Iterators.product(1:n-k-1, 1:k-1)
    N = k*(n-k)+1
    res = Vector{Vector{T}}(undef, N)

    for i in 1:n
        @inbounds res[i] = frozen_label(k, n, i, T)
    end

    for x in it
        @inbounds res[n + (x[2]-1)*(n-k-1) + x[1]] = dual_checkboard_label(k, n, x[2], x[1], T)
    end

    return res
end

#### some helper functions ####

function intersect_neighbors!(res::Vector{T}, a::Vector{T}, b::Vector{T}) where T <: Integer
    len = length(a)
    y = 1

    for x in 1:len
        @inbounds a[x] == b[x] || (y = x; break)
        res[x] = a[x]
    end

    if a[y] < b[y]
        for x in y+1:len
            @inbounds res[x-1] = a[x]
        end
    else
        for x in y+1:len
            @inbounds res[x-1] = b[x]
        end
    end

    return res
end

function intersect_opposing!(res::Vector{T}, a::Vector{T}, b::Vector{T}) where T <: Integer
    x = 1
    len = length(a)

    for i in 1:len
        @inbounds a[i] == b[i] || (x = i; break)
        res[i] = a[i]
    end

    if a[x] < b[x] # first difference is in a

        for i in x+1:len
            @inbounds a[i] == b[i-1] || (x = i; break)
            res[i-1] = a[i]
        end

        if a[x] < b[x-1] # found both differences in a

            for i in x+1:len
                @inbounds res[i-2] = a[i]
            end
        else # there could be one more diff

            y = 0
            for i in x+1:len
                @inbounds a[i-1] == b[i-1] || (y = i; break)
                @inbounds res[i-2] = b[i-1]
            end

            y == 0 && return res

            # b[x-1] < a[x-1] othererwise not weakly separated
            for i in y+1:len+1
                @inbounds res[i-3] = b[i-1]
            end
        end
    else # first difference is in b

        for i in x+1:len
            @inbounds b[i] == a[i-1] || (x = i; break)
            res[i-1] = b[i]
        end

        if b[x] < a[x-1] # found both differences in b
            
            for i in x+1:len
                @inbounds res[i-2] = b[i]
            end
        else # there could be one more diff
            
            y = 0
            for i in x+1:len
                @inbounds b[i-1] == a[i-1] || (y = i; break)
                @inbounds res[i-2] = a[i-1]
            end

            y == 0 && return res
                
            # a[x-1] < b[x-1] othererwise not weakly separated
            for i in y+1:len+1
                @inbounds res[i-3] = a[i-1]
            end
        end
    end

    return res
end

function intersect_neighbors_which!(res::Vector{T}, a::Vector{T}, b::Vector{T}) where T <: Integer
    len = length(a)
    y = 1

    for x in 1:len
        @inbounds a[x] == b[x] || (y = x; break)
        res[x] = a[x]
    end

    if a[y] < b[y]
        for x in y+1:len
            @inbounds res[x-1] = a[x]
        end
        return 2
    else
        for x in y+1:len
            @inbounds res[x-1] = b[x]
        end
        return 1
    end
end

function combine_neighbors!(res::Vector{T}, a::Vector{T}, b::Vector{T}) where T <: Integer
    x = 1
    len = length(a)

    for i in 1:len
        @inbounds a[i] == b[i] || (x = i; break)
        @inbounds res[i] = a[i]
    end

    if a[x] < b[x]
        
        res[x] = a[x]
        for i in x:len
            res[i+1] = b[i]
        end
    else

        res[x] = b[x]
        for i in x:len
            res[i+1] = a[i]
        end
    end

    return res
end

function is_contained(a::Vector{T}, b::Vector{T}) where T <: Integer
    x = 0
    len = length(a)

    for i in 1:len
        a[i] == b[i] || (x = i; break)
    end

    x == 0 && return true
    a[x] < b[x] && return false

    for i in x:len
        a[i] == b[i+1] || return false
    end

    return true
end

function add_two!(W::Vector{Vector{T}}, a::Vector{T}, b::Vector{T}) where T <: Integer
    bool1 = a in W
    bool2 = b in W

    bool1 ? W : push!(W, a)
    bool2 ? W : push!(W, b)
end

@doc raw"""
    compute_cliques(labels::Vector{Vector{Int}})

Return the non trivial black and white cliques of the weakly separated collection 
whose elements are given by `labels`.
"""
function compute_cliques(labels::Vector{Vector{T}}) where T <: Integer
    N = length(labels)
    k = length(labels[1])
    W = Dict{Vector{T}, Vector{Vector{T}}}()
    B = Dict{Vector{T}, Vector{Vector{T}}}()

    sizehint!(W, 2*N)
    sizehint!(B, 2*N)

    K = Vector{T}(undef, k-1)
    L = Vector{T}(undef, k+1)

    # compute white and black cliques
    for i = 1:N-1
        for j = i+1:N
            
            l = intersect_neighbors_which!(K, labels[i], labels[j])
            if is_contained(K, labels[(i, j)[l]]) # => |K| = k-1

                # labels[i] and labels[j] belong to W[K]
                index = Base.ht_keyindex(W, K)
                index < 0 ? W[copy(K)] = [labels[i], labels[j]] : add_two!(W.vals[index], labels[i], labels[j])

                # labels[i] and labels[j] also belong to B[L]
                combine_neighbors!(L, labels[i], labels[j]) 
                index = Base.ht_keyindex(B, L)
                index < 0 ? B[copy(L)] = [labels[i], labels[j]] : add_two!(B.vals[index], labels[i], labels[j])
            end

        end
    end
    
    # remove trivial cliques
    filter!( ((key, val),) -> length(val) > 2, W)
    filter!( ((key, val),) -> length(val) > 2, B)

    return W, B
end

@doc raw"""
    compute_cliques(labels::Vector{Vector{Int}}, quiver::SimpleDiGraph{Int})

Return the non trivial black and white cliques of the weakly separated collection 
whose elements are given by `labels` and whose adjacencies are encoded in `quiver`.
"""
function compute_cliques(labels::Vector{Vector{T}}, quiver::SimpleDiGraph{T}) where T <: Integer
    k = length(labels[1])
    W = Dict{Vector{T}, Vector{Vector{T}}}()
    B = Dict{Vector{T}, Vector{Vector{T}}}()

    sizehint!(W, ne(quiver))
    sizehint!(B, ne(quiver))

    K = Vector{T}(undef, k-1)
    L = Vector{T}(undef, k+1)

    for e in edges(quiver)
        i, j = src(e), dst(e)

        l = intersect_neighbors_which!(K, labels[i], labels[j])
            
        if is_contained(K, labels[(i, j)[l]]) # => |K| = k-1

            # labels[i] and labels[j] belong to W[K]
            index = Base.ht_keyindex(W, K)
            index < 0 ? W[copy(K)] = [labels[i], labels[j]] : add_two!(W.vals[index], labels[i], labels[j])

            # labels[i] and labels[j] also belong to B[L]
            combine_neighbors!(L, labels[i], labels[j]) 
            index = Base.ht_keyindex(B, L)
            index < 0 ? B[copy(L)] = [labels[i], labels[j]] : add_two!(B.vals[index], labels[i], labels[j])
        end
    end

    # there are no trivial cliques generated this way

    return W, B
end

#### helper functions ####

function findindex(a, val)
    for i in 1:length(a)
        a[i] == val && return i
    end

    return 0
end

function first_diff(x, a)
    len = length(x)
    for i in 1:len-1
        @inbounds x[i] == a[i] || return x[i]
    end

    return x[len]
end

# given the boundary of a clique, add edges (if not both vertices are frozen)
function add_edges!(Q::SimpleDiGraph, C, n) 
    len = length(C)

    for l = 1:len-1
        @inbounds (C[l] > n || C[l+1] > n) && add_edge!(Q, C[l], C[l+1])
    end

    (C[len] > n || C[1] > n) && add_edge!(Q, C[len], C[1])
end

function white_clique_pos(K, C, labels::Vector{Vector{T}}) where T <: Integer
    len = length(C)
    res = Vector{T}(undef, len)
    p = Vector{Int}(undef, len)

    for i in 1:len
        @inbounds res[i] = first_diff(C[i], K)
    end	

    sortperm!(p, res)

    for i in 1:len
        @inbounds res[i] = findindex(labels, C[p[i]])
    end

    return res
end

function black_clique_pos(L, C, labels::Vector{Vector{T}}) where T <: Integer
    len = length(C)
    res = Vector{T}(undef, len)
    p = Vector{Int}(undef, len)

    for i in 1:len
        @inbounds res[i] = first_diff(L, C[i])
    end	

    sortperm!(p, res)

    for i in 1:len
        @inbounds res[i] = findindex(labels, C[p[i]])
    end

    return res
end

@doc raw"""
    compute_adjacencies(n::Int, labels::Vector{Vector{Int}}) 

Compute the adjacency graph and face boundaries of the weakly separated collection 
with elements given by `labels`.
"""
function compute_adjacencies(n::Int, labels::Vector{Vector{T}}) where T <: Integer
    N = length(labels)
    W, B = compute_cliques(labels)

    Q = SimpleDiGraph{T}(N)
    W2 = Dict{Vector{T}, Vector{T}}()
    B2 = Dict{Vector{T}, Vector{T}}()

    sizehint!(W2, length(W))
    sizehint!(B2, length(B))

    # compute boundary and add edges for non trivial white cliques
    for (K, C) in W 
        clique_pos = white_clique_pos(K, C, labels)
        W2[K] = clique_pos
        add_edges!(Q, clique_pos, n)
    end

    # compute boundary for non trivial black cliques (dont add edges here to avoid 2-cycles)
    for (L, C) in B 
        B2[L] = black_clique_pos(L, C, labels)
    end

    return Q, W2, B2
end

@doc raw"""
    compute_boundaries(labels::Vector{Vector{Int}}, quiver::SimpleDiGraph{Int})

Compute the face boundaries of the weakly separated collection with elements given 
by `labels` and adjacency graph `quiver`.
"""
function compute_boundaries(labels::Vector{Vector{T}}, quiver::SimpleDiGraph{T}) where T <: Integer
    W, B = compute_cliques(labels, quiver)
    
    W2 = Dict{Vector{Int}, Vector{Int}}()
    B2 = Dict{Vector{Int}, Vector{Int}}()

    sizehint!(W2, length(W))
    sizehint!(B2, length(B))

    # compute boundary and add edges for non trivial white cliques
    for (K, C) in W 
        W2[K] = white_clique_pos(K, C, labels)
    end

    # compute boundary for non trivial black cliques (dont add edges here to avoid 2-cycles)
    for (L, C) in B 
        B2[L] = black_clique_pos(L, C, labels)
    end

    return W2, B2
end

@doc raw"""
    WSCollection

An abstract 2-dimensional cell complex living inside the matriod of `k-sets` in `{1, ..., n}`. 
Its vertices are labelled by elements of `labels` while `quiver` encodes adjacencies 
between the vertices. 
The 2-cells are colored black or white and contained in `blackCliques` and `whiteCliques`.

# Attributes
- `k::Int`
- `n::Int`
- `labels::Vector{Vector{T}}`
- `quiver::SimpleDiGraph{T}`
- `whiteCliques::Dict{Vector{T}, Vector{T}}`
- `blackCliques::Dict{Vector{T}, Vector{T}}`

# Constructors
    WSCollection(k::Int, n::Int, labels::Vector{Vector{T}}, 
                computeCliques::Bool = true, frozenFirst::Bool = true)

    WSCollection(k::Int, n::Int, labels::Vector{Vector{T}}, quiver::SimpleDiGraph{T}, 
                computeCliques::Bool = true, frozenFirst::Bool = true)

    WSCollection(C::WSCollection; computeCliques::Bool = true)
"""
mutable struct WSCollection{T <: Integer}
    k::Int
    n::Int
    labels::Vector{Vector{T}}
    quiver::SimpleDiGraph{T}
    whiteCliques::Dict{Vector{T}, Vector{T}}
    blackCliques::Dict{Vector{T}, Vector{T}}
end

function copy_labels(C::WSCollection{T}) where T <: Integer
    N = length(C)

    new_labels = Vector{Vector{T}}(undef, N)
    for i in 1:N
        @inbounds new_labels[i] = copy(C.labels[i])
    end

    return new_labels
end

function Base.deepcopy(C::WSCollection{T}) where T <: Integer
    labels = copy_labels(C)
    Q = SimpleDiGraph(C.quiver)

    W = Dict{Vector{T}, Vector{T}}()
    B = Dict{Vector{T}, Vector{T}}()
    sizehint!(W, length(C.whiteCliques))
    sizehint!(B, length(C.blackCliques))

    for (K, C) in C.whiteCliques
        W[copy(K)] = copy(C)
    end

    for (L, C) in C.blackCliques
        B[copy(L)] = copy(C)
    end

    return WSCollection(C.k, C.n, labels, Q, W, B)
end

function frozen_first(k::Int, n::Int, labels::Vector{Vector{T}}) where T <: Integer
    N = length(labels)
    res = Vector{Vector{T}}(undef, N)

    for i in 1:n
        res[i] = frozen_label(k, n, i, T)
    end

    frozen = @view res[1:n]

    x = n+1
    for i in 1:N
        labels[i] in frozen || ( res[x] = labels[i]; x += 1)
    end

    return res
end

@doc raw"""
    WSCollection(k::Int, n::Int, labels::Vector{Vector{Int}}, computeCliques::Bool = true)

Constructor of WSCollection. Adjacencies between its vertices as well as 2-cells are 
computed using only a set of vertex `labels`.

If `computeCliques` is set to false, the 2-cells will be left empty.
"""
function WSCollection(k::Int, n::Int, labels::Vector{Vector{T}}; 
                        computeCliques::Bool = true, frozenFirst::Bool = true) where T <: Integer

    new_labels = frozenFirst ? frozen_first(k, n, labels) : labels
    Q, W, B = compute_adjacencies(n, new_labels)

    if computeCliques 
        return WSCollection{T}(k, n, new_labels, Q, W, B)
    else
        return WSCollection{T}(k, n, new_labels, Q, Dict{Vector{T}, Vector{T}}(), Dict{Vector{T}, Vector{T}}())
    end
end

@doc raw"""
    WSCollection(k::Int, n::Int, labels::Vector{Vector{Int}}, quiver::SimpleDiGraph{Int}, 
    computeCliques::Bool = true)

Constructor of WSCollection. The 2-cells are computed from vertex `labels` as well as the
their adjacencies encoded in `quiver`. Faster than just using labels most of the time.

If `computeCliques` is `false` the black and white 2-cells are are left empty instead.
"""
function WSCollection(k::Int, n::Int, labels::Vector{Vector{T}}, quiver::SimpleDiGraph{T}; 
                        computeCliques::Bool = true, frozenFirst::Bool = true) where T <: Integer

    new_labels = frozenFirst ? frozen_first(k, n, labels) : labels

    if !computeCliques
        return WSCollection{T}(k, n, new_labels, quiver, Dict{Vector{T}, Vector{T}}(), Dict{Vector{T}, Vector{T}}())
    else
        W, B = compute_boundaries(new_labels, quiver)
        return WSCollection{T}(k, n, new_labels, quiver, W, B)
    end
end

@doc raw"""
    WSCollection(C::WSCollection; computeCliques::Bool = true)

Constructor of WSCollection. Computes 2-cells of `C` if the are empty, 
othererwise returns a deepcopy of `C`.

If `computeCliques` is `false` the black and white 2-cells are left empty instead.
"""
function WSCollection(C::WSCollection{T}; computeCliques::Bool = true) where T <: Integer

    if computeCliques && !isempty(C.whiteCliques) && !isempty(C.blackCliques)
        return deepcopy(C)
    end

    labels = copy_labels(C)
    Q = SimpleDiGraph(C.quiver)

    if !computeCliques

        W, B = Dict{Vector{T}, Vector{T}}(), Dict{Vector{T}, Vector{T}}()
        return WSCollection{T}(C.k, C.n, labels, Q, W, B)
    else
        
        W, B = compute_boundaries(C.labels, C.quiver)
        return WSCollection(C.k, C.n, labels, Q, W, B)
    end
end

@doc raw"""
    in(label::Vector{Int}, C::WSCollection)

Return true if `label` is occurs as label of `C`.
"""
Base.in(label::Vector{T}, C::WSCollection{T}) where T <: Integer = label in C.labels

@doc raw"""
    getindex(C::WSCollection, inds...)

Return the subset of the labels in `C` specified `inds` in `C.labels`.
"""
Base.getindex(C::WSCollection, inds...) = getindex(C.labels, inds...)

@doc raw"""
    length(C::WSCollection)

Return the length of `C.labels`.
"""
Base.length(C::WSCollection) = length(C.labels)

@doc raw"""
    (==)(C1::WSCollection, C2::WSCollection)

Return true if the vertices of `C1` and `C2` contain the same labels.
The order of labels in each collection does not matter.
"""
function Base.:(==)(C1::WSCollection, C2::WSCollection)
    n = C1.n
    n == C2.n || return false
    C1.k == C2.k || return false
    
    return @views sort(C1.labels[n+1:end]) == sort(C2.labels[n+1:end])
end

Base.hash(C::WSCollection) = hash(sort(C.labels))

# function Base.hash(C::WSCollection)
#     n = C.n
#     res = hash(C[n+1])

#     for i in n+2:length(C)
#         res += hash(C[i])
#     end
    
#     return res
# end

@doc raw"""
    cliques_empty(C::WSCollection)

Return true if the white or black cliques in `C` are empty. 
"""
function cliques_empty(C::WSCollection)
    return isempty(C.whiteCliques) || isempty(C.blackCliques)
end

@doc raw"""
    intersect(C1::WSCollection, C2::WSCollection)

Return the common labels of `C1` and `C2`.
"""
function Base.intersect(C1::WSCollection, C2::WSCollection)
    return intersect(C1.labels, C2.labels)
end

@doc raw"""
    setdiff(C1::WSCollection, C2::WSCollection)

Return the labels of `C1` minus the labels of `C2`.
"""
function Base.setdiff(C1::WSCollection, C2::WSCollection)
    return setdiff(C1.labels, C2.labels)
end

@doc raw"""
    setdiff(C1::WSCollection, C2::WSCollection)

Return the union of labels in `C1` and `C2`.
"""
function Base.union(C1::WSCollection, C2::WSCollection)
    return union(C1.labels, C2.labels)
end


function Base.show(io::IO, C::WSCollection{T}) where T <: Integer
    s = "WSCollection{$T} of type ($(C.k), $(C.n)) with $(length(C)) labels"
    print(io, s)
end

function Base.print(C::WSCollection{T}; full::Bool = false) where T <: Integer
    s = "WSCollection{$T} of type ($(C.k), $(C.n)) with $(length(C)) labels"

    if full
        s *= ": \n"
        for l in C.labels
            s *= "$l\n"
        end
    end
    print(s)
end


function Base.println(C::WSCollection; full::Bool = false)
    print(C; full)
    print("\n")
end

@doc raw"""
    checkboard_collection(k::Int, n::Int, T::Type = Int)

Return the weakly separated collection corresponding to the checkboard graph.
""" 
function checkboard_collection(k::Int, n::Int, T::Type = Int) # TODO use known quiver to speed up computation
    return WSCollection(k, n, checkboard_labels(k, n, T))
end

@doc raw"""
    rectangle_collection(k::Int, n::Int, T::Type = Int)

Return the weakly separated collection corresponding to the rectangle graph.
""" 
function rectangle_collection(k::Int, n::Int, T::Type = Int) # TODO use known quiver to speed up computation
    return WSCollection(k, n, rectangle_labels(k, n, T))
end

@doc raw"""
    dual_checkboard_collection(k::Int, n::Int, T::Type = Int)

Return the weakly separated collection corresponding to the dual-checkboard graph.
""" 
function dual_checkboard_collection(k::Int, n::Int, T::Type = Int) # TODO use known quiver to speed up computation
    return WSCollection(k, n, dual_checkboard_labels(k, n, T))
end

@doc raw"""
    dual_rectangle_collection(k::Int, n::Int, T::Type = Int)

Return the weakly separated collection corresponding to the dual-rectangle graph.
""" 
function dual_rectangle_collection(k::Int, n::Int, T::Type = Int) # TODO use known quiver to speed up computation
    return WSCollection(k, n, dual_rectangle_labels(k, n, T))
end

@doc raw"""
    is_frozen(C::WSCollection, i::Int)

Return true if the vertex `i` of `C` is frozen.
"""
function is_frozen(C::WSCollection, i::Integer) 
    return i <= C.n
end

@doc raw"""
    is_mutable(C::WSCollection, i::Int) 

Return true if the vertex `i` of `C` is mutable.
"""
function is_mutable(C::WSCollection, i::Integer)
    return !is_frozen(C, i) && myDegree(C.quiver, i) == 4 
end

@doc raw"""
    get_mutables(C::WSCollection)

Return all mutable vertices of `C`.
"""
function get_mutables(C::WSCollection{T}) where T <: Integer
    n = C.n
    N = length(C)
    res = Vector{T}(undef, N-n)

    j = 1
    for i in n+1:N
        myDegree(C.quiver, i) == 4 && (res[j] = i; j+=1)
    end

    return resize!(res, j-1)
end

#### helper functions #####

function sort_abcd(a, b, c, d)
    # we alreadyy know a < b amd c < d
    a > c && ((a, c) = (c, a))
    b > d && ((b, d) = (d, b))
    b > c && ((b, c) = (c, b))

    return a, b, c, d
end

function get_inneighbors(Q, i)
    x, y = 0, 0

    for i in inneighbors(Q, i) 
        x == 0 ? x = i : y = i
    end

    return x, y
end

function get_outneighbors(Q, i)
    x, y = 0, 0

    for i in outneighbors(Q, i) 
        x == 0 ? x = i : y = i
    end

    return x, y
end

function remove_I(I, Iab)
    len = length(I)
    x, y = 0, 0

    for i in 1:len
        @inbounds I[i] == Iab[i] || (x = i; break)
    end

    if x == 0 
        return Iab[len+1], Iab[len+2]
    end

    for i in x:len
        @inbounds I[i] == Iab[i+1] || (y = i; break)
    end

    return y == 0 ? (Iab[x], Iab[len+2]) :  (Iab[x], Iab[y+1])
end

function add_I!(res, I, a, b)
    len = length(I)
    x, y = 0, 0

    for i in 1:len
        I[i] < a || (x = i; break)
        @inbounds res[i] = I[i]
    end

    if x == 0 
        res[len+1] = a
        res[len+2] = b
        return res
    end

    # I[x] > a
    res[x] = a

    for i in x:len
        I[i] < b || (y = i; break)
        @inbounds res[i+1] = I[i]
    end

    if y == 0
        res[len+2] = b
        return res
    end 

    # I[y] > b
    res[y+1] = b

    for i in y:len
        @inbounds res[i+2] = I[i]
    end
    
    return res
end

function merge_cliques!(X::Dict{Vector{T},Vector{T}}, Y::Dict{Vector{T},Vector{T}}, i, ind_adj, ind_opp) where T <:Integer
    A = X.vals[ind_adj]
    l = findindex(A, i)
    succ = A[mod1(l+1 ,3)]

    O = Y.vals[ind_opp]
    l = findindex(O, succ)

    insert!(O, l, T(i))
    Base._delete!(X, ind_adj) 
end

function split_clique!(X::Dict{Vector{T},Vector{T}}, Y::Dict{Vector{T},Vector{T}}, i, ind_adj, opp::Vector{T}) where T <:Integer
    A = X.vals[ind_adj]

    if length(A) == 3 # adjacent clique is trangle at the boundary. Just flip colors
        Y[copy(opp)] = A
        Base._delete!(X, ind_adj)
    else # split off a triangle from the adjacent clique

        l = findindex(A, i)
        m = length(A)
        Y[copy(opp)] = [ A[mod1(l-1, m)], T(i), A[mod1(l+1, m)] ]
        deleteat!(A, l)
    end
end

function updateCliques!(K::Vector{T}, L::Vector{T}, x, y, i, C::WSCollection{T}) where T <: Integer

    intersect_neighbors!(K, C[x], C[y])
    combine_neighbors!(L, C[x], C[y])
    ind_K = Base.ht_keyindex(C.whiteCliques, K)
    ind_L = Base.ht_keyindex(C.blackCliques, L)

    if is_contained(K, C[i]) # K corresponds to adjacent clique, L to "opposite"
        
        if ind_L >= 0
            # adjacent clique is a triangle and must be merged with the opposite clique
            merge_cliques!(C.whiteCliques, C.blackCliques, i, ind_K, ind_L)
        else
            # adjacent clique must be split into a triangle and another (possibly empty) clique
            split_clique!(C.whiteCliques, C.blackCliques, i, ind_K, L)
        end

    else # now L corresponds to adjacent clique, K to "opposite"
        
        if ind_K >= 0
            merge_cliques!(C.blackCliques, C.whiteCliques, i, ind_L, ind_K)
        else
            split_clique!(C.blackCliques, C.whiteCliques, i, ind_L, K)
        end
    end
end

@doc raw"""
    mutate!(C::WSCollection, i::Int, mutateCliques::Bool = true)

Mutate the `C` in direction `i` if `i` is a mutable vertex of `C`.

If `mutateCliques` is set to false, the 2-cells are emptied.
"""
function mutate!(C::WSCollection{T}, i::Int, mutateCliques::Bool = true) where T <: Integer

    is_mutable(C, i) || error("vertex $i with label $(C[i]) is not mutable!")
        
    Q = C.quiver
    N_in = get_inneighbors(Q, i)
    N_out = get_outneighbors(Q, i)

    ##### update cliques #####
    
    if mutateCliques && !cliques_empty(C)

        K = Vector{T}(undef, C.k-1)
        L = Vector{T}(undef, C.k+1)
        
        for x in N_in 
            for y in N_out
                updateCliques!(K, L, x, y, i, C)
            end
        end
        
    elseif !cliques_empty(C)
        empty!(C.whiteCliques)
        empty!(C.blackCliques)
    end

    ##### mutate quiver #####

    for j in N_in # add/remove edges according to quiver mutation
        for l in N_out
            if has_edge(Q, l, j)
                rem_edge!(Q, l, j)
            elseif !is_frozen(C, j) || !is_frozen(C, l)
                add_edge!(Q, j, l)
            end
        end
    end

    # reverse edges adjacent to i
    for j in N_in
        rem_edge!(Q, j, i)
        add_edge!(Q, i, j)
    end

    for l in N_out
        rem_edge!(Q, i, l)
        add_edge!(Q, l, i)
    end

    ##### exchange label of i #####

    I = Vector{T}(undef, C.k-2)
    intersect_opposing!(I, C[N_out[1]], C[N_out[2]])
    
    a, b = remove_I(I, C[N_out[1]])
    c, d = remove_I(I, C[N_out[2]])
    (a, b, c, d) = sort_abcd(a, b, c, d)

    insorted(b, C[i]) ? add_I!(C[i], I, a, c) : add_I!(C[i], I, b, d)

    return C
end

@doc raw"""
    mutate(C::WSCollection, i::Int, mutateCliques::Bool = true)

Version of `mutate!` that does not modify its arguments.
"""
function mutate(C::WSCollection, i::Int, mutateCliques::Bool = true)
    return mutate!( deepcopy(C), i, mutateCliques)
end

@doc raw"""
    mutate!(C::WSCollection, label::Vector{T}, mutateCliques::Bool = true)

Mutate the `C` by addressing a vertex with its label.
"""
function mutate!(C::WSCollection, label::Vector{T}, mutateCliques::Bool = true) where T <: Integer
    i = findindex(C.labels, label)
    i == 0 && error("$label is not part of the collection")

    return mutate!(C, i, mutateCliques)
end

@doc raw"""
    mutate(C::WSCollection, label::Vector{Int}, mutateCliques::Bool = true)

Mutate the `C` by addressing a vertex with its label, without modifying arguments.
"""
function mutate(C::WSCollection, label::Vector{Int}, mutateCliques::Bool = true)
    return mutate!( deepcopy(C), label, mutateCliques)
end

function apply_to_collection!(f::Function, C::WSCollection{T}) where T <: Integer # f: T -> T
    k = C.k
    N = length(C)

    # apply to labels
    for i in 1:N
        for j in 1:k
            @inbounds C.labels[i][j] = f(C.labels[i][j])
        end
        sort!(C.labels[i])
    end

    W2 = Dict{Vector{T}, Vector{T}}()
    B2 = Dict{Vector{T}, Vector{T}}()
    sizehint!(W2, length(C.whiteCliques))
    sizehint!(B2, length(C.blackCliques))

    # shift clique keys
    for (K, C) in C.whiteCliques
        for i in 1:k-1
            @inbounds K[i] = f(K[i])
        end
        sort!(K)
        W2[K] = C
    end

    for (L, C) in C.blackCliques
        for i in 1:k+1
            @inbounds L[i] = f(L[i])
        end
        sort!(L)
        B2[L] = C
    end

    C.whiteCliques = W2
    C.blackCliques = B2

    return C
end

@doc raw"""
    rotate!(C::WSCollection, amount::Int = 1)

Rotate `C` by `amount`, where a positive amount indicates a clockwise rotation.
"""
function rotate!(C::WSCollection, amount::Int = 1)
    shift = x -> mod1(x + amount, C.n)
    return apply_to_collection!(shift, C)
end

@doc raw"""
    rotate(C::WSCollection, amount::Int = 1)

Rotate `C` by `amount`, where a positive amount indicates a clockwise rotation.
Does not change its input.
"""
function rotate(C::WSCollection, amount::Int = 1)
    return rotate!(deepcopy(C), amount)
end

@doc raw"""
    mirror!(C::WSCollection, shift::Int = 2)

Reflect `C` by letting the permutation `p(x) = shift - x` interpreted modulo 
`n = C.n` act on the labels of `C`.
"""
function mirror!(C::WSCollection, shift::Int = 2)
    mirror = x -> mod1(shift - x, C.n)
    return apply_to_collection!(mirror, C)
end

@doc raw"""
    mirror(C::WSCollection, shift::Int = 2) 

Reflect `C` by letting the permutation `p(x) = shift - x` interpreted modulo 
`n = C.n` act on the labels of `C`. Does not change its input.
"""
function mirror(C::WSCollection, shift::Int = 2)
    return mirror!(deepcopy(C), shift)
end

function complement(a::Vector{T}, n::Int) where T <: Integer
    
    len = n - length(a)
    res = Vector{T}(undef, len)

    x = 1
    for i in 1:n
        @inbounds i in a || (res[x] = i; x += 1)
    end

    return res
end

@doc raw"""
    complements!(C::WSCollection) 

Return the collection whose labels are complementary to those of `C`.
"""
function complements!(C::WSCollection{T}) where T <: Integer
    n = C.n
    N = length(C)

    for i in 1:N
        @inbounds C.labels[i] = complement(C[i], n)
    end

    # take complement of clique keys
    W2 = Dict{Vector{T}, Vector{T}}()
    B2 = Dict{Vector{T}, Vector{T}}()
    sizehint!(W2, length(C.blackCliques))
    sizehint!(B2, length(C.whiteCliques))

    for (K, C) in C.whiteCliques
        L = complement(K, n)
        B2[L] = C
    end

    for (L, C) in C.blackCliques
        K = complement(L, n)
        W2[K] = C
    end

    C.whiteCliques = W2
    C.blackCliques = B2
    C.k = n-C.k

    return C
end

@doc raw"""
    complements(C::WSCollection) 

Return the collection whose labels are complementary to those of `C`.
Does not modify its input.
"""
function complements(C::WSCollection)
    return complements!(deepcopy(C))
end

@doc raw"""
    swap_colors!(C::WSCollection) 

Return the weakly separated collection whose corresponding plabic graph is obtained
from the one of `C` by swapping the colors black and white.

This is the same as taking complements and rotating by `C.k`.
"""
function swap_colors!(C::WSCollection{T}) where T <: Integer
    # swapping colors = complement + rotate by k

    n = C.n
    k = C.k
    N = length(C)
    
    for i in 1:N
        for j in 1:k
            @inbounds C.labels[i][j] = mod1(C[i][j] + k, n)
        end
        @inbounds C.labels[i] = complement(C[i], n)
    end

    # swap colors of clique keys
    W2 = Dict{Vector{T}, Vector{T}}()
    B2 = Dict{Vector{T}, Vector{T}}()
    sizehint!(W2, length(C.blackCliques))
    sizehint!(B2, length(C.whiteCliques))

    for (K, C) in C.whiteCliques

        for j in 1:k-1
            @inbounds K[j] = mod1(K[j] + k, n)
        end
        L = complement(K, n)
        B2[L] = C
    end

    for (L, C) in C.blackCliques

        for j in 1:k+1
            @inbounds L[j] = mod1(L[j] + k, n)
        end
        K = complement(L, n)
        W2[K] = C
    end

    C.whiteCliques = W2
    C.blackCliques = B2
    C.k = n-k

    return C
end

@doc raw"""
    swap_colors(C::WSCollection) 

Return the weakly separated collection whose corresponding plabic graph is obtained
from the one of `C` by swapping the colors black and white.
Does not change its input.
"""
function swap_colors(C::WSCollection)
    return swap_colors!(deepcopy(C))
end

# extend to maximal weakly separated collection using brute force
@doc raw"""
    extend_weakly_separated!(k::Int, n::Int, labels::Vector{Vector{T}})  

Extend `labels` to contain the labels of a maximal weakly separated collection.
"""
function extend_weakly_separated!(k::Int, n::Int, labels::Vector{Vector{T}}) where T <: Integer # TODO optimize
    N = k*(n-k)+1

    # enforce frozen labels in the first n positions
    frozen = frozen_labels(k, n, T)
    labels = union(frozen, labels)

    if length(labels) == N
        return labels
    end

    k_sets = subsets(1:n, k)

    for v in k_sets
        v = Vector{T}(v)
        if !(v in labels)
            is_weakly_separated(push!(labels, v)) || pop!(labels)
        end

        if length(labels) == N
            return labels
        end
    end

end

# extend to maximal weakly separated collection using know labels, then brute fore
@doc raw"""
    extend_weakly_separated!(k::Int, n::Int, labels1::Vector{Vector{T}}, 
                                             labels2::Vector{Vector{T}})

Extend `labels1` to contain the labels of a maximal weakly separated collection.
Use elements of `labels2` if possible.
"""
function extend_weakly_separated!(k::Int, n::Int, labels1::Vector{Vector{T}}, 
                                                  labels2::Vector{Vector{T}}) where T <: Integer # TODO optimize
    N = k*(n-k)+1

    # enforce frozen labels in the first n positions
    frozen = frozen_labels(k, n, T)
    labels1 = union(frozen, labels1)

    for v in labels2
        if !(v in labels1)
            is_weakly_separated(push!(labels1, copy(v))) || pop!(labels1)
        end

        length(labels1) == N && return labels1
    end

    k_sets = subsets(1:n, k)

    for v in k_sets
        v = Vector{T}(v)
        if !(v in labels1)
            is_weakly_separated(push!(labels1, v)) || pop!(labels1)
        end

        length(labels1) == N && return labels1
    end

end

@doc raw"""
    extend_weakly_separated!(labels::Vector{Vector{Int}}, C::WSCollection)

Extend `labels` to contain the labels of a maximal weakly separated collection.
Use labels of `C` if possible.
"""
function extend_weakly_separated!(labels::Vector{Vector{T}}, C::WSCollection{T}) where T <: Integer
    return extend_weakly_separated!(C.k, C.n, labels, C.labels)
end

@doc raw"""
    extend_to_collection(k::Int, n::Int, labels::Vector{Vector{Int}})

Return a maximal weakly separated collection containing all elements of `labels`.
"""
function extend_to_collection(k::Int, n::Int, labels::Vector{Vector{T}}) where T <: Integer
    N = length(labels)

    L = Vector{Vector{T}}(undef, N)
    for i in 1:N
        @inbounds L[i] = copy(labels[i])
    end

    return WSCollection(k, n, extend_weakly_separated!(k, n, L))
end

@doc raw"""
    extend_to_collection(k::Int, n::Int, labels1::Vector{Vector{Int}}, 
                                         labels2::Vector{Vector{Int}})

Return a maximal weakly separated collection containing all elements of `labels1`.
Use elements of `labels2` if possible.
"""
function extend_to_collection(k::Int, n::Int, labels1::Vector{Vector{T}}, labels2::Vector{Vector{T}}) where T <: Integer
    N = length(labels1)

    L = Vector{Vector{T}}(undef, N)
    for i in 1:N
        @inbounds L[i] = copy(labels1[i])
    end

    return WSCollection(k, n, extend_weakly_separated!(k, n, L, labels2))
end

@doc raw"""
    extend_to_collection(labels::Vector{Vector{Int}}, C::WSCollection)

Return a maximal weakly separated collection containing all elements of `labels`.
Use labels of `collection` if possible.
"""
function extend_to_collection(labels::Vector{Vector{T}}, C::WSCollection{T}) where T <: Integer
    N = length(labels)

    L = Vector{Vector{T}}(undef, N)
    for i in 1:N
        @inbounds L[i] = copy(labels[i])
    end

    return WSCollection(C.k, C.n, extend_weakly_separated!(L, C))
end


# mutating the checkboard graph with this sequence rotates it clockwise
function checkboard_rotation_sequence(k::Int, n::Int) 
    seq = []

    for i in 1:n-k-1
        for j in 1:k-1
            if (i+j) % 2 != 0
                push!(seq, n + (k-1)*(i-1) + j)
            end
        end
    end

    for i in 1:n-k-1
        for j in 1:k-1
            if (i+j) % 2 == 0
                push!(seq, n + (k-1)*(i-1) + j)
            end
        end
    end

    return seq
end