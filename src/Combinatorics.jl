
# return a mod b as element in {1, ..., b}
function pmod(a::Int, b::Int) 
    c = a % b
    return c > 0 ?  c : c+b
end

@doc raw"""
    is_weakly_separated(n::Int, v::Vector{Int}, w::Vector{Int})

Test if two vectors `v` and `w` viewed as subsets of `{1 , ..., n }` are weakly separated.
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
    # if we get here, a, b, c, d have been found so v and w are not ws
    return false
end

@doc raw"""
    is_weakly_separated(n::Int, labels::Vector{Vector{Int}})

Test if the vectors contained in `labels` are pairwise weakly separated.
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

Return the labels of the rectangle graph as a vector. The frozen labels are in positions `1` to `n`.
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

# returns the labels of the checkboard graph. Frozen labels first.
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

# returns the non trivial white and black cliques
function compute_cliques(k::Int, labels::Vector{Vector{Int}})
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

# returns the non trivial white and black cliques. Uses known quiver to speed up the computation
function compute_cliques(labels::Vector{Vector{Int}}, quiver::SimpleDiGraph{Int})
    N = length(labels)
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

# returns a graph encoding the adjacency between labels as well as face boundaries
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

# returns face boundaries using known adjacencies
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

# struct for weakly separated collections
mutable struct WSCollection
    k::Int
    n::Int
    labels::Vector{Vector{Int}}
    quiver::SimpleDiGraph{Int}
    whiteCliques::Union{Missing, Dict{Vector{Int}, Vector{Int} } }
    blackCliques::Union{Missing, Dict{Vector{Int}, Vector{Int} } }
end

# WSCollection from labels only
function WSCollection(k::Int, n::Int, labels::Vector{Vector{Int}}, computeCliques::Bool = true)
    Q, W, B = compute_adjacencies(k, n, labels)

    if computeCliques
        return WSCollection(k, n, labels, Q, W, B)
    else
        return WSCollection(k, n, labels, Q, missing, missing)
    end
end

# WSCollection from labels and quiver
function WSCollection(k::Int, n::Int, labels::Vector{Vector{Int}}, quiver::SimpleDiGraph{Int}, computeCliques::Bool = true)
    if !computeCliques
        return WSCollection(k, n, labels, quiver, missing, missing)
    else
        W, B = compute_boundaries(labels, quiver)
        return WSCollection(k, n, labels, quiver, W, B)
    end
end

# overload Base.isequal
function Base.isequal(collection1::WSCollection, collection2::WSCollection) # two WSC's are equal if der sets of labels equal.
    return issetequal(collection1.labels, collection2.labels)
end

# overload Base.:(==)
Base.:(==)(collection1::WSCollection, collection2::WSCollection) = Base.isequal(collection1, collection2)

# return the wsc corresponding to the checkboard graph 
function checkboard_collection(k::Int, n::Int) # TODO use known quiver to speed up computation
    return WSCollection(k, n, checkboard_labels(k, n))
end

# return the wsc corresponding to the rectangle graph
function rectangle_collection(k::Int, n::Int) # TODO use known quiver to speed up computation
    return WSCollection(k, n, rectangle_labels(k, n))
end


function dual_checkboard_collection(k::Int, n::Int) # TODO use known quiver to speed up computation
    return WSCollection(k, n, dual_checkboard_labels(k, n))
end


function dual_rectangle_collection(k::Int, n::Int) # TODO use known quiver to speed up computation
    return WSCollection(k, n, dual_rectangle_labels(k, n))
end


function is_frozen(collection::WSCollection, i::Int) 
    return i <= collection.n
end


function is_mutable(collection::WSCollection, i::Int) 
    return !is_frozen(collection, i) && Graphs.degree(collection.quiver, [i])[1] == 4 
end


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
    end

    return collection
end


function mutate(collection::WSCollection, i::Int, mutateCliques::Bool = true)
    return mutate!( deepcopy(collection), i, mutateCliques)
end

# for convenience we may mutate using labels
function mutate!(collection::WSCollection, label::Vector{Int}, mutateCliques::Bool = true) 
    i = findfirst(x -> x == label, collection.labels)

    if isnothing(i)
        error("$label is not part of the collection")
    end

    return mutate!(collection, i, mutateCliques)
end


function mutate(collection::WSCollection, label::Vector{Int}, mutateCliques::Bool = true)
    return mutate!( deepcopy(collection), label, mutateCliques)
end


function rotate_collection(k::Int, n::Int, labels::Vector{Vector{Int}}, amount::Int) # TODO obsolete ?
    shift = x -> pmod(x + amount, n)

    for i = n+1:length(labels)
        labels[i] = sort(shift.(labels[i]))
    end

    return WSCollection(k, n, labels)
end


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


function rotate_collection(collection::WSCollection, amount::Int)
    return rotate_collection!(deepcopy(collection), amount)
end


function reflect_collection(k::Int, n::Int, labels::Vector{Vector{Int}}, axis::Int = 1) # TODO obsolete ?
    reflect = x -> pmod(1 + axis - x, n)

    for i = n+1:length(labels)
        labels[i] = sort(reflect.(labels[i]))
    end

    return WSCollection(k, n, labels)
end


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


function reflect_collection(collection::WSCollection, axis::Int = 1)
    return reflect_collection!(deepcopy(collection), axis)
end


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

    I = [i for i in 1:n]
    M = [i for i in n+1:length(labels)]

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


function complement_collection(k::Int, n::Int, labels::Vector{Vector{Int}}) # TODO obsolete ?

    # complement labels
    for i = 0:n-1 # frozen labels
        F = [pmod(l+i, n) for l = 1:n-k]
        labels[i+1] = sort(F)
    end

    I = [i for i in 1:n]
    M = [i for i in n+1:length(labels)]

    complement = A -> setdiff(I, A)
    labels[M] = complement.(labels[M])

    return WSCollection(n-k, n, labels)
end


function complement_collection(collection::WSCollection)
    return complement_collection!(deepcopy(collection))
end


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

    I = [i for i in 1:n]
    M = [i for i in n+1:length(labels)]

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


function swaped_colors_collection(k::Int, n::Int, labels::Vector{Vector{Int}}) # TODO obsolete ?
    # swapping colors = complement + rotate by k

    for i = 0:n-1 # frozen labels
        F = [pmod(l+i, n) for l = 1:n-k]
        labels[i+1] = sort(F)
    end

    I = [i for i in 1:n]
    M = [i for i in n+1:length(labels)]

    complement = A -> setdiff(I, A)
    labels[M] = complement.(labels[M])
    shift = x -> pmod(x + k, n)

    for i = n+1:length(labels)
        labels[i] = sort(shift.(labels[i]))
    end

    return WSCollection(n-k, n, labels)
end


function swaped_colors_collection(collection::WSCollection)
    return swaped_colors_collection!(deepcopy(collection))
end

# extend to maximal weakly separated collection using brute force
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

# extend to maximal weakly separated collection using know collection, then brute fore
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


function extend_weakly_separated!(labels::Vector{Vector{Int}}, collection::WSCollection)
    return extend_weakly_separated!(collection.k, collection.n, labels, collection.labels)
end


function extend_to_collection(k::Int, n::Int, labels::Vector{Vector{Int}})
    return WSCollection(k, n, extend_weakly_separated!(k, n, deepcopy(labels)))
end


function extend_to_collection(k::Int, n::Int, labels1::Vector{Vector{Int}}, labels2::Vector{Vector{Int}})
    return WSCollection(k, n, extend_weakly_separated!(k, n, deepcopy(labels1), labels2))
end


function extend_to_collection(labels::Vector{Vector{Int}}, collection::WSCollection)
    return WSCollection(collection.k, collection.n, extend_weakly_separated!(deepcopy(labels), collection))
end


function super_potential_labels(k::Int, n::Int)
    labels::Vector{Vector{Int}} = Vector()

    I = union(collect(1:k-1), [k+1])

    for i = 0:n-1 
        S = (x -> pmod(x+i, n)).(I)
        push!(labels, sort(S))
    end
    
    return labels
end