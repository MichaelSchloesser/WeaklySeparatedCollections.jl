module OscarExt

using WeaklySeparatedCollections, Oscar
import Graphs: SimpleDiGraph, inneighbors, outneighbors, has_edge, add_edge!, rem_edge!
import WeaklySeparatedCollections as WSC

pmod = WSC.pmod
frozen_label = WSC.frozen_label

################## basic seed functionality ##################

# TODO allow for custom printing
function WSC.Seed(cluster_size::Int, n_frozen::Int, quiver::SimpleDiGraph{Int})
    R, _ = polynomial_ring(ZZ, cluster_size)
    S = fraction_field(R)

    return Seed(n_frozen, gens(S), deepcopy(quiver))
end

# TODO add version that prints variables with left/right labels
function WSC.Seed(collection::WSCollection)
    N = length(collection)

    return Seed(N, deepcopy(collection.n), deepcopy(collection.quiver))
end


Base.getindex(seed::Seed, i::Int) = getindex(seed.variables, i)

Base.getindex(seed::Seed, v::Vector{Int}) = getindex(seed.variables, v)

Base.setindex!(seed::Seed, x::AbstractAlgebra.Generic.Frac{T} where T <: RingElem, i::Int) = setindex!(seed.variables, x, i)

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

function WSC.is_frozen(seed::Seed, i::Int)
    return i <= seed.n_frozen
end

function myProd(array)
    return isempty(array) ? 1 : prod(array)
end

function WSC.mutate!(seed::Seed, i::Int)

    if is_frozen(seed, i)
        error("Trying to mutate the frozen variable $(seed.variables[i]).")
    end

    Q = seed.quiver
    x = seed.variables
    N_in = collect(inneighbors(Q, i))
    N_out = collect(outneighbors(Q, i))

    new_x_i = (myProd(x[N_in]) + myProd(x[N_out])) / x[i]
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

    seed.quiver = Q
    
    return seed
end

function WSC.mutate(seed::Seed, i::Int)
    return mutate!(deepcopy(seed), i)
end

################## special seeds ##################

function WSC.grid_Seed(k::Int, n::Int, quiver::SimpleDiGraph{Int})
    variable_names::Vector{String} = []

    # TODO make frozen actually depend on the labels
    for f in 1:n
        push!(variable_names, "a$(pmod(f+k-1, n))")
    end

    for i in 1:n-k-1
        for j in 1:k-1
            push!(variable_names, "x$i$j")
        end
    end

    R, _ = polynomial_ring(ZZ, variable_names)
    S = fraction_field(R)

    return Seed(n, gens(S), quiver)
end


function WSC.grid_Seed(collection::WSCollection)
    grid_Seed(collection.k, collection.n, deepcopy(collection.quiver))
end


function WSC.extended_checkboard_seed(k, n)
    check = checkboard_collection(k, n)
    check_seed = grid_Seed(check)
    T = typeof(check_seed[1])
    X = Array{T}(undef, n-k+1, k+1)

    for i in 0:n-k
        for j in 0:k
            label = checkboard_label(k, n, i, j)
            pos = findfirst(x -> x == label, check.labels)

            X[i+1, j+1] = check_seed[pos]
        end
    end

    return check_seed, X
end


function WSC.extended_rectangle_seed(k, n)
    rec = rectangle_collection(k, n)
    rec_seed = grid_Seed(rec)
    T = typeof(rec_seed[1])
    X = Array{T}(undef, n-k+1, k+1)

    for i in 0:n-k
        for j in 0:k
            label = rectangle_label(k, n, i, j)
            pos = findfirst(x -> x == label, rec.labels)

            X[i+1, j+1] = rec_seed[pos]
        end
    end

    return rec_seed, X
end

################## superpotential ##################

# TODO allow to pass seed, or custom printing
function WSC.get_superpotential_terms(collection::WSCollection; use_grid = false)
    k = collection.k
    n = collection.n

    terms::Vector{AbstractAlgebra.Generic.Frac{ZZMPolyRingElem}} = []
    super_labels = super_potential_labels(k, n)

    for i in 1:n
        super = super_labels[i]
        denom_index = findfirst( x -> x == frozen_label(k, n, i), collection.labels)

        seed = use_grid ? grid_Seed(collection) : Seed(collection)

        if super in collection
            pos = findfirst( x -> x == super, collection.labels)
            push!(terms, seed[pos]/seed[denom_index])
        else
            seq = find_label(collection, super)
            
            for i in seq
                mutate!(seed, i)
            end

            push!(terms, seed[seq[end]]/seed[denom_index])
        end
    end

    return circshift(terms, + k - 1)
end


function WSC.checkboard_potential_terms(k, n)
    _, X = extended_checkboard_seed(k, n)
    x = (i, j) -> X[i+1, j+1]

    terms = [x(1, 1) for i in 1:n]
    terms[Int(floor( k/2 ))] = x(1, k-1)/x(0, k)
    terms[Int(floor( (n+k)/2 ))] = x(n-k-1, 1)/x(n-k, 0)
    
    for d in 1-k:n-k-2

        (a, b) = d >= 0 ? (d, 0) : (0, -d)

        term = 0
        while a <= n-k && b <= k
            try term += x(a, b+1)*x(a+1, b-1)/(x(a, b)*x(a+1, b)) catch end
            try term += x(a-1, b)*x(a+1, b-1)/(x(a, b-1)*x(a, b)) catch end

            (a, b) = (a+1, b+1)
        end

        if d % 2 == 0
            terms[pmod( Int(k + d/2), n)] = term
        else
            terms[pmod( Int(n - (d+1)/2), n)] = term
        end
    end

    return terms
end


################## newton okounkov bodies ##################


function WSC.newton_okounkov_inequalities(collection::WSCollection, r::Int = 1; q_term_index::Int = collection.k)
    k, n = collection.k, collection.n
    T = get_superpotential_terms(collection; use_grid = false)
    empty_index = findfirst( x -> x == WSC.frozen_label(k, n, n-k+1), collection.labels)

    A::Vector{Vector{Int}} = []
    b::Vector{Int} = []

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

# return the inequalities of the newton okounkov body associated to the checkboard graph
function WSC.checkboard_inequalities(k::Int, n::Int, r::Int = 1; q_term_index::Int = k)
    T = checkboard_potential_terms(k, n)
    empty_index = n-k+1
    A::Vector{Vector{Int}} = []
    b::Vector{Int} = []

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
    return sub(cperm(collect(1:n)), perm([pmod(n+2-i, n) for i in 1:n]))
end

function WSC.cyclic_perm_group(n::Int) # C_n as specific permutation group
    return sub(cperm(collect(1:n)))
end

function WSC.standard_form(D::PermGroup, x::PermGroupElem) # return vector v with x = s^v[1]*t^v[2]
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

# TODO change so that the permutation is instead used directly on labls -> no need for standard_form
function Base.:^(collection::WSCollection, x::PermGroupElem) # works for D_n and C_n defined via above functions
    D, _ = dihedral_perm_group( collection.n)
    v = standard_form(D, x)

    res = rotate(collection, v[1])
    return v[2] == 0 ? res : reflect!(res)
end

function Oscar.gset(D::PermGroup, seeds::Vector{WSCollection}; closed::Bool = false) # standard action for gset on WSCollections
    return gset(D, (G, x) -> G^x , seeds; closed = closed)
end

function WSC.get_orbit(collection::WSCollection) # orbits without oscar
    orb = Set([collection])

    for i in 1:collection.n-1
        push!(orb, rotate(collection, i))
    end

    refl = reflect(collection)
    push!(orb, refl)

    for i in 1:collection.n-1
        push!(orb, rotate(refl, i))
    end

    return collect(orb)
end

function Oscar.stabilizer(D::PermGroup, collection::WSCollection)
    return stabilizer(D, collection, ^)
end

function WSC.get_stabilizer(collection::WSCollection)
    k, n = collection.k, collection.n
    D, _ = dihedral_perm_group(n)

    S, _ = collect(stabilizer(D, collection))
    return S
end

end

