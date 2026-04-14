
# positive cyclic shift of x by s. 
# x is interpreted as number with n bits. expects 0 <= s <= n.
# combine with mod1 for arbitrary input.
function myBitrotate(x::Integer, s::Int, n::Int)
    ( (x << s) | (x >> (n-s)) ) & (1 << n -1)
end

function label_to_string(label::Integer, n::Int)
    res = ""

    for i in 0:n-1
        if (label & (1 << i)) != 0
            res *= "$(i+1)"
        end
    end

    return res
end

function label_to_array(label::Integer, n::Int)
    res = Vector{Int}(undef, count_ones(label))

    x = 1
    for i in 0:n-1
        if (label & (1 << i)) != 0
            @inbounds res[x] = i+1
            x += 1
        end
    end

    return res
end

function findindex(array::Vector, val)
    for i in 1:length(array)
        @inbounds array[i] == val && return i
    end

    return 0
end

@doc raw"""
    is_weakly_separated(n::Int, v::Vector{Int}, w::Vector{Int})

Test if two vectors `v` and `w` viewed as subsets of `{1 , ..., n}` are weakly separated.
"""
function is_weakly_separated(x::T, y::T) where T <: Integer
    a =  x & ~y
    b = ~x &  y 

    ( (one(T) << trailing_zeros(a) -1) | (one(T) << leading_zeros(one(T)) >> leading_zeros(a)) ) & b === b  &&  return true
    ( (one(T) << trailing_zeros(b) -1) | (one(T) << leading_zeros(one(T)) >> leading_zeros(b)) ) & a === a  &&  return true
 
    return false
end

@doc raw"""
    is_weakly_separated(labels::Vector{Vector{Int}})

Test if the elements of `labels` are pairwise weakly separated.
"""
function is_weakly_separated(labels::Vector{T}) where T <: Integer
    len = length(labels)
    
    for i = 1:len-1
        for j = i+1:len
            @inbounds is_weakly_separated(labels[i], labels[j]) || return false
        end
    end

    return true
end

# expects 0 <= i <= n.
@doc raw"""
    frozen_label(k::Int, n::Int, i::Int)

Return the `i-th` frozen label.
"""
function frozen_label(k::Int, n::Int, i::Int, T::Type = Int)
    # originally[i-k+1,i]. Now [i+1, i+k]. aka shifted by k. 
    myBitrotate( one(T) << k -1, i, n)
end


@doc raw"""
    super_potential_label(k, n, i)

Return the `i-th` (left) label of the superpotential.
"""
function super_potential_label(k::Int, n::Int, i::Int, T::Type = Int) 
    # originally i-k cup [i-k+2,i]. Now i+1 cup [i+3, i+k+1]. aka shifted by k+1.
    myBitrotate( T(2) << k -3, i, n)
end

@doc raw"""
    rec_label(k::Int, n::Int, i::Int, j::Int)

Return the label of the rectangle graph in row `i`
and column `j`. 
"""
# expects 0 <= i <= n-k and 0 <= j <= k
function rec_label(k::Int, n::Int, i::Int, j::Int, T::Type = Int) # [i+1,i+j] cup [n-k+j+1, n]
    ( (one(T) << j -1) << i ) | ( (one(T) << (k-j) -1) << (n-k+j) )
end

@doc raw"""
    check_label(k::Int, n::Int, i::Int, j::Int)

Return the label of the checkboard graph in row `i`
and column `j`. 
"""
# expects 0 <= i <= n-k and 0 <= j <= k
function check_label(k::Int, n::Int, i::Int, j::Int, T::Type = Int)
    y = cld(i+j, 2)
    myBitrotate(rec_label(k, n, i, j), n-y, n)
end

@doc raw"""
    drec_label(k::Int, n::Int, i::Int, j::Int)

Return the label of the dual rectangle graph in row `i`
and column `j`. 
"""
# expects 0 <= j <= n-k and 0 <= i <= k. NOTE THE SWAP!
# n is an unnecessary argument, only included for consistency.
function drec_label(k::Int, n::Int, i::Int, j::Int, T::Type = Int) 
    (one(T) << i -1) | ( (one(T) << (k-i) -1) << (i+j))
end

@doc raw"""
    dcheck_label(k::Int, n::Int, i::Int, j::Int)

Return the label of the dual checkboard graph in row `i`
and column `j`. 
"""
function dcheck_label(k::Int, n::Int, i::Int, j::Int, T::Type = Int) 
    y = cld(i+j, 2)
    myBitrotate(drec_label(k, n, i, j), n-y, n)
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
    rec_labels(k::Int, n::Int)

Return the labels of the rectangle graph as a vector. 
The frozen labels are in positions `1` to `n`.
"""
function rec_labels(k::Int, n::Int, T::Type = Int) 
    N = k*(n-k)+1
    res = Vector{T}(undef, N)

    for i in 1:n
        @inbounds res[i] = frozen_label(k, n, i, T)
    end

    for i in 1:n-k-1
        for j in 1:k-1
            @inbounds res[n+(i-1)*(k-1) + j] = rec_label(k, n, i, j, T)
        end
    end

    return res
end

@doc raw"""
    check_labels(k::Int, n::Int)

Return the labels of the checkboard graph as a vector. 
The frozen labels are in positions `1` to `n`.
"""
function check_labels(k::Int, n::Int, T::Type = Int) 
    N = k*(n-k)+1
    res = Vector{T}(undef, N)
    
    for i in 1:n
        @inbounds res[i] = frozen_label(k, n, i, T)
    end

    for i in 1:n-k-1
        for j in 1:k-1
            @inbounds res[n+(i-1)*(k-1) + j] = check_label(k, n, i, j, T)
        end
    end

    return res
end
@doc raw"""
    drec_labels(k::Int, n::Int)

Return the labels of the dual-rectangle graph as a vector. 
The frozen labels are in positions `1` to `n`.
"""
function drec_labels(k::Int, n::Int, T::Type = Int)
    N = k*(n-k)+1
    res = Vector{T}(undef, N)

    for i in 1:n
        @inbounds res[i] = frozen_label(k, n, i, T)
    end

    for j in 1:n-k-1
        for i in 1:k-1
            @inbounds res[n+(i-1)*(n-k-1) + j] = drec_label(k, n, i, j, T)
        end
    end

    return res
end

@doc raw"""
    dcheck_labels(k::Int, n::Int)

Return the labels of the dual-checkboard graph as a vector. 
The frozen labels are in positions `1` to `n`.
"""
function dcheck_labels(k::Int, n::Int, T::Type = Int)
    N = k*(n-k)+1
    res = Vector{T}(undef, N)

    for i in 1:n
        @inbounds res[i] = frozen_label(k, n, i, T)
    end
    
    for j in 1:n-k-1
        for i in 1:k-1
            @inbounds res[n+(i-1)*(n-k-1) + j] = dcheck_label(k, n, i, j, T)
        end
    end

    return res
end

#### some helper functions ####

function label_positions!(labels::Vector{T}, clique::Vector{T}) where T <: Integer
    for i in 1:length(clique)
        @inbounds clique[i] = findindex(labels, clique[i])
    end
end

function _add_two!(V::Vector{T}, a::T, b::T) where T
    a in V || push!(V, a)
    b in V || push!(V, b)
end

@doc raw"""
    compute_cliques(labels::Vector{Vector{Int}})

Return the non trivial black and white cliques of the weakly separated collection 
whose elements are given by `labels`.
"""
function compute_cliques(labels::Vector{T}) where T <: Integer
    N = length(labels)
    @inbounds k = count_ones(labels[1])
    W = Dict{T, Vector{T}}()
    B = Dict{T, Vector{T}}()

    sizehint!(W, 2*N)
    sizehint!(B, 2*N)

    # compute white and black cliques
    for i = 1:N-1
        for j = i+1:N

            @inbounds K = labels[i] & labels[j]
            if count_ones(K) == k-1 

                # labels[i] and labels[j] belong to W[K]
                index = Base.ht_keyindex(W, K)
                @inbounds index < 0 ? W[K] = [labels[i], labels[j]] : _add_two!(W.vals[index], labels[i], labels[j])

                # labels[i] and labels[j] also belong to B[L]
                L = labels[i] | labels[j]
                index = Base.ht_keyindex(B, L)
                @inbounds index < 0 ? B[L] = [labels[i], labels[j]] : _add_two!(B.vals[index], labels[i], labels[j])
            end

        end
    end
    
    # remove trivial cliques
    filter!( p -> length(p.second) > 2, W)
    filter!( p -> length(p.second) > 2, B)

    for C in values(W) label_positions!(labels, sort!(C)) end
    for C in values(B) label_positions!(labels, sort!(C)) end

    return W, B
end

@doc raw"""
    compute_cliques(labels::Vector{Vector{Int}}, quiver::SimpleDiGraph{Int})

Return the non trivial black and white cliques of the weakly separated collection 
whose elements are given by `labels` and whose adjacencies are encoded in `quiver`.
"""
function compute_cliques(labels::Vector{T}, quiver::SimpleDiGraph{T}) where T <: Integer
    W = Dict{T, Vector{T}}()
    B = Dict{T, Vector{T}}()

    sizehint!(W, ne(quiver))
    sizehint!(B, ne(quiver))

    for e in edges(quiver)
        i, j = src(e), dst(e)

        # labels[i] and labels[j] belong to W[K]
        @inbounds K = labels[i] & labels[j]
        index = Base.ht_keyindex(W, K)
        @inbounds index < 0 ? W[K] = [labels[i], labels[j]] : _add_two!(W.vals[index], labels[i], labels[j])

        # labels[i] and labels[j] also belong to B[L]
        @inbounds L = labels[i] | labels[j]
        index = Base.ht_keyindex(B, L)
        @inbounds index < 0 ? B[L] = [labels[i], labels[j]] : _add_two!(B.vals[index], labels[i], labels[j])
    end

    # there are no trivial cliques generated this way

    for C in values(W) label_positions!(labels, sort!(C)) end
    for C in values(B) label_positions!(labels, sort!(C)) end

    return W, B
end

#### helper functions ####

function add_clique_edges!(Q::SimpleDiGraph{T}, C::Vector{T}, n) where T <: Integer
    len = length(C)

    for l = 1:len-1
        @inbounds (C[l] > n || C[l+1] > n) && add_edge!(Q, C[l], C[l+1])
    end

    @inbounds (C[len] > n || C[1] > n) && add_edge!(Q, C[len], C[1])
end

# TODO update docstring
@doc raw"""
    compute_quiver(n::Int, labels::Vector{T}, W) where T <: Integer

Compute the face boundaries of the weakly separated collection with elements given 
by `labels` and adjacency graph `quiver`.
"""
function compute_quiver(n::Int, labels::Vector{T}, W) where T <: Integer
    N = length(labels)
    Q = SimpleDiGraph{T}(N)

    # add edges for non trivial white cliques
    for C in values(W)
        add_clique_edges!(Q, C, n)
    end

    # dont add edges for black cliques to avoid 2-cycles

    return Q
end

# TODO update docstring. also does not work because of @lazy...
# @doc raw"""
#     @lazy WSCollection
#
# An abstract 2-dimensional cell complex living inside the matriod of `k-sets` in `{1, ..., n}`. 
# Its vertices are labelled by elements of `labels` while `quiver` encodes adjacencies 
# between the vertices. 
# The 2-cells are colored black or white and contained in `blackCliques` and `whiteCliques`.
#
# # Attributes
# - `k::Int`
# - `n::Int`
# - `labels::Vector{Vector{T}}`
# - `quiver::SimpleDiGraph{T}`
# - `whiteCliques::Dict{Vector{T}, Vector{T}}`
# - `blackCliques::Dict{Vector{T}, Vector{T}}`
#
# # Constructors
#     WSCollection(k::Int, n::Int, labels::Vector{Vector{T}}, 
#                 computeCliques::Bool = true, frozenFirst::Bool = true)

#     WSCollection(k::Int, n::Int, labels::Vector{Vector{T}}, quiver::SimpleDiGraph{T}, 
#                 computeCliques::Bool = true, frozenFirst::Bool = true)

#     WSCollection(C::WSCollection; computeCliques::Bool = true)
# """
@lazy mutable struct WSCollection{T <: Integer}
    k::Int
    n::Int
    labels::Vector{T}
    quiver::SimpleDiGraph{T}
    @lazy whiteCliques::Dict{T, Vector{T}}
    @lazy blackCliques::Dict{T, Vector{T}}
end


@doc raw"""
    cliques_init(C::WSCollection)

Return true if the cliques of 'C' are initialized. 
"""
function cliques_init(C::WSCollection)
    return isinit(C, :whiteCliques) && isinit(C, :blackCliques)
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
    WSCollection(k::Int, n::Int, labels::Vector{T}, 
                    keepCliques::Bool = true) where T <: Integer

Constructor of WSCollection. Adjacencies between its vertices as well as 2-cells are 
computed using only a set of vertex `labels`.

If `keepCliques` is set to false, the 2-cells will be disgarded.
"""
function WSCollection(k::Int, n::Int, labels::Vector{T}; 
                        keepCliques::Bool = false) where T <: Integer
                        
    W, B = compute_cliques(labels)
    Q = compute_quiver(n, labels, W)
    
    keepCliques && return WSCollection{T}(k, n, labels, Q, W, B)
    
    return WSCollection{T}(k, n, labels, Q, uninit, uninit)
end

# TODO update docstring
@doc raw"""
    WSCollection(k::Int, n::Int, labels::Vector{T}, quiver::SimpleDiGraph{T}, 
                    keepCliques::Bool = false) where T <: Integer

Constructor of WSCollection. The 2-cells are computed from vertex `labels` as well as the
their adjacencies encoded in `quiver`. Faster than just using labels most of the time.

If `keepCliques` is `false` the black and white 2-cells are disgarded.
"""
function WSCollection(k::Int, n::Int, labels::Vector{T}, quiver::SimpleDiGraph{T}; 
                        keepCliques::Bool = false) where T <: Integer

    if keepCliques
        W, B = compute_cliques(labels, quiver)
        return WSCollection{T}(k, n, labels, quiver, W, B)
    end
    
    return WSCollection{T}(k, n, labels, quiver, uninit, uninit)
end

@doc raw"""
    WSCollection(C::WSCollection; keepCliques::Bool = false)

Constructor of WSCollection. Computes 2-cells of `C` if the are empty, 
othererwise returns a deepcopy of `C`.

If `keepCliques` is `false` the black and white 2-cells are disgarded.
"""
function WSCollection(C::WSCollection; keepCliques::Bool = false)
    labels = copy(C.labels)
    Q = SimpleDiGraph(C.quiver)

    if keepCliques 
        W, B = compute_cliques(C.labels, C.quiver)
        return WSCollection(C.k, C.n, labels, Q, W, B)
    end

    return WSCollection(C.k, C.n, labels, Q, uninit, uninit)
end

function Base.deepcopy(C::WSCollection{T}) where T
    labels = copy(C.labels)
    Q = SimpleDiGraph(C.quiver)

    if cliques_init(C)
        W = Dict{T, Vector{T}}()
        B = Dict{T, Vector{T}}()
        sizehint!(W, length(C.whiteCliques))
        sizehint!(B, length(C.blackCliques))

        for (K, C) in C.whiteCliques W[K] = copy(C) end
        for (L, C) in C.blackCliques B[L] = copy(C) end

        return WSCollection(C.k, C.n, labels, Q, W, B)
    end

    return WSCollection(C.k, C.n, labels, Q, uninit, uninit)
end

@doc raw"""
    in(label::T, C::WSCollection{T}) where T <: Integer

Return true if `label` is occurs as label of `C`.
"""
Base.in(label, C::WSCollection) = label in C.labels

Base.lastindex(C::WSCollection) = lastindex(C.labels)

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

function sorted_unfrozen(C::WSCollection)
    return sort!(C[C.n+1:end])
end

function sorted_unfrozen!(C::WSCollection{T}, preloaded::Vector{T}) where T
    N = length(C)

    for i in C.n+1:N
        @inbounds preloaded[i-C.n] = C[i]
    end

    return sort!(preloaded)
end

@doc raw"""
    (==)(C1::WSCollection, C2::WSCollection)

Return true if the vertices of `C1` and `C2` contain the same labels.
The order of labels in each collection does not matter.
"""
function Base.:(==)(C1::WSCollection, C2::WSCollection)
    # TODO it may be worthwhile to compare a test sum first.
    # as this is most often gonna return false
    return sorted_unfrozen(C1) == sorted_unfrozen(C2)
end

Base.isequal(C1::WSCollection, C2::WSCollection) = isequal(sorted_unfrozen(C1), sorted_unfrozen(C2))

# TODO also hash WSCollection as a type, to differentiate from Vector{T}
Base.hash(C::WSCollection) = hash(sorted_unfrozen(C))

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
    union(C1::WSCollection, C2::WSCollection)

Return the union of labels in `C1` and `C2`.
"""
function Base.union(C1::WSCollection, C2::WSCollection)
    return union(C1.labels, C2.labels)
end


function Base.show(io::IO, C::WSCollection{T}) where T <: Integer
    s = "WSCollection{$T} of type ($(C.k), $(C.n)) with $(length(C)) labels."
    print(io, s)
end

function Base.print(C::WSCollection{T}; full::Bool = false) where T <: Integer
    s = "WSCollection{$T} of type ($(C.k), $(C.n)) with $(length(C)) labels"

    if full
        s *= ": \n"
        for l in C.labels
            s *= label_to_string(l, C.n)*"\n"
        end
    end
    print(s,".")
end


function Base.println(C::WSCollection; full::Bool = false)
    print(C; full)
    print("\n")
end

@doc raw"""
    check_collection(k::Int, n::Int, T::Type = Int)

Return the weakly separated collection corresponding to the checkboard graph.
""" 
function check_collection(k::Int, n::Int, T::Type = Int; keepCliques = false) # TODO use known quiver to speed up computation
    return WSCollection(k, n, check_labels(k, n, T); keepCliques = keepCliques)
end

@doc raw"""
    rec_collection(k::Int, n::Int, T::Type = Int)

Return the weakly separated collection corresponding to the rectangle graph.
""" 
function rec_collection(k::Int, n::Int, T::Type = Int; keepCliques = false) # TODO use known quiver to speed up computation
    return WSCollection(k, n, rec_labels(k, n, T); keepCliques = keepCliques)
end

@doc raw"""
    dcheck_collection(k::Int, n::Int, T::Type = Int)

Return the weakly separated collection corresponding to the dual-checkboard graph.
""" 
function dcheck_collection(k::Int, n::Int, T::Type = Int; keepCliques = false) # TODO use known quiver to speed up computation
    return WSCollection(k, n, dcheck_labels(k, n, T); keepCliques = keepCliques)
end

@doc raw"""
    drec_collection(k::Int, n::Int, T::Type = Int)

Return the weakly separated collection corresponding to the dual-rectangle graph.
""" 
function drec_collection(k::Int, n::Int, T::Type = Int; keepCliques = false) # TODO use known quiver to speed up computation
    return WSCollection(k, n, drec_labels(k, n, T); keepCliques = keepCliques)
end

@doc raw"""
    is_frozen(C::WSCollection, i::Integer)

Return true if the vertex `i` of `C` is frozen.
"""
function is_frozen(C::WSCollection, i::Integer) 
    return i <= C.n
end

@doc raw"""
    is_mutable(C::WSCollection, i::Integer) 

Return true if the vertex `i` of `C` is mutable.
"""
function is_mutable(C::WSCollection, i::Integer)
    return !is_frozen(C, i) && degree(C.quiver, i) == 4 
end

@doc raw"""
    get_mutables(C::WSCollection)

Return all mutable vertices of `C`.
"""
function get_mutables(C::WSCollection)
    n = C.n
    N = length(C)
    res = Vector{Int}(undef, N-n)

    j = 1
    for i in n+1:N
        degree(C.quiver, i) == 4 && (res[j] = i; j+=1)
    end

    return resize!(res, j-1)
end

# TODO more details
@doc raw"""
    get_mutables(C::WSCollection, preloaded::Vector{Int})

Collect all mutable vertices of `C` into the first 'num_mutables' entries of
'preloaded' and return 'num_mutables'. 
"""
function get_mutables!(C::WSCollection, preloaded)
    n = C.n
    N = length(C)

    j = 1
    for i in n+1:N
        degree(C.quiver, i) == 4 && (preloaded[j] = i; j+=1)
    end

    return j-1
end

#### helper functions #####

function my_has_edge(g::SimpleDiGraph{T}, s::T, d::T) where T
    @inbounds list = g.fadjlist[s]
    return d in list
end

function my_add_edge!(g::SimpleDiGraph{T}, s::T, d::T) where T
    
    @inbounds list = g.fadjlist[s]
    index = searchsortedfirst(list, d)
    insert!(list, index, d)

    g.ne += 1

    @inbounds list = g.badjlist[d]
    index = searchsortedfirst(list, s)
    insert!(list, index, s)

    return true  # edge successfully added
end

function my_rem_edge!(g::SimpleDiGraph{T}, s::T, d::T) where T
    
    @inbounds list = g.fadjlist[s]
    index = findindex(list, d)
    deleteat!(list, index)

    g.ne -= 1

    @inbounds list = g.badjlist[d]
    index = findindex(list, s)
    deleteat!(list, index)
    
    return true # edge successfully removed
end


function _reverse_square!(g::SimpleDiGraph, i, i1, i2, o1, o2)
    @inbounds(
        begin
            g.fadjlist[i][1] = i1
            g.fadjlist[i][2] = i2
            g.badjlist[i][1] = o1
            g.badjlist[i][2] = o2

            list = g.fadjlist[i1]
            index = findindex(list, i)
            deleteat!(list, index)

            list = g.badjlist[i1]
            index = searchsortedfirst(list, i)
            insert!(list, index, i)

            list = g.fadjlist[i2]
            index = findindex(list, i)
            deleteat!(list, index)

            list = g.badjlist[i2]
            index = searchsortedfirst(list, i)
            insert!(list, index, i)

            list = g.badjlist[o1]
            index = findindex(list, i)
            deleteat!(list, index)

            list = g.fadjlist[o1]
            index = searchsortedfirst(list, i)
            insert!(list, index, i)

            list = g.badjlist[o2]
            index = findindex(list, i)
            deleteat!(list, index)

            list = g.fadjlist[o2]
            index = searchsortedfirst(list, i)
            insert!(list, index, i)
        end
        
    )
    return true
end

function _merge_cliques!(X::Dict{T, Vector{T}}, Y::Dict{T, Vector{T}}, i, ind_adj, ind_opp) where T <: Integer
    @inbounds A = X.vals[ind_adj]
    l = findindex(A, i)
    @inbounds succ = A[mod1(l+1 ,3)]

    @inbounds O = Y.vals[ind_opp]
    l = findindex(O, succ)

    insert!(O, l, i)
    Base._delete!(X, ind_adj) # TODO this is depreceated and might be unnecessary in the newest julia version. 
end

function _split_clique!(X::Dict{T, Vector{T}}, Y::Dict{T, Vector{T}}, i, ind_adj, opp::T) where T <: Integer
    @inbounds A = X.vals[ind_adj]

    if length(A) == 3 # adjacent clique is trangle at the boundary. Just flip colors
        Y[opp] = A
        Base._delete!(X, ind_adj) # TODO this is depreceated and might be unnecessary in the newest julia version. 
    else # split off a triangle from the adjacent clique

        l = findindex(A, i)
        m = length(A)
        @inbounds Y[opp] = [ A[mod1(l-1, m)], i, A[mod1(l+1, m)] ]

        deleteat!(A, l)
    end
end

function _update_cliques!(x, y, i, C::WSCollection)
    @inbounds K = C[x] & C[y]
    @inbounds L = C[x] | C[y]

    ind_K = Base.ht_keyindex(C.whiteCliques, K)
    ind_L = Base.ht_keyindex(C.blackCliques, L)

    if @inbounds K & C[i] == K # K is contained in C[i], so K corresponds to adjacent clique, L to "opposite"
        
        if ind_L >= 0 # black cliqe also exists
            # adjacent clique is a triangle and must be merged with the opposite clique
            _merge_cliques!(C.whiteCliques, C.blackCliques, i, ind_K, ind_L)
        else
            # adjacent clique must be split into a triangle and another (possibly empty) clique
            _split_clique!(C.whiteCliques, C.blackCliques, i, ind_K, L)
        end

    else # now L corresponds to adjacent clique, K to "opposite"
        
        if ind_K >= 0
            _merge_cliques!(C.blackCliques, C.whiteCliques, i, ind_L, ind_K)
        else
            _split_clique!(C.blackCliques, C.whiteCliques, i, ind_L, K)
        end
    end
end

@doc raw"""
    mutate!(C::WSCollection, i::Integer; updateCliques::Bool = false)

Mutate the `C` in direction `i` if `i` is a mutable vertex of `C`.

If `updateCliques` is set to false, the 2-cells are disgarded.
"""
# TODO this does not check for mutability. make safe version
function mutate!(C::WSCollection{T}, i::Integer; updateCliques::Bool = false) where T <: Integer
    # is_mutable(C, i) || error("vertex $i with label $(label_to_string(C[i], C.n)) is not mutable!")
        
    Q = C.quiver
    @inbounds i1, i2 = Q.badjlist[i]
    @inbounds o1, o2 = Q.fadjlist[i]

    ##### update cliques #####
    
    if updateCliques && cliques_init(C)
        
        _update_cliques!(i1, o1, i, C)
        _update_cliques!(i1, o2, i, C)
        _update_cliques!(i2, o1, i, C)
        _update_cliques!(i2, o2, i, C)
        
    else
        C.whiteCliques = uninit
        C.blackCliques = uninit
    end

    ##### mutate quiver #####

    for j in (i1, i2) # add/remove edges according to quiver mutation
        for l in (o1, o2)
            if my_has_edge(Q, l, j)
                my_rem_edge!(Q, l, j)
            elseif !is_frozen(C, j) || !is_frozen(C, l)
                my_add_edge!(Q, j, l)
            end
        end
    end

    # reverse edges adjacent to i
    _reverse_square!(Q, i, i1, i2, o1, o2)

    ##### exchange label of i #####

    @inbounds C.labels[i] = xor( xor(C[i], C[i1]), C[i2])

    return C
end

@doc raw"""
    mutate(C::WSCollection, i::Int; updateCliques::Bool = true)

Version of `mutate!` that does not modify its arguments.
"""
function mutate(C::WSCollection, i::Integer; updateCliques::Bool = false)
    return mutate!( deepcopy(C), i, updateCliques)
end

# TODO add docstrings
function label(args...; type::Type{<:Integer} = Int)
    label = 0
    for i in args
        label += one(type) << (i-1)
    end

    return label
end

function label(a; type::Type{<:Integer} = Int)
    label = 0
    for i in a
        label += one(type) << (i-1)
    end

    return label
end

@doc raw"""
    mutate!(C::WSCollection, label::Vector{T}; updateCliques::Bool = true)

Mutate the `C` by addressing a vertex with its label.
"""
function mutate!(C::WSCollection{T}, args...; updateCliques::Bool = false) where T

    x = label(args...; type = T)
    i = findindex(C.labels, x)
    i == 0 && error("$label is not part of the collection")

    return mutate!(C, i, updateCliques)
end

@doc raw"""
    mutate(C::WSCollection, label::Vector{Int}, mutateCliques::Bool = true)

Mutate the `C` by addressing a vertex with its label, without modifying arguments.
"""
function mutate(C::WSCollection, label::Vector{Int}; updateCliques::Bool = true)
    return mutate!( deepcopy(C), label, updateCliques)
end

# TODO add docstring
function mutate!(C::WSCollection, label; updateCliques::Bool = false)
    return mutate!(C, label..., updateCliques = updateCliques)
end

@doc raw"""
    mutate(C::WSCollection, label::Vector{Int}, updateCliques::Bool = true)

Mutate the `C` by addressing a vertex with its label, without modifying arguments.
"""
function mutate(C::WSCollection, args...; updateCliques::Bool = false)
    return mutate!( deepcopy(C), args..., updateCliques = updateCliques)
end

# TODO add docstring
function mutate(C::WSCollection, label; updateCliques::Bool = false)
    return mutate!( deepcopy(C), label, updateCliques = updateCliques)
end

# TODO add docstring
function peek(C::WSCollection, i::Integer)
    @inbounds i1, i2 = C.quiver.badjlist[i]
    @inbounds xor( xor(C[i], C[i1]), C[i2])
end


function apply_to_collection!(f::Function, C::WSCollection, swap = false) # WSCollection{T}, f: T -> T
    
    # apply to labels
    for i in 1:length(C)
        @inbounds C.labels[i] = f(C[i])
    end

    if cliques_init(C)
        W2 = Dict{T, Vector{T}}()
        B2 = Dict{T, Vector{T}}()
        sizehint!(W2, length(C.whiteCliques))
        sizehint!(B2, length(C.blackCliques))
        
        # apply to clique keys
        for (K, C) in C.whiteCliques
            W2[f(K)] = C
        end

        for (L, C) in C.blackCliques
            B2[f(L)] = C
        end

        if swap
            C.whiteCliques = B2
            C.blackCliques = W2
            C.k = C.n - C.k
        else
            C.whiteCliques = W2
            C.blackCliques = B2
        end
    end 

    return C
end

@doc raw"""
    rotate!(C::WSCollection, amount::Int = 1)

Rotate `C` by `amount`, where a positive amount indicates a clockwise rotation.
"""
function rotate!(C::WSCollection, amount::Int = 1)
    f = x -> myBitrotate(x, mod1(amount, C.n), C.n) 
    return apply_to_collection!(f, C)
end

@doc raw"""
    rotate(C::WSCollection, amount::Int = 1)

Rotate `C` by `amount`, where a positive amount indicates a clockwise rotation.
Does not change its input.
"""
function rotate(C::WSCollection, amount::Int = 1)
    return rotate!(deepcopy(C), amount)
end

function reverse_bits(x::Integer, n)
    res = zero(T)
    for i in 1:n
        res <<= 1
        res |= (x & 1)
        x >>= 1
    end
    return res
end

@doc raw"""
    mirror!(C::WSCollection)

Reflect `C` by letting the permutation `p(x) = 1 - x` interpreted modulo 
`n = C.n` act on the labels of `C`.
"""
function mirror!(C::WSCollection) 
    f = x -> reverse_bits(x, C.n)
    return apply_to_collection!(f, C)
end

@doc raw"""
    mirror(C::WSCollection)

Reflect `C` by letting the permutation `p(x) = 1 - x` interpreted modulo 
`n = C.n` act on the labels of `C`. Does not change its input.
"""
function mirror(C::WSCollection)
    return mirror!(deepcopy(C))
end

function complement(x::T, n::Int) where T <: Integer
    return ~x & (one(T) << n  -1)
end

@doc raw"""
    complements!(C::WSCollection) 

Return the collection whose labels are complementary to those of `C`.
"""
function complements!(C::WSCollection{T}) where T <: Integer
    f = x-> ~x & (one(T) << C.n  -1)
    return apply_to_collection!(f, C, true)
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

    f = x-> myBitrotate(~x & (one(T) << C.n  -1), C.k, C.n)
    return apply_to_collection!(f, C, true)
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

# from https://graphics.stanford.edu/~seander/bithacks.html#NextBitPermutation
@inline function next_combination(x::T) where T <: Integer
    t = x | (x-one(T))
    return (t+one(T)) | (((~t & -~t) - one(T)) >>> (trailing_zeros(x) + one(T)))
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
function extend_weakly_separated!(k::Int, n::Int, labels1::Vector{T}, 
                                                  labels2::Vector{T} = Vector{T}()) where T <: Integer
    max = k*(n-k)+1

    # enforce frozen labels in the first n positions
    frozen = frozen_labels(k, n, T)
    labels1 = union(frozen, labels1)

    for v in labels2
        if !(v in labels1)
            is_weakly_separated(push!(labels1, v)) || pop!(labels1)
        end

        length(labels1) == max && return labels1
    end

    v = frozen[n]

    while v < frozen[n-k]

        if !(v in labels1)
            is_weakly_separated(push!(labels1, v)) || pop!(labels1)
        end

        length(labels1) == max && return labels1

        v = next_combination(v)
    end
    
    return labels1
end


@doc raw"""
    extend_to_collection(k::Int, n::Int, labels1::Vector{Vector{Int}}, 
                                         labels2::Vector{Vector{Int}})

Return a maximal weakly separated collection containing all elements of `labels1`.
Use elements of `labels2` if possible.
"""
function extend_to_collection(k::Int, n::Int, labels1::Vector{T}, 
                                              labels2::Vector{T} = Vector{T}()) where T <: Integer

    return WSCollection(k, n, extend_weakly_separated!(k, n, copy(labels1), labels2))
end

@doc raw"""
    extend_to_collection(label::T, C::WSCollection{T}) where T <: Integer

Return a maximal weakly separated collection containing `label`.
Use labels of `C` if possible.
"""
function extend_to_collection(label::T, C::WSCollection{T}) where T <: Integer

    L = extend_weakly_separated!(C.k, C.n, [label], C.labels)
    return WSCollection(C.k, C.n, L)
end

@doc raw"""
    extend_to_collection(labels::Vector{T}, C::WSCollection{T}) where T <: Integer

Return a maximal weakly separated collection containing all elements of `labels`.
Use labels of `C` if possible.
"""
function extend_to_collection(labels::Vector{T}, C::WSCollection{T}) where T <: Integer

    L = extend_weakly_separated!(C.k, C.n, copy(labels), C.labels)
    return WSCollection(C.k, C.n, L)
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