
# return a mod b as element in {1, ..., b}
function pmod(a::T, b::T) where T <: Integer
    c = a % b
    return c > 0 ?  c : c+b
end

@doc raw"""
    is_weakly_separated(n::Int, v::Vector{Int}, w::Vector{Int})

Test if two vectors `v` and `w` viewed as subsets of `{1 , ..., n}` are weakly separated.
"""
function is_weakly_separated(n, v::Vector{T}, w::Vector{S}) where {T, S <: Integer}
    x = setdiff(v, w)
    y = setdiff(w, v)
    i = 1
    
    # the following trys to finds a < b < c < d contradicting the the ws of v and w
    while !(i in x) && !(i in y) 
        i += 1
        if i+3 > n
            return true
        end
    end
            
    if i in y
        (x, y) = (y, x)
    end
    
    while !(i in y)
        i += 1
        if i+2 > n
            return true
        end
    end
    
    while !(i in x) 
        i += 1
        if i+1 > n
            return true
        end
    end
    
    while !(i in y) 
        i += 1
        if i > n
            return true
        end
    end
    # if we get here, a, b, c, d have been found so v and w are not weakly separated
    return false
end

@doc raw"""
    is_weakly_separated(n::Int, labels::Vector{Vector{Int}})

Test if the vectors contained in `labels` are pairwise weakly separated.
"""
function is_weakly_separated(n, labels::Vector{Vector{T}}) where T <: Integer
    len = length(labels)
    for i = 1:len-1
        for j = i+1:len
            if !is_weakly_separated(n, labels[i], labels[j])
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
function frozen_label(k, n, i, type = Int)
    return sort!([type(pmod(l+i, n)) for l = 1-k:0])
end


@doc raw"""
    super_potential_label(k, n, i)

Return the `i-th` (left) label of the superpotential.
"""
function super_potential_label(k, n, i, type = Int)
    super = [type(pmod(l+i, n)) for l = 1-k:0]
    super[1] = type(pmod(i-k, n))
    sort!(super)
    
    return super
end

@doc raw"""
    rectangle_label(k::Int, n::Int, i::Int, j::Int)

Return the label of the rectangle graph in row `i`
and column `j`. 
"""
function rectangle_label(k, n, i, j, type = Int)
    L = collect(type, i+1:i+j)
    R = collect(type, n-k+j+1:n)
    return union!(L, R)
end

@doc raw"""
    checkboard_label(k::Int, n::Int, i::Int, j::Int)

Return the label of the checkboard graph in row `i`
and column `j`. 
"""
function checkboard_label(k, n, i, j, type = Int)
    
    sigma_ij = let (n, y) = ( type(n), type(ceil((i+j)/2)) )
        x -> pmod(x - y, n)
    end

    L = sigma_ij.(collect(type, i+1:i+j))
    R = sigma_ij.(collect(type, n-k+j+1:n))
    return sort!(union!(L, R))
end

@doc raw"""
    dual_rectangle_label(k::Int, n::Int, i::Int, j::Int)

Return the label of the dual rectangle graph in row `i`
and column `j`. 
"""
function dual_rectangle_label(k, n, i, j, type = Int)
    L = collect(type, 1:i)
    R = collect(type, i+j+1:k+j)
    return union!(L, R)
end

@doc raw"""
    dual_checkboard_label(k::Int, n::Int, i::Int, j::Int)

Return the label of the dual checkboard graph in row `i`
and column `j`. 
"""
function dual_checkboard_label(k, n, i, j, type = Int)
    
    sigma_ij = let (n, y) = ( type(n), type(ceil((i+j)/2)) )
        x -> pmod(x - y, n)
    end

    L = sigma_ij.( collect(type, 1:i))
    R = sigma_ij.( collect(type, i+j+1:k+j))
    return sort!(union!(L, R))
end

@doc raw"""
    frozen_labels(k::Int, n::Int)

Return the frozen labels as a vector.
"""
function frozen_labels(k, n, type = Int)
    return [frozen_label(k, n, i, type) for i in 1:n]
end

function super_potential_labels(k, n, type = Int)
    return [super_potential_label(k, n, i, type) for i in 1:n]
end

@doc raw"""
    rectangle_labels(k::Int, n::Int)

Return the labels of the rectangle graph as a vector. 
The frozen labels are in positions `1` to `n`.
"""
function rectangle_labels(k, n, type = Int)
    
    # frozen labels first
    labels = frozen_labels(k, n, type)
    
    for i = 1:n-k-1 # mutable labels
        for j = 1:k-1
            push!(labels, rectangle_label(k, n, i, j, type))
        end
    end

    return labels
end

@doc raw"""
    checkboard_labels(k::Int, n::Int)

Return the labels of the checkboard graph as a vector. 
The frozen labels are in positions `1` to `n`.
"""
function checkboard_labels(k, n, type = Int)

    # frozen labels first
    labels = frozen_labels(k, n, type)

    for i = 1:n-k-1 # mutable labels
        for j = 1:k-1
            push!(labels, checkboard_label(k, n, i, j, type))
        end
    end

    return labels
end

@doc raw"""
    dual_rectangle_labels(k::Int, n::Int)

Return the labels of the dual-rectangle graph as a vector. 
The frozen labels are in positions `1` to `n`.
"""
function dual_rectangle_labels(k, n, type = Int)
    
    # frozen labels first
    labels = frozen_labels(k, n, type)

    for i = 1:k-1 # mutable labels
        for j = 1:n-k-1
            push!(labels, dual_rectangle_label(k, n, i, j, type))
        end
    end

    return labels
end

@doc raw"""
    dual_checkboard_labels(k::Int, n::Int)

Return the labels of the dual-checkboard graph as a vector. 
The frozen labels are in positions `1` to `n`.
"""
function dual_checkboard_labels(k, n, type = Int)
    
    # frozen labels first
    labels = frozen_labels(k, n, type)

    for i = 1:k-1 # mutable labels
        for j = 1:n-k-1
            push!(labels, dual_checkboard_label(k, n, i, j, type))
        end
    end

    return labels
end

@doc raw"""
    compute_cliques(labels::Vector{Vector{Int}})

Return the non trivial black and white cliques of the weakly separated collection 
whose elements are given by `labels`.
"""
function compute_cliques(labels::Vector{Vector{T}}) where T <: Integer
    N = length(labels)
    k = length(labels[1])
    W::Dict{Vector{T}, Vector{Vector{T}}} = Dict()
    B::Dict{Vector{T}, Vector{Vector{T}}} = Dict()

    # compute white and black cliques
    for i = 1:N-1
        for j = i+1:N

            K = intersect(labels[i], labels[j])
            if length(K) == k-1 # labels[i] and labels[j] belong to W[K]

                if haskey(W, K) 
                    union!(W[K], [labels[i], labels[j]])
                else
                    W[K] = [labels[i], labels[j]]
                end

                L = sort!(union(labels[i], labels[j])) # labels[i] and labels[j] also belong to B[L]
                if haskey(B, L) 
                    union!(B[L], [labels[i], labels[j]])
                else
                    B[L] = [labels[i], labels[j]]
                end

            end

        end
    end
    
    for (K, C) in W # remove trivial cliques
        if length(C) < 3
            delete!(W, K)
        end
    end

    for (L, C) in B
        if length(C) < 3
            delete!(B, L)
        end
    end 

    return W, B
end

@doc raw"""
    compute_cliques(labels::Vector{Vector{Int}}, quiver::SimpleDiGraph{Int})

Return the non trivial black and white cliques of the weakly separated collection 
whose elements are given by `labels` and whose adjacencies are encoded in `quiver`.
"""
function compute_cliques(labels::Vector{Vector{T}}, quiver::SimpleDiGraph{T}) where T <: Integer
    W::Dict{Vector{T}, Vector{Vector{T}}} = Dict()
    B::Dict{Vector{T}, Vector{Vector{T}}} = Dict()

    for e in edges(quiver)
        i, j = src(e), dst(e)
        K = intersect(labels[i], labels[j])
        L = sort!(union(labels[i], labels[j]))

        if haskey(W, K) 
            union!(W[K], [labels[i], labels[j]])
        else
            W[K] = [labels[i], labels[j]]
        end

        if haskey(B, L) 
            union!(B[L], [labels[i], labels[j]])
        else
            B[L] = [labels[i], labels[j]]
        end
    end

    for (K, C) in W # remove trivial cliques
        if length(C) < 3
            delete!(W, K)
        end
    end

    for (L, C) in B
        if length(C) < 3
            delete!(B, L)
        end
    end 

    return W, B
end

# given the boundary of a clique, add edges (if not both vertices are frozen)
function add_edges!(Q::SimpleDiGraph{T}, C::Vector{T}, n) where T <: Integer

    for l = 1:length(C)-1
        i, j = C[l], C[l+1]
        if i > n || j > n
            add_edge!(Q, i, j)
        end
    end

    l = length(C)
    i, j = C[l], C[1]
    if i > n || j > n
        add_edge!(Q, i, j)
    end
end

@doc raw"""
    compute_adjacencies(n::Int, labels::Vector{Vector{Int}}) 

Compute the adjacency graph and face boundaries of the weakly separated collection 
with elements given by `labels`.
"""
function compute_adjacencies(n, labels::Vector{Vector{T}}) where T <: Integer
    N = length(labels)
    W, B = compute_cliques(labels)

    positions = let labelPos = Dict(labels[i] => i for i = one(T):T(N)) # memorize positions of labels
        c -> labelPos[c]
    end

    Q = SimpleDiGraph{T}(N)
    W2::Dict{Vector{T}, Vector{T}} = Dict()
    B2::Dict{Vector{T}, Vector{T}} = Dict()

    for K in keys(W) # compute boundary and add edges for non trivial white cliques
        minus_K = let K = K
            x -> setdiff(x, K)
        end
        p = sortperm(minus_K.(W[K]))

        W2[K] = (positions.(W[K]))[p]

        add_edges!(Q, W2[K], n)
    end

    for L in keys(B) # compute boundary for non trivial black cliques (dont add edges here to avoid 2-cycles)
        L_minus = let L = L
            x -> setdiff(L, x)
        end
        p = sortperm(L_minus.(B[L]))

        B2[L] = positions.(B[L])[p]
    end

    return Q, W2, B2
end

@doc raw"""
    compute_boundaries(labels::Vector{Vector{Int}}, quiver::SimpleDiGraph{Int})

Compute the face boundaries of the weakly separated collection with elements given 
by `labels` and adjacency graph `quiver`.
"""
function compute_boundaries(labels::Vector{Vector{T}}, quiver::SimpleDiGraph{T}) where T <: Integer
    N = length(labels)
    W, B = compute_cliques(labels, quiver)

    positions = let labelPos = Dict(labels[i] => i for i = one(T):T(N)) # memorize positions of labels
        c -> labelPos[c]
    end
    
    W2::Dict{Vector{T}, Vector{T}} = Dict()
    B2::Dict{Vector{T}, Vector{T}} = Dict()

    for K in keys(W) # compute boundary 
        minus_K = let K = K
            x -> setdiff(x, K)
        end
        p = sortperm(minus_K.(W[K]))

        W2[K] = (positions.(W[K]))[p]
    end

    for L in keys(B) # compute boundary
        L_minus = let L = L
            x -> setdiff(L, x)
        end
        p = sortperm(L_minus.(B[L]))

        B2[L] = positions.(B[L])[p]
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
- `labels::Vector{Vector{Int}}`
- `quiver::SimpleDiGraph{Int}`
- `whiteCliques::Union{Missing, Dict{Vector{Int}, Vector{Int} }}`
- `blackCliques::Union{Missing, Dict{Vector{Int}, Vector{Int} }}`

# Constructors
    WSCollection(k::Int, n::Int, labels::Vector{Vector{Int}}, computeCliques::Bool = true)
    WSCollection(k::Int, n::Int, labels::Vector{Vector{Int}}, quiver::SimpleDiGraph{Int}, 
                                                              computeCliques::Bool = true)
    WSCollection(collection::WSCollection; computeCliques::Bool = true)
"""
mutable struct WSCollection{T <: Integer}
    k::T
    n::T
    labels::Vector{Vector{T}}
    quiver::SimpleDiGraph{T}
    whiteCliques::Dict{Vector{T}, Vector{T}}
    blackCliques::Dict{Vector{T}, Vector{T}}
end

@doc raw"""
    WSCollection(k::Int, n::Int, labels::Vector{Vector{Int}}, computeCliques::Bool = true)

Constructor of WSCollection. Adjacencies between its vertices as well as 2-cells are 
computed using only a set of vertex `labels`.

If `computeCliques` is set to false, the 2-cells will be left empty.
"""
function WSCollection(k, n, labels::Vector{Vector{T}}; computeCliques::Bool = true) where T <: Integer
    # TODO enfore frozen labels first
    Q, W, B = compute_adjacencies(n, labels)

    if computeCliques 
        return WSCollection{T}(k, n, deepcopy(labels), Q, W, B)
    else
        return WSCollection{T}(k, n, deepcopy(labels), Q, Dict{Vector{T}, Vector{T}}(), Dict{Vector{T}, Vector{T}}())
    end
end

@doc raw"""
    WSCollection(k::Int, n::Int, labels::Vector{Vector{Int}}, quiver::SimpleDiGraph{Int}, 
    computeCliques::Bool = true)

Constructor of WSCollection. The 2-cells are computed from vertex `labels` as well as the
their adjacencies encoded in `quiver`. Faster than just using labels most of the time.

If `computeCliques` is `false` the black and white 2-cells are are left empty instead.
"""
function WSCollection(k, n, labels::Vector{Vector{T}}, quiver::SimpleDiGraph{T}; computeCliques::Bool = true) where T <: Integer
    k, n = T(k), T(n)
    # TODO enfore frozen labels first
    if !computeCliques
        return WSCollection{T}(k, n, deepcopy(labels), deepcopy(quiver), Dict{Vector{T}, Vector{T}}(), Dict{Vector{T}, Vector{T}}())
    else
        W, B = compute_boundaries(labels, quiver)
        return WSCollection{T}(k, n, deepcopy(labels), deepcopy(quiver), W, B)
    end
end

@doc raw"""
    WSCollection(collection::WSCollection; computeCliques::Bool = true)

Constructor of WSCollection. Computes 2-cells of `collection` if the are empty, 
othererwise returns a deepcopy of `collection`.

If `computeCliques` is `false` the black and white 2-cells are left empty instead.
"""
function WSCollection(collection::WSCollection{T}; computeCliques::Bool = true) where T <: Integer
    if !computeCliques
        return WSCollection{T}(collection.k, collection.n, deepcopy(collection.labels), deepcopy(collection.quiver), 
                            Dict{Vector{T}, Vector{T}}(), Dict{Vector{T}, Vector{T}}())
    else
        if isempty(collection.whiteCliques) || isempty(collection.blackCliques)
            W, B = compute_boundaries(collection.labels, collection.quiver)
            return WSCollection{T}(collection.k, collection.n, deepcopy(collection.labels), deepcopy(collection.quiver), W, B)
        else
            return deepcopy(collection)
        end
    end
end

@doc raw"""
    (==)(collection1::WSCollection, collection2::WSCollection)

Return true if the vertices of `collection1` and `collection2` share the same labels.
The order of labels in each collection does not matter.
"""
function Base.:(==)(collection1::WSCollection, collection2::WSCollection)
    return sort(collection1.labels) == sort(collection2.labels)
end


Base.hash(collection::WSCollection) = hash(sort(collection.labels))


@doc raw"""
    in(label::Vector{Int}, collection::WSCollection)

Return true if `label` is occurs as label of `collection`.
"""
Base.in(label::Vector{T}, collection::WSCollection{T}) where T <: Integer = label in collection.labels

@doc raw"""
    getindex(collection::WSCollection, inds...)

Return the subset of the labels in `collection` specified `inds` in `collection.labels`.
"""
Base.getindex(collection::WSCollection, inds...) = getindex(collection.labels, inds...)

@doc raw"""
    setindex!(collection::WSCollection{T}, x::Vector{T}, ind)

Set the element at index `i` in `collection.labels` to `x`.
"""
Base.setindex!(collection::WSCollection{T}, x::Vector{T}, ind) where T <: Integer = setindex!(collection.labels, x, ind)

@doc raw"""
    setindex!(collection::WSCollection{T}, X::Vector{Vector{T}}, inds...)

Store the elements from X withing the subset of `collection` specified by `inds`.
"""
Base.setindex!(collection::WSCollection{T}, X::Vector{Vector{T}}, inds...) where T <: Integer = setindex!(collection.labels, X, inds...)

@doc raw"""
    length(collection::WSCollection)

Return the length of `collection.labels`.
"""
Base.length(collection::WSCollection) = length(collection.labels)

@doc raw"""
    cliques_empty(collection::WSCollection)

Return true if the white or black cliques in `collection` are empty. 
"""
function cliques_empty(collection::WSCollection)
    return isempty(collection.whiteCliques) || isempty(collection.blackCliques)
end

@doc raw"""
    intersect(collection1::WSCollection, collection2::WSCollection)

Return the common labels of `collection1` and `collection2`.
"""
function Base.intersect(collection1::WSCollection, collection2::WSCollection)
    return intersect(collection1.labels, collection2.labels)
end

@doc raw"""
    setdiff(collection1::WSCollection, collection2::WSCollection)

Return the labels of `collection1` minus the labels of `collection2`.
"""
function Base.setdiff(collection1::WSCollection, collection2::WSCollection)
    return setdiff(collection1.labels, collection2.labels)
end

@doc raw"""
    setdiff(collection1::WSCollection, collection2::WSCollection)

Return the union of labels in `collection1` and `collection2`.
"""
function Base.union(collection1::WSCollection, collection2::WSCollection)
    return union(collection1.labels, collection2.labels)
end


function Base.show(io::IO, collection::WSCollection{T}) where T <: Integer
    s = "WSCollection{$T} of type ($(collection.k), $(collection.n)) with $(length(collection)) labels"
    print(io, s)
end

function Base.print(collection::WSCollection{T}; full::Bool = false) where T <: Integer
    s = "WSCollection{$T} of type ($(collection.k), $(collection.n)) with $(length(collection)) labels"

    if full
        s *= ": \n"
        for l in collection.labels
            s *= "$l\n"
        end
    end
    print(s)
end


function Base.println(collection::WSCollection; full::Bool = false)
    print(collection; full)
    print("\n")
end

@doc raw"""
    checkboard_collection(k::Int, n::Int)

Return the weakly separated collection corresponding to the checkboard graph.
""" 
function checkboard_collection(k, n, type = Int) # TODO use known quiver to speed up computation
    return WSCollection(k, n, checkboard_labels(k, n, type))
end

@doc raw"""
    rectangle_collection(k::Int, n::Int)

Return the weakly separated collection corresponding to the rectangle graph.
""" 
function rectangle_collection(k, n, type = Int) # TODO use known quiver to speed up computation
    return WSCollection(k, n, rectangle_labels(k, n, type))
end

@doc raw"""
    dual_checkboard_collection(k::Int, n::Int)

Return the weakly separated collection corresponding to the dual-checkboard graph.
""" 
function dual_checkboard_collection(k, n, type = Int) # TODO use known quiver to speed up computation
    return WSCollection(k, n, dual_checkboard_labels(k, n, type))
end

@doc raw"""
    dual_rectangle_collection(k::Int, n::Int)

Return the weakly separated collection corresponding to the dual-rectangle graph.
""" 
function dual_rectangle_collection(k, n, type = Int) # TODO use known quiver to speed up computation
    return WSCollection(k, n, dual_rectangle_labels(k, n, type))
end

@doc raw"""
    is_frozen(collection::WSCollection, i::Int)

Return true if the vertex `i` of `collection` is frozen.
"""
function is_frozen(collection::WSCollection, i) 
    return i <= collection.n
end

@doc raw"""
    is_mutable(collection::WSCollection, i::Int) 

Return true if the vertex `i` of `collection` is mutable.
"""
function is_mutable(collection::WSCollection, i)
    return !is_frozen(collection, i) && degree(collection.quiver, [i])[1] == 4 
end

@doc raw"""
    get_mutables(collection::WSCollection)

Return all mutable vertices of `collection`.
"""
function get_mutables(collection::WSCollection)
    return filter( x -> is_mutable(collection, x), collection.n+1:length(collection))
end

function updateCliques!(array::Vector{T}, collection::WSCollection{T}, 
                        i, I::Vector{T}, a::T, b::T, c::T, d::T) where T <: Integer

    if length(array) == 1
        adj = sort!(union(I, array))
        opp = sort(union(adj, [b, d]))
        X = collection.whiteCliques
        Y = collection.blackCliques 
    else 
        adj = sort!(union(I, array))
        opp = setdiff(adj, [a, c]) 
        X = collection.blackCliques
        Y = collection.whiteCliques
    end
    
    if haskey(Y, opp) # adjacent clique is a triangle and must be merged with the opposite clique
        A = X[adj]
        l = findfirst(x -> x == i, A)
        succ = A[pmod(l+1 ,3)]

        O = Y[opp]
        l = findfirst(x -> x == succ, O)

        Y[opp] = insert!(O, l, T(i))
        delete!(X, adj)
    else # adjacent clique must be split into a triangle and another (possibly empty) clique
        A = X[adj]

        if length(A) == 3 # adjacent clique is trangle at the boundary. Just flip colors
            Y[opp] = A
            delete!(X, adj)
        else # split off a triangle from the adjacent clique

         l = findfirst(x -> x == i, A) 
         m = length(A)
         Y[opp] = [ A[pmod(l-1, m)], T(i), A[pmod(l+1, m)] ]
         X[adj] = deleteat!(A, l)
        end
    end

    collection.whiteCliques, collection.blackCliques = length(array) == 1 ? (X, Y) : (Y, X)
end

@doc raw"""
    mutate!(collection::WSCollection, i::Int, mutateCliques::Bool = true)

Mutate the `collection` in direction `i` if `i` is a mutable vertex of `collection`.

If `mutateCliques` is set to false, the 2-cells are emptied.
"""
function mutate!(collection::WSCollection{T}, i::Int, mutateCliques::Bool = true) where T <: Integer

    if !is_mutable(collection, i)
        return error("vertex $i with label $(collection.labels[i]) of the given WSCollection is not mutable!")
    end

    G = collection.quiver
    
    # exchange label of i
    N_in::SVector{2, Int} = collect(inneighbors(G, i))
    N_out::SVector{2, Int} = collect(outneighbors(G, i))

    N_out_labels = collection[N_out]
    
    I = intersect(N_out_labels[1], N_out_labels[2])
    (a, b, c, d) = sort!(setdiff(union(N_out_labels[1], N_out_labels[2]), I))
    
    if b in collection.labels[i]   # ensure label of i is Iac
        (a, b, c, d) = (b, c, d, a) 
    end
    
    collection[i] = sort!(union(I, [b,d])) # exchange Iac for Ibd

    # mutate quiver
    for j in N_in # add/remove edges according to quiver mutation
        for l in N_out
            if has_edge(G, l, j)
                rem_edge!(G, l, j)
            elseif !is_frozen(collection, j) || !is_frozen(collection, l)
                add_edge!(G, j, l)
            end
        end
    end

    # reverse edges adjacent to i
    for j in N_in
        rem_edge!(G, j, i)
        add_edge!(G, i, j)
    end

    for l in N_out
        rem_edge!(G, i, l)
        add_edge!(G, l, i)
    end

    collection.quiver = G

    if mutateCliques && !cliques_empty(collection)
        updateCliques!([a], collection, i, I, a, b, c, d)
        updateCliques!([c], collection, i, I, a, b, c, d)
        updateCliques!([a,b,c], collection, i, I, a, b, c, d)
        updateCliques!([a,c,d], collection, i, I, a, b, c, d)
        
    elseif !cliques_empty(collection)
        collection.whiteCliques = Dict{Vector{T}, Vector{T}}()
        collection.blackCliques = Dict{Vector{T}, Vector{T}}()
    end

    return collection
end

@doc raw"""
    mutate(collection::WSCollection, i::Int, mutateCliques::Bool = true)

Version of `mutate!` that does not modify its arguments.
"""
function mutate(collection::WSCollection, i::Int, mutateCliques::Bool = true)
    return mutate!( deepcopy(collection), i, mutateCliques)
end

@doc raw"""
    mutate!(collection::WSCollection, label::Vector{Int}, mutateCliques::Bool = true)

Mutate the `collection` by addressing a vertex with its label.
"""
function mutate!(collection::WSCollection, label::Vector{Int}, mutateCliques::Bool = true) 
    i = findfirst(x -> x == label, collection.labels)

    if isnothing(i)
        error("$label is not part of the collection")
    end

    return mutate!(collection, i, mutateCliques)
end

@doc raw"""
    mutate(collection::WSCollection, label::Vector{Int}, mutateCliques::Bool = true)

Mutate the `collection` by addressing a vertex with its label, without modifying arguments.
"""
function mutate(collection::WSCollection, label::Vector{Int}, mutateCliques::Bool = true)
    return mutate!( deepcopy(collection), label, mutateCliques)
end


function apply_to_collection!(f::Function, collection::WSCollection{T}) where T <: Integer # f: T -> T
    
    # apply to labels
    F = I -> sort!(f.(I))
    collection.labels = F.(collection.labels)

    # shift clique keys
    W2::Dict{Vector{T}, Vector{T}} = Dict()
    B2::Dict{Vector{T}, Vector{T}} = Dict()

    for (K, C) in collection.whiteCliques
        K2 = sort(f.(K))
        W2[K2] = C
    end

    for (L, C) in collection.blackCliques
        L2 = sort(f.(L))
        B2[L2] = C
    end

    collection.whiteCliques = W2
    collection.blackCliques = B2

    return collection
end


@doc raw"""
    rotate!(collection::WSCollection, amount::Int)

Rotate `collection` by `amount`, where a positive amount indicates a clockwise rotation.
"""
function rotate!(collection::WSCollection{T}, amount) where T <: Integer

    shift = let (n, a) = (collection.n, T(amount))
        x -> pmod(x + a, n)
    end
    return apply_to_collection!(shift, collection)
end

@doc raw"""
    rotate(collection::WSCollection, amount::Int)

Rotate `collection` by `amount`, where a positive amount indicates a clockwise rotation.
Does not change its input.
"""
function rotate(collection::WSCollection, amount)
    return rotate!(deepcopy(collection), amount)
end

@doc raw"""
    mirror!(collection::WSCollection, shift::Int = 1)

Reflect `collection` by letting the permutation `p(x) = 1 + shift - x` interpreted modulo 
`n = collection.n` act on the labels of `collection`.
"""
function mirror!(collection::WSCollection{T}, shift = 2) where T <: Integer

    mirror = let (n, s) = (collection.n, T(shift))
        x -> pmod(s - x, n)
    end
    return apply_to_collection!(mirror, collection)
end

@doc raw"""
    mirror(collection::WSCollection, shift::Int = 1) 

Reflect `collection` by letting the permutation `p(x) = 1 + shift - x` interpreted modulo 
`n = collection.n` act on the labels of `collection`. Does not change its input.
"""
function mirror(collection::WSCollection, shift = 1)
    return mirror!(deepcopy(collection), shift)
end

@doc raw"""
    complements!(collection::WSCollection) 

Return the collection whose labels are complementary to those of `collection`.
"""
function complements!(collection::WSCollection{T}) where T <: Integer
    n = collection.n
    k = collection.k

    complement = let Omega = collect(T, 1:n)
        A -> setdiff(Omega, A)
    end

    collection.labels = complement.(collection.labels)

    # take complement of clique keys
    W2::Dict{Vector{T}, Vector{T}} = Dict()
    B2::Dict{Vector{T}, Vector{T}} = Dict()

    for (K, C) in collection.whiteCliques
        L = complement(K)
        B2[L] = C
    end

    for (L, C) in collection.blackCliques
        K = complement(L)
        W2[K] = C
    end

    collection.whiteCliques = W2
    collection.blackCliques = B2

    collection.k = n-k

    return collection
end

@doc raw"""
    complements(collection::WSCollection) 

Return the collection whose labels are complementary to those of `collection`.
Does not change its input.
"""
function complements(collection::WSCollection)
    return complements!(deepcopy(collection))
end

@doc raw"""
    swap_colors!(collection::WSCollection) 

Return the weakly separated collection whose corresponding plabic graph is obtained
from the one of `collection` by swapping the colors black and white.

This is the same as taking complements and rotating by `collection.k`.
"""
function swap_colors!(collection::WSCollection{T}) where T <: Integer
    # swapping colors = complement + rotate by k

    n = collection.n
    k = collection.k

    shift = let (k, n) = (k, n)
        x -> pmod(x + k, n)
    end

    swap_color = let Omega = collect(T, 1:n)
        A -> setdiff( Omega, shift.(A))
    end

    collection.labels = swap_color.(collection.labels)

    # swap colors of clique keys
    W2::Dict{Vector{T}, Vector{T}} = Dict()
    B2::Dict{Vector{T}, Vector{T}} = Dict()

    for (K, C) in collection.whiteCliques
        L = swap_color(K)
        B2[L] = C
    end

    for (L, C) in collection.blackCliques
        K = swap_color(L)
        W2[K] = C
    end

    collection.whiteCliques = W2
    collection.blackCliques = B2
    collection.k = n-k

    return collection
end

@doc raw"""
    swap_colors(collection::WSCollection) 

Return the weakly separated collection whose corresponding plabic graph is obtained
from the one of `collection` by swapping the colors black and white.
Does not change its input.
"""
function swap_colors(collection::WSCollection)
    return swap_colors!(deepcopy(collection))
end

# extend to maximal weakly separated collection using brute force
@doc raw"""
    extend_weakly_separated!(k::Int, n::Int, labels::Vector{Vector{Int}})  

Extend `labels` to contain the labels of a maximal weakly separated collection.
"""
function extend_weakly_separated!(k::Int, n::Int, labels::Vector{Vector{T}}) where T <: Integer
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
        if !(v in labels) && is_weakly_separated(n, union(labels, [v]))
            push!(labels, v)
        end

        if length(labels) == N
            return labels
        end
    end

end

# extend to maximal weakly separated collection using know labels, then brute fore
@doc raw"""
    extend_weakly_separated!(k::Int, n::Int, labels1::Vector{Vector{Int}}, 
                                             labels2::Vector{Vector{Int}})

Extend `labels1` to contain the labels of a maximal weakly separated collection.
Use elements of `labels2` if possible.
"""
function extend_weakly_separated!(k::Int, n::Int, labels1::Vector{Vector{T}}, 
                                                  labels2::Vector{Vector{T}}) where T <: Integer
    N = k*(n-k)+1

    # enforce frozen labels in the first n positions
    frozen = frozen_labels(k, n, T)
    labels1 = union(frozen, labels1)

    for v in labels2
        if !(v in labels1) && is_weakly_separated(n, union(labels1, [v]))

            push!(labels1, deepcopy(v))
        end

        if length(labels1) == N
            return labels1
        end
    end

    k_sets = subsets(1:n, k)

    for v in k_sets
        v = Vector{T}(v)
        if !(v in labels1) && is_weakly_separated(n, union(labels1, [v]))
            push!(labels1, v)
        end

        if length(labels1) == N
            return labels1
        end
    end

end

@doc raw"""
    extend_weakly_separated!(labels::Vector{Vector{Int}}, collection::WSCollection)

Extend `labels` to contain the labels of a maximal weakly separated collection.
Use labels of `collection` if possible.
"""
function extend_weakly_separated!(labels::Vector{Vector{T}}, collection::WSCollection{T}) where T <: Integer
    return extend_weakly_separated!(collection.k, collection.n, labels, collection.labels)
end

@doc raw"""
    extend_to_collection(k::Int, n::Int, labels::Vector{Vector{Int}})

Return a maximal weakly separated collection containing all elements of `labels`.
"""
function extend_to_collection(k::Int, n::Int, labels::Vector{Vector{T}}) where T <: Integer
    return WSCollection(k, n, extend_weakly_separated!(k, n, deepcopy(labels)))
end

@doc raw"""
    extend_to_collection(k::Int, n::Int, labels1::Vector{Vector{Int}}, 
                                         labels2::Vector{Vector{Int}})

Return a maximal weakly separated collection containing all elements of `labels1`.
Use elements of `labels2` if possible.
"""
function extend_to_collection(k::Int, n::Int, labels1::Vector{Vector{T}}, labels2::Vector{Vector{T}}) where T <: Integer
    return WSCollection(k, n, extend_weakly_separated!(k, n, deepcopy(labels1), labels2))
end

@doc raw"""
    extend_to_collection(labels::Vector{Vector{Int}}, collection::WSCollection)

Return a maximal weakly separated collection containing all elements of `labels`.
Use labels of `collection` if possible.
"""
function extend_to_collection(labels::Vector{Vector{T}}, collection::WSCollection{T}) where T <: Integer
    return WSCollection(collection.k, collection.n, extend_weakly_separated!(deepcopy(labels), collection))
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