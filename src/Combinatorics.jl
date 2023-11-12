
# a mod b, but returns value in [1,b]
function pmod(a::Int, b::Int) 
    c = a % b
    return c > 0 ?  c : c+b
end

# tests if two vectors v and w are weakly separated
function is_weakly_separated(n::Int, v::Vector{Int}, w::Vector{Int}) 
    x = setdiff(v,w)
    y = setdiff(w,v)
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

# tests if the vectors in labels are pairwise weakly separated
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
            L = [sigma(l, Int(floor((i-j)/2))) for l = 1:j]
            R = [sigma(l, n-k+Int(floor((j-i)/2))) for l = 1:k-j]
            push!(labels, sort(union(L, R)))
        end
    end

    return Vector{Vector{Int}}(labels)
end

# returns the labels of the rectangle graph. Frozen labels first.
function rectangle_labels(k::Int, n::Int)
    labels = Vector() 

    for i = 0:n-1 # frozen labels
        F = [pmod(l+i, n) for l = 1:k]
        push!(labels, sort(F))
    end

    for i = 1:n-k-1 # mutable labels
        for j = 1:k-1
            L = [l for l = i+1:i+j]
            R = [r for r = n-k+1+j:n]
            push!(labels, union(L, R))
        end
    end

    return Vector{Vector{Int}}(labels)
end

# returns the non trivial white and black cliques as Dict{ Vector{Int}, Set{Vector{Int}} }
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

# returns a graph encoding the adjacency between labels as well as face boundaries as Dict{ Vector{Int}, Vector{Vector{Int}} }
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
        C = collect(W[K])
        C_minus_K = (x -> setdiff(x, K)).(C)
        
        p = sortperm(C_minus_K)
        C = [labelPos[c] for c in C]
        C = C[p]
        W[K] = C

        add_edges(C)
    end

    for L in keys(B) # compute boundary for non trivial black cliques (dont add edges here to avoid 2-cycles)
        C = collect(B[L])
        L_minus_C = (x -> setdiff(L, x)).(C)
        
        p = sortperm(L_minus_C)
        C = C[p]
        B[L] = [labelPos[c] for c in C]
    end

    return Q, W, B
end

# TODO
# function compute_adjacencies(k::Int, n::Int, labels::Vector{Vector{Int}}, quiver::SimpleDiGraph{Int})
    

# end

# struct for weakly separated collections
mutable struct WSCollection
    k::Int
    n::Int
    labels::Vector{Vector{Int}}
    quiver::SimpleDiGraph{Int}
    whiteCliques::Union{Missing, Dict{Vector{Int}, Vector{Int} } }
    blackCliques::Union{Missing, Dict{Vector{Int}, Vector{Int} } }
end


function WSCollection(k::Int, n::Int, labels::Vector{Vector{Int}}, 
                        quiver::SimpleDiGraph{Int}; 
                        whiteCliques::Union{Missing, Dict{Vector{Int}, Vector{Int}} } = missing, 
                        blackCliques::Union{Missing, Dict{Vector{Int}, Vector{Int}} } = missing)

    return WSCollection(k, n, labels, quiver, whiteCliques, blackCliques)
end


function WSCollection(k::Int, n::Int, labels::Vector{Vector{Int}}, computeCliques::Bool = true)
    Q, W, B = compute_adjacencies(k, n, labels)

    if computeCliques
        return WSCollection(k, n, labels, Q, W, B)
    else
        return WSCollection(k, n, labels, Q)
    end
end

# TODO
# function WSCollection(k::Int, n::Int, labels::Vector{Vector{Int}}, quiver::SimpleDiGraph{Int}, computeCliques::Bool = true)
    

# end


function Base.isequal(collection1::WSCollection, collection2::WSCollection) #two WSC's are equal if der sets of labels equal.
    return issetequal(collection1.labels, collection2.labels)
end


Base.:(==)(collection1::WSCollection, collection2::WSCollection) = Base.isequal(collection1, collection2)


function is_frozen(collection::WSCollection, i::Int) # may change this at some point
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


function checkboard_collection(k::Int, n::Int) # return the wsc corresponding to the checkboard graph
    labels = checkboard_labels(k, n) 
    Q, W, B = compute_adjacencies(k, n, labels) # TODO speed up using known quiver

    return WSCollection(k, n, labels, Q, W, B)
end


function rectangle_collection(k::Int, n::Int)
    labels = rectangle_labels(k, n) 
    Q, W, B = compute_adjacencies(k, n, labels) # TODO speed up using known quiver

    return WSCollection(k, n, labels, Q, W, B)
end


function rotate_collection(k::Int, n::Int, labels::Vector{Vector{Int}}, amount::Int) # TODO refine
    shift = x -> pmod(x + amount, n)

    for i = n+1:length(labels)
        labels[i] = sort(shift.(labels[i]))
    end
    
    Q, W, B = compute_adjacencies(k, n, labels)

    return WSCollection(k, n, labels, Q, W, B)
end


function rotate_collection(collection::WSCollection, amount::Int)
    labels = deepcopy(collection.labels)
    return rotate_collection(collection.k, collection.n, labels, amount)
end


function reflect_collection(k::Int, n::Int, labels::Vector{Vector{Int}}, axis::Int = 1) # TODO refine
    reflect = x -> pmod(1 + axis - x, n)

    for i = n+1:length(labels)
        labels[i] = sort(reflect.(labels[i]))
    end
    
    Q, W, B = compute_adjacencies(k, n, labels)

    return WSCollection(k, n, labels, Q, W, B)
end


function reflect_collection(collection::WSCollection, axis::Int = 1)
    labels = deepcopy(collection.labels)
    return reflect_collection(collection.k, collection.n, labels, axis)
end


function complement_collection(k::Int, n::Int, labels::Vector{Vector{Int}}) # TODO refine

    for i = 0:n-1 # frozen labels
        F = [pmod(l+i, n) for l = 1:n-k]
        labels[i+1] = sort(F)
    end

    I = [i for i in 1:n]
    M = [i for i in n+1:length(labels)]

    complement = A -> setdiff(I, A)
    labels[M] = complement.(labels[M])

    Q, W, B = compute_adjacencies(n-k, n, labels)

    return WSCollection(n-k, n, labels, Q, W, B)
end


function complement_collection(collection::WSCollection)
    labels = deepcopy(collection.labels)
    return complement_collection(collection.k, collection.n, labels)
end


function swaped_colors_collection(k::Int, n::Int, labels::Vector{Vector{Int}}) # TODO refine
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

    Q, W, B = compute_adjacencies(n-k, n, labels)

    return WSCollection(n-k, n, labels, Q, W, B)

end


function swaped_colors_collection(collection::WSCollection)
    labels = deepcopy(collection.labels)
    return swaped_colors_collection(collection.k, collection.n, labels)
end


function dual_checkboard_collection(k::Int, n::Int) # TODO compute directly from labels
    return complement_collection(n-k, n, checkboard_labels(n-k, n))
end


function dual_rectangle_collection(k::Int, n::Int) # TODO compute directly from labels
    return complement_collection(n-k, n, rectangle_labels(n-k, n))
end
