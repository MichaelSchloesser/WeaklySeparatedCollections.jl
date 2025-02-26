module OscarExt

using WeaklySeparatedCollections, Oscar
import Graphs: SimpleDiGraph, inneighbors, outneighbors, has_edge, add_edge!, rem_edge!
import WeaklySeparatedCollections as WSC

findindex = WSC.findindex
super_potential_label = WSC.super_potential_label

################## basic seed functionality ##################

function WSC.Seed(cluster_size::Int, n_frozen::Int, quiver::SimpleDiGraph{T}) where T <: Integer
    R, _ = polynomial_ring(ZZ, cluster_size)
    S = fraction_field(R)

    return Seed{elem_type(S), T}(n_frozen, gens(S), SimpleDiGraph(quiver))
end

function WSC.Seed(variable_names::Vector{String}, n_frozen::Int, quiver::SimpleDiGraph{T}) where T <: Integer
    R, _ = polynomial_ring(ZZ, variable_names)
    S = fraction_field(R)

    return Seed{elem_type(S), T}(n_frozen, gens(S), SimpleDiGraph(quiver))
end

# TODO add version that prints variables with left/right labels
function WSC.Seed(C::WSCollection) 
    N = length(C)

    return Seed(N, C.n, SimpleDiGraph(C.quiver))
end

Base.getindex(seed::Seed, itr...) = getindex(seed.variables, itr...)

Base.setindex!(seed::Seed, x, i::Int) = setindex!(seed.variables, x, i)

function Base.deepcopy(seed::Seed)
    n = seed.n_frozen
    vars = deepcopy(seed.variables)
    Q = SimpleDiGraph(seed.quiver)

    return Seed(n, vars, Q)
end

Base.length(seed::Seed) = length(seed.variables)

function Base.show(io::IO, seed::Seed)
    s = "Seed with $(seed.n_frozen) frozen and $(length(seed) - seed.n_frozen) mutable variables"
    print(io, s)
end

function Base.print(seed::Seed; full::Bool = false)
    s = "Seed with $(seed.n_frozen) frozen and $(length(seed) - seed.n_frozen) mutable variables"

    if full
        s *= ": \n"
        for var in seed.variables
            s *= "$var\n"
        end
    end
    print(s)
end

function Base.println(seed::Seed; full::Bool = false)
    print(seed; full)
    print("\n")
end

@doc raw"""
    is_frozen(seed::Seed, i::Int)

Return true if the `i-th` clustervariable of `seed` is frozen.
"""
function WSC.is_frozen(seed::Seed, i::T) where T <: Integer
    return i <= seed.n_frozen
end

function myProd(x, array)
    res = one(x[1])

    for a in array
        res*= x[a]
    end

    return res
end

# TODO this only really supports mutations coming from a WSC. need non multigraph for general case
@doc raw"""
    mutate!(seed::Seed, i::Int)

Mutate the `seed` in direction `i` if `i` is the index of a mutable variable.
"""
function WSC.mutate!(seed::Seed, i::T) where T <: Integer

    if is_frozen(seed, i)
        error("Trying to mutate the frozen variable $(seed.variables[i]).")
    end

    Q = seed.quiver
    x = seed.variables

    N_in = copy(inneighbors(Q, i))
    N_out = copy(outneighbors(Q, i))

    new_x_i = (myProd(x, N_in) + myProd(x, N_out)) / x[i]
    seed.variables[i] = new_x_i

    # mutate quiver
    for j in N_in # add/remove edges according to quiver mutation
        for l in N_out
            if has_edge(Q, l, j)
                rem_edge!(Q, l, j)
            elseif !is_frozen(seed, j) || !is_frozen(seed, l)
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
    
    return seed
end

@doc raw"""
    mutate(seed::Seed, i::Int)

Mutate the `seed` in direction `i` if `i` is the index of a mutable variable.
"""
function WSC.mutate(seed::Seed, i::Int)
    return mutate!(deepcopy(seed), i)
end

################## laurent expansions ##################

function WSC.laurent_expansion(target_label::Vector{S}, C::WSCollection{S}, seed::Seed = Seed(C)) where S <: Integer
    s = deepcopy(seed)

    if target_label in C
        return s[ findindex(C.labels, target_label) ]
    else
        seq = find_label(C, target_label)
        
        for i in seq
            mutate!(s, i)
        end

        return s[seq[end]]
    end
end

function WSC.laurent_expansion(target_labels::Vector{Vector{S}}, C::WSCollection{S}, seed::Seed = Seed(C)) where S <: Integer
    f = L -> laurent_expansion(L, C, seed)
    return f.(target_labels)
end

function WSC.laurent_expansion(target_label_it, C::WSCollection{S}, seed::Seed = Seed(C)) where S <: Integer
    T = typeof(seed[1])
    res = Vector{T}(undef, binomial(C.n, C.k))

    i = 1
    for L in target_label_it
        res[i] = laurent_expansion(L, C, seed)
        i += 1
    end

    return res
end

################## special seeds ##################

function WSC.grid_seed(n::Int, height::Int, width::Int, quiver::SimpleDiGraph{Int})
    variable_names = Vector{String}()

    for f in 1:n
        push!(variable_names, "a$f")
    end

    for i in 1:height-1
        for j in 1:width-1
            push!(variable_names, "x$i$j")
        end
    end

    R, _ = polynomial_ring(ZZ, variable_names)
    S = fraction_field(R)

    return Seed(n, gens(S), quiver)
end


function WSC.grid_seed(collection::WSCollection, height::Int = collection.n - collection.k, width::Int = collection.k)
    grid_seed(collection.n, height, width,  SimpleDiGraph(collection.quiver))
end


function WSC.extended_checkboard_seed(k, n)
    check = checkboard_collection(k, n)
    check_seed = grid_seed(check)
    T = typeof(check_seed[1])
    X = Array{T}(undef, n-k+1, k+1)

    for i in 0:n-k
        for j in 0:k
            label = checkboard_label(k, n, i, j)
            pos = findindex(check.labels, label)

            X[i+1, j+1] = check_seed[pos]
        end
    end

    return check_seed, X
end


function WSC.extended_rectangle_seed(k, n)
    rec = rectangle_collection(k, n)
    rec_seed = grid_seed(rec)
    T = typeof(rec_seed[1])
    X = Array{T}(undef, n-k+1, k+1)

    for i in 0:n-k
        for j in 0:k
            label = rectangle_label(k, n, i, j)
            pos = findindex(rec.labels, label)

            X[i+1, j+1] = rec_seed[pos]
        end
    end

    return rec_seed, X
end


################## superpotential ##################


function WSC.get_superpotential_terms(collection::WSCollection{S}, seed::Seed = Seed(collection)) where S <: Integer
    k = collection.k
    n = collection.n
    T = typeof(seed[1])

    terms = Vector{T}()

    for i in 1:n
        super = super_potential_label(k, n, i, S)
        denom_index = findindex(collection.labels, frozen_label(k, n, i, S))

        s = deepcopy(seed)

        if super in collection
            pos = findindex(collection.labels, super)
            push!(terms, s[pos]/s[denom_index])
        else
            seq = find_label(collection, super)
            
            for i in seq
                mutate!(s, i)
            end

            push!(terms, s[seq[end]]/s[denom_index])
        end
    end

    return terms
end


function WSC.checkboard_potential_terms(k::Int, n::Int)
    _, X = extended_checkboard_seed(k, n)
    x = (i, j) -> X[i+1, j+1]

    terms = [x(1, 1) for i in 1:n]
    terms[fld(k, 2)] = x(1, k-1)/x(0, k)
    terms[fld(n+k, 2)] = x(n-k-1, 1)/x(n-k, 0)
    
    for d in 1-k:n-k-2

        (a, b) = d >= 0 ? (d, 0) : (0, -d)

        term = 0
        while a <= n-k && b <= k
            try term += x(a, b+1)*x(a+1, b-1)/(x(a, b)*x(a+1, b)) catch end
            try term += x(a-1, b)*x(a+1, b-1)/(x(a, b-1)*x(a, b)) catch end

            (a, b) = (a+1, b+1)
        end

        if d % 2 == 0
            terms[mod1( k + div(d, 2), n)] = term
        else
            terms[mod1( n - div(d+1, 2), n)] = term
        end
    end

    return terms
end


################## newton okounkov bodies ##################


function WSC.newton_okounkov_inequalities(collection::WSCollection, r::Int = 1; q_term_index::Int = collection.k)
    k, n = collection.k, collection.n
    T = get_superpotential_terms(collection)
    empty_index = findindex(collection.labels, frozen_label(k, n, n)) # TODO changed frozen_label(k, n, n-k+1)  to  frozen_label(k, n, n)

    A = Vector{Vector{Int}}()
    b = Vector{Int}()

    for i in 1:n
        numer, denom = numerator(T[i]), denominator(T[i])
        denom_exp = deleteat!(exponent_vector(denom, 1), empty_index)
        for t in terms(numer)

            # add row to A
            t_exp = deleteat!(exponent_vector(t, 1), empty_index)
            exponent_vec = denom_exp - t_exp                       # note that we negate here to get Ax <= b
            push!(A, exponent_vec)

            # add entry to b
            i == q_term_index ? push!(b, r) : push!(b, 0)
        end
    end

    return Matrix(reduce(hcat, A)'), b
end

# return the inequalities of the newton okounkov body associated to the checkboard graph
function WSC.checkboard_inequalities(k::Int, n::Int, r::Int = 1; q_term_index::Int = k)
    T = checkboard_potential_terms(k, n)
    empty_index = n # TODO changed empty_index = n-k+1  to  empty_index = n
    A = Vector{Vector{Int}}()
    b = Vector{Int}()

    for i in 1:n
        numer, denom = numerator(T[i]), denominator(T[i])
        denom_exp = deleteat!(exponent_vector(denom, 1), empty_index)
        for t in terms(numer)

            # add row to A
            t_exp = deleteat!(exponent_vector(t, 1), empty_index)
            exponent_vec = denom_exp - t_exp
            push!(A, exponent_vec)

            # add entry to b
            i == q_term_index ? push!(b, r) : push!(b, 0)
        end
    end

    return Matrix(reduce(hcat, A)'), b
end

function WSC.checkboard_body(k::Int, n::Int; q_term_index::Int = k)
    return polyhedron(checkboard_inequalities(k, n; q_term_index = q_term_index))
end

function WSC.newton_okounkov_body(collection::WSCollection; q_term_index::Int = collection.k)
    return polyhedron(newton_okounkov_inequalities(collection::WSCollection; q_term_index = q_term_index))
end


################## Action of cyclic and dihedral group ##################

function WSC.dihedral_perm_group(n::Int) # D_n as specific permutation group
    return permutation_group(n, [cperm(collect(1:n)), perm([mod1(n+2-i, n) for i in 1:n])] )
end

function WSC.cyclic_perm_group(n::Int) # C_n as specific permutation group
    return permutation_group(n, [cperm(collect(1:n))] )
end

@doc raw"""
    ^(collection::WSCollection, p::PermGroupElem)

Let `p` act on `collection` via the natural right action.
"""
function Base.:^(collection::WSCollection{T}, p::PermGroupElem) where T <: Integer# works for D_n and C_n defined via above functions
    f = let p = Vector{T}(p)
        x -> p[x]
    end 
    return WSC.apply_to_collection!(f, deepcopy(collection))
end

@doc raw"""
    gset(D::PermGroup, seeds::Vector{WSCollection}; closed::Bool = false)

Return the G-set of the natural action of `D` on the specified WSC's in `seeds`.
"""
function Oscar.gset(D::PermGroup, seeds::Vector{WSCollection{T}}; closed::Bool = false) where T <: Integer # standard action for gset on WSCollections
    return gset(D, ^ , seeds; closed = closed)
end

@doc raw"""
    orbit(D::PermGroup, collection::WSCollection)

Return the orbit of `collection` under the natural action of `D`.
"""
function Oscar.orbit(D::PermGroup, collection::WSCollection)
    M = gset(D, [collection])
    return orbit(M, collection)
end

@doc raw"""
    orbit(collection::WSCollection)

Return the orbit of `collection` under the natural action of the dihedral group.
"""
function Oscar.orbit(collection::WSCollection)
    D = WSC.dihedral_perm_group(collection.n)
    M = gset(D, ^, [collection])
    return orbit(M, collection)
end

@doc raw"""
    stabilizer(D::PermGroup, collection::WSCollection)

Return the stabilizer of `collection` under the natural action of `D`.
"""
function Oscar.stabilizer(D::PermGroup, collection::WSCollection)
    return stabilizer(D, collection, ^)
end

@doc raw"""
    stabilizer(collection::WSCollection)

Return the stabilizer of `collection` under the natural action of the dihedral group.
"""
function Oscar.stabilizer(collection::WSCollection)
    D = WSC.dihedral_perm_group(collection.n)
    return stabilizer(D, collection)
end

end

