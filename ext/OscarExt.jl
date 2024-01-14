module OscarExt

using WeaklySeparatedCollections, Oscar
import Graphs as MyGraphs
using Graphs

pmod = WeaklySeparatedCollections.pmod

################## basic seed functionality ##################

# TODO somehow use this
# mutable struct WeaklySeparatedCollections.Seed
#     n_frozen::Int
#     variables::Vector{AbstractAlgebra.Generic.Frac{T}} where T <: RingElem
#     quiver::SimpleDiGraph{Int}
# end


function WeaklySeparatedCollections.Seed(cluster_size::Int, n_frozen::Int, quiver::SimpleDiGraph{Int})
    R, _ = polynomial_ring(ZZ, cluster_size)
    S = fraction_field(R)

    return Seed(n_frozen, gens(S), quiver)
end


function WeaklySeparatedCollections.Seed(collection::WSCollection)
    N = length(collection)

    return Seed(N, deepcopy(collection.n), deepcopy(collection.quiver))
end


Base.getindex(seed::Seed, i::Int) = getindex(seed.variables, i)


Base.setindex!(seed::Seed, x::AbstractAlgebra.Generic.Frac{T} where T <: RingElem, i::Int) = setindex!(seed.variables, x, i)

Base.length(seed::Seed) = length(seed.variables)

function WeaklySeparatedCollections.is_frozen(seed::Seed, i::Int)
    return i <= seed.n_frozen
end


function myProd(array)
    return isempty(array) ? 1 : prod(array)
end

function WeaklySeparatedCollections.mutate!(seed::Seed, i::Int)

    if is_frozen(seed, i)
        error("Trying to mutate the frozen variable $(seed.variables[i]).")
    end

    Q = seed.quiver
    x = seed.variables
    N_in = collect(MyGraphs.inneighbors(Q, i))
    N_out = collect(MyGraphs.outneighbors(Q, i))

    new_x_i = (myProd(x[N_in]) + myProd(x[N_out])) / x[i]
    seed.variables[i] = new_x_i

    # mutate quiver
    for j in N_in # add/remove edges according to quiver mutation
        for l in N_out
            if MyGraphs.has_edge(Q, l, j)
                MyGraphs.rem_edge!(Q, l, j)
            elseif !is_frozen(seed, j) || !is_frozen(seed, l)
                MyGraphs.add_edge!(Q, j, l)
            end
        end
    end

    # reverse edges adjacent to i
    for j in N_in
        MyGraphs.rem_edge!(Q, j, i)
        MyGraphs.add_edge!(Q, i, j)
    end

    for l in N_out
        MyGraphs.rem_edge!(Q, i, l)
        MyGraphs.add_edge!(Q, l, i)
    end

    seed.quiver = Q
    
    return seed
end

function WeaklySeparatedCollections.mutate(seed::Seed, i::Int)
    return mutate!(deepcopy(seed), i)
end

################## special seeds ##################

function WeaklySeparatedCollections.grid_Seed(k::Int, n::Int, quiver::SimpleDiGraph{Int})
    variable_names::Vector{String} = []

    for f in 1:n
        push!(variable_names, "a$(pmod(f+k-1, n))")
    end

    for i in 1:n-k-1
        for j in 1:k-1
            push!(variable_names, "x$(i)$j")
        end
    end

    R, _ = polynomial_ring(ZZ, variable_names)
    S = fraction_field(R)

    return Seed(n, gens(S), quiver)
end


function WeaklySeparatedCollections.grid_Seed(collection::WSCollection)
    grid_Seed(collection.k, collection.n, deepcopy(collection.quiver))
end


function WeaklySeparatedCollections.extended_checkboard_seed(k, n)
    check = checkboard_collection(k, n)
    check_seed = grid_Seed(check)
    T = typeof(check_seed.variables[1])
    X = Array{T}(undef, n-k+1, k+1)

    for i in 0:n-k
        for j in 0:k
            label = checkboard_label(k, n, i, j)
            pos = findfirst(x -> x == label, check.labels)

            X[i+1, j+1] = check_seed.variables[pos]
        end
    end

    return check_seed, X
end

################## superpotential ##################

function WeaklySeparatedCollections.get_superpotential_terms(collection::WSCollection, use_grid = true)
    k = collection.k
    n = collection.n

    terms::Vector{AbstractAlgebra.Generic.Frac{ZZMPolyRingElem}} = []
    super_labels = super_potential_labels(k, n);
    denom_index = 1

    for label in super_labels
        seed = use_grid ? grid_Seed(collection) : Seed(collection)

        if label in collection
            pos = findfirst( x -> x == label, collection.labels)
            push!(terms, seed[pos]/seed[denom_index])
        else
            seq = find_label(collection, label)
            
            for i in seq
                mutate!(seed, i)
            end

            push!(terms, seed[seq[end]]/seed[denom_index])
        end
        denom_index += 1
    end

    return circshift(terms, -k+1)
end


function WeaklySeparatedCollections.checkboard_potential_terms(k, n)
    _, X = extended_checkboard_seed(k, n)
    x = (i, j) -> X[i+1, j+1]

    terms = [x(1, k-1)/x(0, k), x(n-k-1, 1)/x(n-k, 0)]

    for d in 1-k:n-k-2

        (a, b) = d >= 0 ? (d, 0) : (0, -d)

        term = 0
        while a <= n-k && b <= k
            try term += x(a, b+1)*x(a+1, b-1)/(x(a, b)*x(a+1, b)) catch end
            try term += x(a-1, b)*x(a+1, b-1)/(x(a, b-1)*x(a, b)) catch end

            (a, b) = (a+1, b+1)
        end

        push!(terms, term)
    end

    # TODO sort terms to have terms = [p_J1, ... , p_Jn]
    return terms
end

################## Action of cyclic and dihedral group ##################

function WeaklySeparatedCollections.dihedral_perm_group(n::Int) # D_n as specific permutation group
    return sub(cperm(collect(1:n)), perm([pmod(n+2-i, n) for i in 1:n]))
end

function WeaklySeparatedCollections.cyclic_perm_group(n::Int) # C_n as specific permutation group
    return sub(cperm(collect(1:n)))
end

function WeaklySeparatedCollections.standard_form(D::PermGroup, x::PermGroupElem) # return vector v with x = s^v[1]*t^v[2]
    s = gens(D)[1]

    m = 1^x - 1
    x = x*s^-m

    return isone(x) ? [m, 0] : [-m, 1]
end

# TODO kill or rename
# function s_t_perm(D::PermGroup, v::Vector{Int})
#     s, t = gens(D)
#     return s^v[1]*t^v[2]
# end

function Base.:^(collection::WSCollection, x::PermGroupElem) # works for D_n and C_n defined via above functions
    D, _ = dihedral_perm_group( collection.n)
    v = standard_form(D, x)

    res = rotate_collection(collection, v[1])
    return v[2] == 0 ? res : reflect_collection!(res)
end

function Oscar.gset(D::PermGroup, seeds::Vector{WSCollection}; closed::Bool = false) # standard action for gset on WSCollections
    return gset(D, (G, x) -> G^x , seeds; closed = closed)
end

function WeaklySeparatedCollections.get_orbit(collection::WSCollection) # orbits without oscar
    refl = reflect_collection(collection)
    orb = Set([collection, refl])

    for i in 1:collection.n-1
        push!(orb, rotate_collection(collection, i), rotate_collection(refl, i))
    end

    return collect(orb)
end

function Oscar.stabilizer(D::PermGroup, collection::WSCollection)
    return stabilizer(D, collection, ^)
end

function WeaklySeparatedCollections.get_stabilizer(collection::WSCollection)
    k, n = collection.k, collection.n
    D, _ = dihedral_perm_group(n)

    S, _ = collect(stabilizer(D, collection))
    return S
end

end

