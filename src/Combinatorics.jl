
# return a mod b as element in {1, ..., b}
function pmod(a::Int, b::Int) 
    c = a % b
    return c > 0 ?  c : c+b
end

@doc raw"""
    is_weakly_separated(n::Int, v::Vector{Int}, w::Vector{Int})

Test if two vectors `v` and `w` viewed as subsets of `{1 , ..., n }` are weakly separated.

# Examples

```julia-repl
julia> v = [1,2,3,5,6,9]
julia> w = [1,2,4,5,7,8]
julia> is_weakly_separated(9, v, w)
true
```

```julia-repl
julia> v = [1,2,3,5,6,9]
julia> w = [1,2,3,5,7,8]
julia> is_weakly_separated(9, v, w)
false
```
"""
function is_weakly_separated(n::Int, v::Vector{Int}, w::Vector{Int}) 
    x = setdiff(v, w)
    y = setdiff(w, v)
    i = 1
    
    # the following trys to finds a < b < c < d contradicting the the ws of v and w
    while(!(i in x) && !(i in y) )
        i += 1
        if(i+3 > n)
            return true
        end
    end
            
    if(i in y)
        (x,y) = (y,x)
    end
    
    while(!(i in y))
        i += 1
        if(i+2 > n)
            return true
        end
    end
    
    while(!(i in x))
        i += 1
        if(i+1 > n)
            return true
        end
    end
    
    while(!(i in y))
        i += 1
        if(i > n)
            return true
        end
    end
    # if we get here, a, b, c, d have been found so v and w are not weakly separated
    return false
end

@doc raw"""
    is_weakly_separated(n::Int, labels::Vector{Vector{Int}})

Test if the vectors contained in `labels` are pairwise weakly separated.

# Examples

```julia-repl
julia> u = [1,2,3,4,5,6]
julia> v = [1,2,3,5,6,9]
julia> w = [1,2,3,5,7,8]
julia> is_weakly_separated(9, [u, v, w])
true
```
"""
function is_weakly_separated(n::Int, labels::Vector{Vector{Int}})
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
    rectangle_labels(k::Int, n::Int)

Return the labels of the rectangle graph as a vector. 
The frozen labels are in positions `1` to `n`.
"""
function rectangle_labels(k::Int, n::Int)
    labels = Vector() 

    for i = 0:n-1 # frozen labels
        F = [pmod(l+i, n) for l = 1:k]
        push!(labels, sort(F))
    end

    for i = 1:n-k-1 # mutable labels
        for j = 1:k-1
            L = collect(i+1:i+j)
            R = collect(n-k+j+1:n)
            push!(labels, union(L, R))
        end
    end

    return Vector{Vector{Int}}(labels)
end

@doc raw"""
    checkboard_labels(k::Int, n::Int)

Return the labels of the checkboard graph as a vector. 
The frozen labels are in positions `1` to `n`.
"""
function checkboard_labels(k::Int, n::Int) 
    sigma = (x, y) -> pmod(x+y, n)

    labels = Vector() 

    for i = 0:n-1 # frozen labels
        F = [pmod(l+i, n) for l = 1:k] 
        push!(labels, sort(F))
    end

    for i = 1:n-k-1 # mutable labels
        for j = 1:k-1
            sigma_ij = x -> sigma(x, -Int(ceil((i+j)/2)))
            L = sigma_ij.(collect(i+1:i+j))
            R = sigma_ij.(collect(n-k+j+1:n))
            push!(labels, sort(union(L, R)))
        end
    end

    return Vector{Vector{Int}}(labels)
end

@doc raw"""
    dual_rectangle_labels(k::Int, n::Int)

Return the labels of the dual-rectangle graph as a vector. 
The frozen labels are in positions `1` to `n`.
"""
function dual_rectangle_labels(k::Int, n::Int) 
    labels = Vector() 

    for i = 0:n-1 # frozen labels
        F = [pmod(l+i, n) for l = 1:k]
        push!(labels, sort(F))
    end

    for i = 1:k-1 # mutable labels
        for j = 1:n-k-1
            L = collect(1:i)
            R = collect(i+j+1:k+j)
            push!(labels, union(L, R))
        end
    end

    return Vector{Vector{Int}}(labels)
end

@doc raw"""
    dual_checkboard_labels(k::Int, n::Int)

Return the labels of the dual-checkboard graph as a vector. 
The frozen labels are in positions `1` to `n`.
"""
function dual_checkboard_labels(k::Int, n::Int) 
    labels =  Vector() 
    sigma = (x, y) -> pmod(x+y, n)

    for i = 0:n-1 # frozen labels
        F = [pmod(l+i, n) for l = 1:k] 
        push!(labels, sort(F))
    end

    for i = 1:k-1 # mutable labels
        for j = 1:n-k-1
            sigma_ij = x -> sigma(x, -Int(ceil((i+j)/2)))
            L = sigma_ij.( collect(1:i))
            R = sigma_ij.( collect(i+j+1:k+j))
            push!(labels, sort(union(L, R)))
        end
    end

    return Vector{Vector{Int}}(labels)
end

@doc raw"""
    compute_cliques(k::Int, labels::Vector{Vector{Int}})

Return the non trivial black and white cliques of the weakly separated collection 
whose elements are given by `labels`.
"""
function compute_cliques(k::Int, labels::Vector{Vector{Int}}) # TODO parameter k is unnessesary
    N = length(labels)
    W = Dict()
    B = Dict()

    # compute white and black cliques
    for i = 1:N-1
        for j = i+1:N

            K = intersect(labels[i], labels[j])
            if length(K) == k-1 # labels[i] and labels[j] belong to W[K]

                if( haskey(W, K) )
                    W[K] = push!(W[K], labels[i])
                    W[K] = push!(W[K], labels[j])
                else
                    W[K] = Set([labels[i], labels[j]])
                end

                L = sort(union(labels[i], labels[j])) # labels[i] and labels[j] also belong to B[L]
                if( haskey(B, L) )
                    B[L] = push!(B[L], labels[i])
                    B[L] = push!(B[L], labels[j])
                else
                    B[L] = Set([labels[i], labels[j]])
                end

            end

        end
    end

    for (K, C) in W # remove trivial cliques, and convert to vector
        if length(C) < 3
            delete!(W, K)
        else
            W[K] = collect(C)
        end
    end

    for (L, C) in B
        if length(C) < 3
            delete!(B, L)
        else
            B[L] = collect(C)
        end
    end 

    return W, B        
end

@doc raw"""
    compute_cliques(labels::Vector{Vector{Int}}, quiver::SimpleDiGraph{Int})

Return the non trivial black and white cliques of the weakly separated collection 
whose elements are given by `labels` and whose adjacencies are encoded in `quiver`.
"""
function compute_cliques(labels::Vector{Vector{Int}}, quiver::SimpleDiGraph{Int})
    W = Dict()
    B = Dict()

    for e in edges(quiver)
        i, j = src(e), dst(e)
        K = intersect(labels[i], labels[j])
        L = sort(union(labels[i], labels[j]))

        if( haskey(W, K) )
            W[K] = push!(W[K], labels[i])
            W[K] = push!(W[K], labels[j])
        else
            W[K] = Set([labels[i], labels[j]])
        end

        if( haskey(B, L) )
            B[L] = push!(B[L], labels[i])
            B[L] = push!(B[L], labels[j])
        else
            B[L] = Set([labels[i], labels[j]])
        end
    end

    for (K, C) in W # remove trivial cliques, and convert to vector
        if length(C) < 3
            delete!(W, K)
        else
            W[K] = collect(C)
        end
    end

    for (L, C) in B
        if length(C) < 3
            delete!(B, L)
        else
            B[L] = collect(C)
        end
    end 

    return W, B
end

@doc raw"""
    compute_adjacencies(k::Int, n::Int, labels::Vector{Vector{Int}}) 

Compute the adjacency graph and face boundaries of the weakly separated collection 
with elements given by `labels`.
"""
function compute_adjacencies(k::Int, n::Int, labels::Vector{Vector{Int}}) 
    N = length(labels)
    W, B = compute_cliques(k, labels)
    labelPos = Dict(labels[i] => i for i = 1:N) # memorize positions of labels

    Q = SimpleDiGraph(N, 0)

    function add_edges(C) # given the boundary of a clique, add edges (if not both vertices are frozen)

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

    for K in keys(W) # compute boundary and add edges for non trivial white cliques
        C = W[K]
        C_minus_K = (x -> setdiff(x, K)).(C)
        
        p = sortperm(C_minus_K) 
        C = (c -> labelPos[c]).(C)
        C = C[p]
        W[K] = C

        add_edges(C)
    end

    for L in keys(B) # compute boundary for non trivial black cliques (dont add edges here to avoid 2-cycles)
        C = B[L]
        L_minus_C = (x -> setdiff(L, x)).(C)
        
        p = sortperm(L_minus_C)
        C = (c -> labelPos[c]).(C)
        B[L] = C[p]
    end

    return Q, W, B
end

@doc raw"""
    compute_boundaries(labels::Vector{Vector{Int}}, quiver::SimpleDiGraph{Int})

Compute the face boundaries of the weakly separated collection with elements given 
by `labels` and adjacency graph `quiver`.
"""
function compute_boundaries(labels::Vector{Vector{Int}}, quiver::SimpleDiGraph{Int})
    N = length(labels)
    W, B = compute_cliques(labels, quiver)
    labelPos = Dict(labels[i] => i for i = 1:N) # memorize positions of labels
    
    for K in keys(W) # compute boundary 
        C = W[K]
        C_minus_K = (x -> setdiff(x, K)).(C)
        
        p = sortperm(C_minus_K)
        C = (c -> labelPos[c]).(C)
        W[K] = C[p]
    end

    for L in keys(B) # compute boundary
        C = B[L]
        L_minus_C = (x -> setdiff(L, x)).(C)
        
        p = sortperm(L_minus_C)
        C = (c -> labelPos[c]).(C)
        B[L] = C[p]
    end

    return W, B
end

@doc raw"""
    WSCollection

An abstract 2-dimensional cell complex living inside the matriod of `k-sets` in `{1, ..., n}`. 
Its vertices are labelled by elements of `labels` while `quiver` encodes adjacencies 
between the vertices. 
The 2-cells are colored black or white and contained in `blackCliques` and `whiteCliques`.

Optionally the 2-cells can be set to `missing`, to save memory.

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

# Examples

```julia-repl
julia> labels = rectangle_labels(4, 9)
julia> WSCollection(4, 9, labels);
```
"""
mutable struct WSCollection
    k::Int
    n::Int
    labels::Vector{Vector{Int}}
    quiver::SimpleDiGraph{Int}
    whiteCliques::Union{Missing, Dict{Vector{Int}, Vector{Int} } }
    blackCliques::Union{Missing, Dict{Vector{Int}, Vector{Int} } }
end

@doc raw"""
    WSCollection(k::Int, n::Int, labels::Vector{Vector{Int}}, computeCliques::Bool = true)

Constructor of WSCollection. Adjacencies between its vertices as well as 2-cells are 
computed using only a set of vertex `labels`.

If `computeCliques` is set to false, the 2-cells will be set to `missing`.
"""
function WSCollection(k::Int, n::Int, labels::Vector{Vector{Int}}; computeCliques::Bool = true)
    Q, W, B = compute_adjacencies(k, n, labels)

    if computeCliques
        return WSCollection(k, n, labels, Q, W, B)
    else
        return WSCollection(k, n, labels, Q, missing, missing)
    end
end

@doc raw"""
    WSCollection(k::Int, n::Int, labels::Vector{Vector{Int}}, quiver::SimpleDiGraph{Int}, 
    computeCliques::Bool = true)

Constructor of WSCollection. The 2-cells are computed from vertex `labels` as well as the
their adjacencies encoded in `quiver`. Faster than just using labels most of the time.

If `computeCliques` is `false` the black and white 2-cells are set to `missing` instead.
"""
function WSCollection(k::Int, n::Int, labels::Vector{Vector{Int}}, quiver::SimpleDiGraph{Int}; computeCliques::Bool = true)
    if !computeCliques
        return WSCollection(k, n, labels, quiver, missing, missing)
    else
        W, B = compute_boundaries(labels, quiver)
        return WSCollection(k, n, labels, quiver, W, B)
    end
end

@doc raw"""
    WSCollection(collection::WSCollection; computeCliques::Bool = true)

Constructor of WSCollection. Computes 2-cells of `collection` if the are missing, 
othererwise returns a deepcopy of `collection`.

If `computeCliques` is `false` the black and white 2-cells are set to `missing` instead.
"""
function WSCollection(collection::WSCollection; computeCliques::Bool = true)
    if !computeCliques
        return WSCollection(collection.k, collection.n, collection.labels, collection.quiver, missing, missing)
    else
        if ismissing(collection.whiteCliques) || ismissing(collection.blackCliques)
            W, B = compute_boundaries(collection.labels, collection.quiver)
            return WSCollection(collection.k, collection.n, collection.labels, collection.quiver, W, B)
        else
            return deepcopy(collection)
        end
    end
end

# @doc raw"""
#     isequal(collection1::WSCollection, collection2::WSCollection)

# Return true if the vertices of `collection1` and `collection2` share the same labels.
# The order of labels in each collection does not matter.
# """
# function Base.isequal(collection1::WSCollection, collection2::WSCollection) 
#     return issetequal(collection1.labels, collection2.labels)
# end

@doc raw"""
    (==)(collection1::WSCollection, collection2::WSCollection)

Return true if the vertices of `collection1` and `collection2` share the same labels.
The order of labels in each collection does not matter.
"""
function Base.:(==)(collection1::WSCollection, collection2::WSCollection)
    return issetequal(collection1.labels, collection2.labels)
end


Base.hash(collection::WSCollection) = hash(Set(collection.labels))


@doc raw"""
    in(label::Vector{Int}, collection::WSCollection)

Return true `label` is occurs as label of `collection`.
"""
Base.in(label::Vector{Int}, collection::WSCollection) = label in collection.labels

@doc raw"""
    getindex(collection::WSCollection, i::Int)

Return the element at index `i` in `collection.labels`.
"""
Base.getindex(collection::WSCollection, i::Int) = getindex(collection.labels, i)

@doc raw"""
    setindex!(collection::WSCollection, i::Int)

Set the element at index `i` in `collection.labels` to `x`.
"""
Base.setindex!(collection::WSCollection, x::Vector{Int}, i::Int) = setindex!(collection.labels, x, i)

@doc raw"""
    length(collection::WSCollection)

Return the length of `collection.labels`.
"""
Base.length(collection::WSCollection) = length(collection.labels)

function cliques_missing(collection::WSCollection)
    return ismissing(collection.whiteCliques) || ismissing(collection.blackCliques)
end


function Base.intersect(collection1::WSCollection, collection2::WSCollection)
    return intersect(collection1.labels, collection2.labels)
end


function Base.setdiff(collection1::WSCollection, collection2::WSCollection)
    return setdiff(collection1.labels, collection2.labels)
end


function Base.union(collection1::WSCollection, collection2::WSCollection)
    return union(collection1.labels, collection2.labels)
end


function Base.show(io::IO, collection::WSCollection)
    s = "WSCollection of type ($(collection.k),$(collection.n)) with $(length(collection)) labels: \n"

    for l in collection.labels
        s *= "$l\n"
    end
    print(io, s)
end

@doc raw"""
    checkboard_collection(k::Int, n::Int)

Return the weakly separated collection corresponding to the checkboard graph.
""" 
function checkboard_collection(k::Int, n::Int) # TODO use known quiver to speed up computation
    return WSCollection(k, n, checkboard_labels(k, n))
end

@doc raw"""
    rectangle_collection(k::Int, n::Int)

Return the weakly separated collection corresponding to the rectangle graph.
""" 
function rectangle_collection(k::Int, n::Int) # TODO use known quiver to speed up computation
    return WSCollection(k, n, rectangle_labels(k, n))
end

@doc raw"""
    dual_checkboard_collection(k::Int, n::Int)

Return the weakly separated collection corresponding to the dual-checkboard graph.
""" 
function dual_checkboard_collection(k::Int, n::Int) # TODO use known quiver to speed up computation
    return WSCollection(k, n, dual_checkboard_labels(k, n))
end

@doc raw"""
    dual_rectangle_collection(k::Int, n::Int)

Return the weakly separated collection corresponding to the dual-rectangle graph.
""" 
function dual_rectangle_collection(k::Int, n::Int) # TODO use known quiver to speed up computation
    return WSCollection(k, n, dual_rectangle_labels(k, n))
end

@doc raw"""
    is_frozen(collection::WSCollection, i::Int)

Return true if the vertex `i` of `collection` is frozen.

# Examples

````julia-repl
julia> H = rectangle_collection(4, 9)
julia> is_frozen(H, 5)
true

julia> is_frozen(H, 11)
false
```
"""
function is_frozen(collection::WSCollection, i::Int) 
    return i <= collection.n
end

@doc raw"""
    is_mutable(collection::WSCollection, i::Int) 

Return true if the vertex `i` of `collection` is mutable. This is the case if
it is not frozen and is of degree 4.

# Examples

````julia-repl
julia> H = rectangle_collection(4, 9)
julia> is_mutable(H, 11)
false

julia> is_frozen(H, 10)
true
```
"""
function is_mutable(collection::WSCollection, i::Int) 
    return !is_frozen(collection, i) && Graphs.degree(collection.quiver, [i])[1] == 4 
end

@doc raw"""
    is_mutable(collection::WSCollection, i::Int) 

Return all mutable vertices of `collection`.
"""
function get_mutables(collection::WSCollection)
    return filter( x -> is_mutable(collection, x), collection.n+1:length(collection))
end

@doc raw"""
    mutate!(collection::WSCollection, i::Int, mutateCliques::Bool = true)

Mutate the `collection` in direction `i` if `i` is a mutable vertex of `collection`.

If `mutateCliques` is set to false, the 2-cells are set to missing.


# Examples

````julia-repl
julia> H = rectangle_collection(4, 9)
julia> mutate!(H, 10)
```
"""
function mutate!(collection::WSCollection, i::Int, mutateCliques::Bool = true)

    if !is_mutable(collection, i)
        return error("vertex $i with label $(collection.labels[i]) of the given WSCollection is not mutable!")
    end

    G = collection.quiver
    
    # exchange label of i
    N_in = collect(inneighbors(G, i))
    N_out = collect(outneighbors(G, i))

    N_out_labels = collection.labels[N_out]
    
    I = intersect(N_out_labels[1], N_out_labels[2])
    Iabcd = union(N_out_labels[1], N_out_labels[2])
    (a, b, c, d) = sort(setdiff(Iabcd, I))
    
    if b in collection.labels[i]   # ensure label of i is Iac
        (a, b, c, d) = (b, c, d, a) 
    end
    
    collection.labels[i] = sort(union(I, [b,d])) # exchange Iac for Ibd

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

    # update cliques if mutateCliques = true and cliques are not missing
    function updateCliques(array)
        adj, opp, X, Y = Vector(), Vector(), Dict(), Dict()

        if length(array) == 1
            adj = sort(union(I, array))
            opp = sort(union(adj, [b, d]) )
            X = collection.whiteCliques
            Y = collection.blackCliques 
        else 
            adj = sort(union(I, array))
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

            Y[opp] = insert!(O, l, i)
            delete!(X, adj)
        else # adjacent clique must be split into a triangle and another (possibly empty) clique
            A = X[adj]

            if length(A) == 3 # adjacent clique is trangle at the boundary. Just flip colors
                Y[opp] = A
                delete!(X, adj)
            else # split off a triangle from the adjacent clique

             l = findfirst(x -> x == i, A) 
             m = length(A)
             Y[opp] = [ A[pmod(l-1, m)], i, A[pmod(l+1, m)] ]
             X[adj] = deleteat!(A, l)
            end
        end

        collection.whiteCliques, collection.blackCliques = length(array) == 1 ? (X, Y) : (Y, X)
    end

    if mutateCliques && !ismissing(collection.whiteCliques) && !ismissing(collection.blackCliques)
        updateCliques([a])
        updateCliques([c])
        updateCliques([a,b,c])
        updateCliques([a,c,d])
    else
        collection.whiteCliques, collection.blackCliques = missing, missing
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

# Examples

````julia-repl
julia> H = rectangle_collection(4, 9)
julia> H.labels[10]
4-element Vector{Int64}:
 2
 7
 8
 9

julia> mutate!(H, [2,7,8,9])
```
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

@doc raw"""
    rotate_collection!(collection::WSCollection, amount::Int)

Rotate `collection` by `amount`, where a positive amount indicates a clockwise rotation.

# Examples

```julia-repl
julia> H = rectangle_collection(4, 9)
julia> rotate_collection!(H, 2)
```
"""
function rotate_collection!(collection::WSCollection, amount::Int)
    n = collection.n
    labels = collection.labels
    Q = collection.quiver
    W = collection.whiteCliques
    B = collection.blackCliques

    shift = x -> pmod(x + amount, n)
    shift_frozen = (x -> x <= n ? shift(x) : x)

    # shift labels
    for i = n+1:length(labels)
        collection.labels[i] = sort(shift.(labels[i]))
    end

    # shift edges to frozen vertices
    Q2 = deepcopy(Q)

    for i = 1:n
        for j in outneighbors(Q, i)
            rem_edge!(Q2, i, j)
            add_edge!(Q2, shift(i), j)
        end

        for j in inneighbors(Q, i)
            rem_edge!(Q2, j, i)
            add_edge!(Q2, j, shift(i))
        end
    end
    collection.quiver = Q2

    # shift clique keys
    W2 = Dict()
    B2 = Dict()

    for (K, C) in W
        K2 = sort(shift.(K))
        C2 = shift_frozen.(C)
        W2[K2] = C2
    end

    for (L, C) in B
        L2 = sort(shift.(L))
        C2 = shift_frozen.(C)
        B2[L2] = C2
    end

    collection.whiteCliques = W2
    collection.blackCliques = B2

    return collection
end

@doc raw"""
    rotate_collection(collection::WSCollection, amount::Int)

Version of `rotate_collection!` that does not modify its argument. 
"""
function rotate_collection(collection::WSCollection, amount::Int)
    return rotate_collection!(deepcopy(collection), amount)
end

@doc raw"""
    reflect_collection!(collection::WSCollection, axis::Int = 1) 

Reflect `collection` by letting the permutation `x ↦ 2*axis -x` interpreted modulo 
`n = collection.n` act on the labels of `collection`.

# Examples

```julia-repl
julia> H = rectangle_collection(4, 9)
julia> rotate_collection!(H, 1)
```
"""
function reflect_collection!(collection::WSCollection, axis::Int = 1) 
    n = collection.n
    k = collection.k
    labels = collection.labels
    Q = collection.quiver
    W = collection.whiteCliques
    B = collection.blackCliques

    reflect = x -> pmod(2*axis - x, n)
    reflect_frozen = (x -> x <= n ? pmod(2*axis + 1 - k - x, n) : x)

    # reflect labels
    for i = n+1:length(labels)
        collection.labels[i] = sort(reflect.(labels[i]))
    end

    # shift edges to frozen vertices
    Q2 = deepcopy(Q)

    for i = 1:n
        for j in outneighbors(Q, i)
            rem_edge!(Q2, i, j)
            add_edge!(Q2, reflect_frozen(i), j)
        end

        for j in inneighbors(Q, i)
            rem_edge!(Q2, j, i)
            add_edge!(Q2, j, reflect_frozen(i))
        end
    end
    collection.quiver = Q2

    # shift clique keys
    W2 = Dict()
    B2 = Dict()

    for (K, C) in W
        K2 = sort(reflect.(K))
        C2 = reflect_frozen.(C)
        W2[K2] = C2
    end

    for (L, C) in B
        L2 = sort(reflect.(L))
        C2 = reflect_frozen.(C)
        B2[L2] = C2
    end

    collection.whiteCliques = W2
    collection.blackCliques = B2

    return collection
end

@doc raw"""
    reflect_collection(collection::WSCollection, axis::Int = 1) 

Version of `reflect_collection!` that does not modify its argument.
"""
function reflect_collection(collection::WSCollection, axis::Int = 1)
    return reflect_collection!(deepcopy(collection), axis)
end

@doc raw"""
    complement_collection!(collection::WSCollection) 

Return the collection whose labels are complementary to those of `collection`.

# Examples

```julia-repl
julia> H = rectangle_collection(4, 9)
julia> complement_collection!(H)
```
"""
function complement_collection!(collection::WSCollection) 
    n = collection.n
    k = collection.k
    labels = collection.labels
    Q = collection.quiver
    W = collection.whiteCliques
    B = collection.blackCliques

    shift = x -> pmod(x + k, n)
    shift_frozen = (x -> x <= n ? shift(x) : x)
    
    # take complements of labels
    for i = 0:n-1 # frozen labels
        F = [pmod(l+i, n) for l = 1:n-k]
        labels[i+1] = sort(F)
    end

    I = collect(1:n)
    M = collect(n+1:length(labels))

    complement = A -> setdiff(I, A)
    labels[M] = complement.(labels[M])
    collection.labels = labels

    # shift edges to frozen vertices
    Q2 = deepcopy(Q)

    for i = 1:n
        for j in outneighbors(Q, i)
            rem_edge!(Q2, i, j)
            add_edge!(Q2, shift(i), j)
        end

        for j in inneighbors(Q, i)
            rem_edge!(Q2, j, i)
            add_edge!(Q2, j, shift(i))
        end
    end
    collection.quiver = Q2

    # take complement of clique keys, and shift frozen
    W2 = Dict()
    B2 = Dict()

    for (K, C) in W
        L = sort(complement(K))
        C2 = shift_frozen.(C)
        B2[L] = C2
    end

    for (L, C) in B
        K = sort(complement(L))
        C2 = shift_frozen.(C)
        W2[K] = C2
    end

    collection.whiteCliques = W2
    collection.blackCliques = B2

    collection.k = n-k

    return collection
end

@doc raw"""
    complement_collection(collection::WSCollection) 

Version of `complement_collection!` that does not modify its argument.
"""
function complement_collection(collection::WSCollection)
    return complement_collection!(deepcopy(collection))
end

@doc raw"""
    swaped_colors_collection!(collection::WSCollection) 

Return the weakly separated collection whose corresponding plabic graph is obtained
from the one of `collection` by swapping the colors black and white.

This is the same as taking complements and rotating by `collection.k`.

# Examples

```julia-repl
julia> H = rectangle_collection(4, 9)
julia> swaped_colors_collection!(H)
```
"""
function swaped_colors_collection!(collection::WSCollection) 
    # swapping colors = complement + rotate by k

    n = collection.n
    k = collection.k
    labels = collection.labels
    Q = collection.quiver
    W = collection.whiteCliques
    B = collection.blackCliques

    shift = x -> pmod(x + k, n)
    shift_frozen = (x -> x <= n ? pmod(x + 2*k, n) : x)

    # labels
    for i = 0:n-1 # frozen labels
        F = [pmod(l+i, n) for l = 1:n-k]
        labels[i+1] = sort(F)
    end

    I = collect(1:n)
    M = collect(n+1:length(labels))

    complement = A -> setdiff(I, A)
    labels[M] = complement.(labels[M])

    for i = n+1:length(labels)
        labels[i] = sort(shift.(labels[i]))
    end

    # shift edges to frozen vertices
    Q2 = deepcopy(Q)

    for i = 1:n
        for j in outneighbors(Q, i)
            rem_edge!(Q2, i, j)
            add_edge!(Q2, shift_frozen(i), j)
        end

        for j in inneighbors(Q, i)
            rem_edge!(Q2, j, i)
            add_edge!(Q2, j, shift_frozen(i))
        end
    end
    collection.quiver = Q2

    # take complement of clique keys, and shift frozen
    W2 = Dict()
    B2 = Dict()

    for (K, C) in W
        L = sort(shift.(complement(K)))
        C2 = shift_frozen.(C)
        B2[L] = C2
    end

    for (L, C) in B
        K = sort(shift.(complement(L)))
        C2 = shift_frozen.(C)
        W2[K] = C2
    end

    collection.whiteCliques = W2
    collection.blackCliques = B2

    collection.k = n-k

    return collection
end

@doc raw"""
    swaped_colors_collection(collection::WSCollection) 

Version of `swaped_colors_collection!` that does not modify its argument.
"""
function swaped_colors_collection(collection::WSCollection)
    return swaped_colors_collection!(deepcopy(collection))
end

# extend to maximal weakly separated collection using brute force
@doc raw"""
    extend_weakly_separated!(k::Int, n::Int, labels::Vector{Vector{Int}})  

Extend `labels` to contain the labels of a maximal weakly separated collection.

# Examples

```julia-repl
julia> labels = [[1,3,5,7], [1,3,5,9]]
julia> extend_weakly_separated!(4, 9, labels)
```
"""
function extend_weakly_separated!(k::Int, n::Int, labels::Vector{Vector{Int}})
    N = k*(n-k)+1

    # enforce frozen labels in the first n positions
    frozen::Vector{Vector{Int}} = Vector() 
    for i = 0:n-1 
        F = [pmod(l+i, n) for l = 1:k]
        push!(frozen, sort(F))
    end

    labels = union(frozen, labels)

    if length(labels) == N
        return Vector{Vector{Int}}(labels)
    end

    k_sets = subsets(collect(1:n), k)

    for v in k_sets
        if !(v in labels) && is_weakly_separated(n, union(labels, [v]))
            push!(labels, v)
        end

        if length(labels) == N
            return Vector{Vector{Int}}(labels)
        end
    end

end

# extend to maximal weakly separated collection using know labels, then brute fore
@doc raw"""
    extend_weakly_separated!(k::Int, n::Int, labels1::Vector{Vector{Int}}, 
                                             labels2::Vector{Vector{Int}})

Extend `labels1` to contain the labels of a maximal weakly separated collection.
Use elements of `labels2` if possible.

# Examples

```julia-repl
julia> labels1 = [[1,3,5,7], [1,3,5,9]]
julia> labels2 = checkboard_labels(4, 9)
julia> extend_weakly_separated!(4, 9, labels1, labels2)
```
"""
function extend_weakly_separated!(k::Int, n::Int, labels1::Vector{Vector{Int}}, labels2::Vector{Vector{Int}})
    N = k*(n-k)+1

    # enforce frozen labels in the first n positions
    frozen::Vector{Vector{Int}} = Vector() 
    for i = 0:n-1 
        F = [pmod(l+i, n) for l = 1:k]
        push!(frozen, sort(F))
    end

    labels1 = union(frozen, labels1)

    for v in labels2
        if !(v in labels1) && is_weakly_separated(n, union(labels1, [v]))

            push!(labels1, v)
        end

        if length(labels1) == N
            return Vector{Vector{Int}}(labels1)
        end
    end

    k_sets = subsets(collect(1:n), k)

    for v in k_sets
        if !(v in labels1) && is_weakly_separated(n, union(labels1, [v]))
            push!(labels1, v)
        end

        if length(labels1) == N
            return Vector{Vector{Int}}(labels1)
        end
    end

end

@doc raw"""
    extend_weakly_separated!(labels::Vector{Vector{Int}}, collection::WSCollection)

Extend `labels` to contain the labels of a maximal weakly separated collection.
Use labels of `collection` if possible.

# Examples

```julia-repl
julia> labels = [[1,3,5,7], [1,3,5,9]]
julia> H = checkboard_collection(4, 9)
julia> extend_weakly_separated!(labels, H)
```
"""
function extend_weakly_separated!(labels::Vector{Vector{Int}}, collection::WSCollection)
    return extend_weakly_separated!(collection.k, collection.n, labels, collection.labels)
end

@doc raw"""
    extend_to_collection(k::Int, n::Int, labels::Vector{Vector{Int}})

Return a maximal weakly separated collection containing all elements of `labels`.

# Examples

```julia-repl
julia> labels = [[1,3,5,7], [1,3,5,9]]
julia> extend_to_collection(4, 9, labels)
```
"""
function extend_to_collection(k::Int, n::Int, labels::Vector{Vector{Int}})
    return WSCollection(k, n, extend_weakly_separated!(k, n, deepcopy(labels)))
end

@doc raw"""
    extend_to_collection(k::Int, n::Int, labels1::Vector{Vector{Int}}, 
                                         labels2::Vector{Vector{Int}})

Return a maximal weakly separated collection containing all elements of `labels1`.
Use elements of `labels2` if possible.

# Examples

```julia-repl
julia> labels1 = [[1,3,5,7], [1,3,5,9]]
julia> labels2 = checkboard_labels(4, 9)
julia> extend_to_collection(4, 9, labels1, labels2)
```
"""
function extend_to_collection(k::Int, n::Int, labels1::Vector{Vector{Int}}, labels2::Vector{Vector{Int}})
    return WSCollection(k, n, extend_weakly_separated!(k, n, deepcopy(labels1), labels2))
end

@doc raw"""
    extend_to_collection(labels::Vector{Vector{Int}}, collection::WSCollection)

Return a maximal weakly separated collection containing all elements of `labels`.
Use labels of `collection` if possible.

# Examples

```julia-repl
julia> labels = [[1,3,5,7], [1,3,5,9]]
julia> H = checkboard_collection(4, 9)
julia> extend_to_collection(labels, H)
```
"""
function extend_to_collection(labels::Vector{Vector{Int}}, collection::WSCollection)
    return WSCollection(collection.k, collection.n, extend_weakly_separated!(deepcopy(labels), collection))
end


function super_potential_labels(k::Int, n::Int)
    labels::Vector{Vector{Int}} = Vector()

    I = push!(collect(2:k), n)

    for i = 0:n-1 
        S = (x -> pmod(x+i, n)).(I)
        push!(labels, sort(S))
    end
    
    return labels
end