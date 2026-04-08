
@inline function update!(dict::Dict{T, V}, key::T, val::V) where {T, V}
    index = Base.ht_keyindex2!(dict, key)
    if index > 0
        @inbounds dict.vals[index] = val
    else
        @inbounds Base._setindex!(dict, val, key, -index)
    end
end

function limit_searchspace!(mutables::Vector{T}, C1::WSCollection, C2::WSCollection) where T <: Integer
    x = 1

    for m in mutables
        @inbounds @views C1[m] in C2[C2.n+1:end] || (mutables[x] = m; x += 1)
    end

    return resize!(mutables, x-1)
end

function limit_searchspace!(mutables::Vector{T}, num_mutables, C1::WSCollection, su_target) where T <: Integer
    x = 1

    for i in 1:num_mutables
        @inbounds m = mutables[i]
        @inbounds C1[m] in su_target || (mutables[x] = m; x += 1)
    end

    return x-1
end

################## uninformed searching ##################

@doc raw"""
    BFS(root::WSCollection, target::WSCollection)

Return a minimal sequence of mutations, transforming `root` into `target`.
This sequence is computed by a breadth first search. 

# Keyword arguments:
- `limitSearchSpace::Bool = true`

If `limitSearchSpace` is set to true then labels already contained
in `target` will never be mutated.
"""
function BFS(root::WSCollection{T}, target::WSCollection{T}; limitSearchSpace::Bool = true) where T
    queue = Queue{WSCollection}()
    parent_explored = Dict{Vector{T}, Int}()

    N = length(root)-root.n
    mutables = Vector{Int}(undef, N)
    num_mutables = N

    enqueue!(queue, WSCollection(root))
    su_root = sorted_unfrozen(root)
    su_target = sorted_unfrozen(target)
    su_target_set = Set(su_target)
    update!(parent_explored, su_root, 0)

    su = Vector{T}(undef, N)
    while !isempty(queue)
        current = dequeue!(queue)
        sorted_unfrozen!(current, su) # su_current

        if su == su_target
            sequence = Vector{Int}()

            while su != su_root
                m = parent_explored[su]
                mutate!(current, m)
                sorted_unfrozen!(current, su)
                push!(sequence, m)
            end

            return reverse!(sequence)
        end

        num_mutables = get_mutables!(current, mutables)
        limitSearchSpace && (num_mutables = limit_searchspace!(mutables, num_mutables, current, su_target_set))
        camefrom = parent_explored[su]

        for i in 1:num_mutables
            @inbounds m = mutables[i]
            m == camefrom && continue
            
            @inbounds temp = current[m]
            @inbounds current.labels[m] = peek(current, m)
            sorted_unfrozen!(current, su) # su_next
            @inbounds current.labels[m] = temp
            
            index = Base.ht_keyindex2!(parent_explored, su)
            if index < 0
                Base._setindex!(parent_explored, m, copy(su), -index)
                enqueue!(queue, mutate(current, m))
            end
        end
    end
    # a path always exist so we never get here
end

@doc raw"""
    DFS(root::WSCollection, target::WSCollection)

Return a sequence of mutations, transforming `root` into `target`.
This sequence is computed by a depth first search. 

# Keyword arguments:
- `limitSearchSpace::Bool = true`

If `limitSearchSpace` is set to true then labels already contained
in `target` will never be mutated.
"""
function DFS(root::WSCollection{T}, target::WSCollection{T}; limitSearchSpace::Bool = true) where T
    stack = Stack{WSCollection}()
    explored = Dict{Vector{T}, Nothing}() # = Set
    parent = Dict{Vector{T}, Int}()

    N = length(root)-root.n
    mutables = Vector{Int}(undef, N)
    num_mutables = N
    
    push!(stack, WSCollection(root))
    su_root = sorted_unfrozen(root)
    su_target = sorted_unfrozen(target)
    su_target_set = Set(su_target)
    update!(parent, su_root, 0)
    
    su = Vector{Int}(undef, N)

    while !isempty(stack)
        current = pop!(stack)
        sorted_unfrozen!(current, su)
        
        if su == su_target
            sequence = Vector{Int}()

            while su != su_root
                m = parent[su]
                mutate!(current, m)
                sorted_unfrozen!(current, su)
                push!(sequence, m)
            end

            return reverse!(sequence)
        end

        index = Base.ht_keyindex2!(explored, su)
        if index < 0
            Base._setindex!(explored, nothing, copy(su), -index)
            
            num_mutables = get_mutables!(current, mutables)
            limitSearchSpace && (num_mutables = limit_searchspace!(mutables, num_mutables, current, su_target_set))
            camefrom = parent[su]

            for i in 1:num_mutables
                @inbounds m = mutables[i]
                m == camefrom && continue

                @inbounds temp = current[m]
                @inbounds current.labels[m] = peek(current, m)
                sorted_unfrozen!(current, su) 
                @inbounds current.labels[m] = temp

                index = Base.ht_keyindex(explored, su)
                if index < 0
                    push!(stack, mutate(current, m))
                    update!(parent, copy(su), m)
                end
            end
        end
    end
end

# TODO add docstring
function wscs(root::WSCollection{T}) where T
    # TODO if we knew how big these get we could use sizehint
    queue = Queue{Tuple{WSCollection, Int}}()
    wsc_list = Dict{Vector{T}, Nothing}()

    N = length(root)-root.n
    mutables = Vector{Int}(undef, N)
    su_next = Vector{Int}(undef, N)
    num_mutables = N

    update!(wsc_list, sorted_unfrozen(root), nothing)
    enqueue!(queue, (WSCollection(root), 0))

    while !isempty(queue)
        current, camefrom = dequeue!(queue)
        num_mutables = get_mutables!(current, mutables)

        for i in 1:num_mutables
            @inbounds m = mutables[i]
            m == camefrom && continue
    
            @inbounds temp = current[m]
            @inbounds current.labels[m] = peek(current, m)
            sorted_unfrozen!(current, su_next)
            @inbounds current.labels[m] = temp

            index = Base.ht_keyindex2!(wsc_list, su_next)
            if index < 0
                Base._setindex!(wsc_list, nothing, copy(su_next), -index)
                enqueue!(queue, (mutate(current, m), m))
            end
            
        end

    end

    return keys(wsc_list)
end

function wscs(k::Int, n::Int, T::Type = Int)
    return wscs( rec_collection(k, n, T))
end


# TODO rework
@doc raw"""
    generalized_associahedron(root::WSCollection)

Return all maximal weakly separated collections of same type as `root`
together with a graph that decribes mutations between the wsc's. 
"""
function generalized_associahedron(root::WSCollection)
    queue = Queue{Tuple{WSCollection, Int}}()
    wsc_list = Vector{WSCollection}()
    associahedron = SimpleGraph(1)

    push!(wsc_list, WSCollection(root, computeCliques = false))
    enqueue!(queue, (WSCollection(root, computeCliques = false), 0))
    current_index = 1

    while !isempty(queue)
        current, camefrom = dequeue!(queue)
        mutables = get_mutables(current)

        for m in mutables
            m == camefrom && continue
            next = mutate!(copy_without_cliques(current), m)
            next_index = findindex(wsc_list, next)

            if next_index == 0
                push!(wsc_list, next)
                enqueue!(queue, (next, m))

                add_vertex!(associahedron)
                add_edge!(associahedron, current_index, nv(associahedron))
            else
                add_edge!(associahedron, current_index, next_index)
            end
        end

        current_index += 1
    end

    return wsc_list, associahedron
end

@doc raw"""
    generalized_associahedron(root::WSCollection)

Return all maximal weakly separated collections of type `k`, `n`
together with a graph that decribes mutations between the wsc's. 
"""
function generalized_associahedron(k::Int, n::Int, T::Type = Int)
    return generalized_associahedron( rec_collection(k, n, T))
end

################## heuristics ##################

function setdiff_length(w, x)
    res = 0 

    for y in w
        y in x || (res += 1)
    end

    return res
end

@doc raw"""
    number_wrong_labels(C::WSCollection, target::WSCollection)

Return the number of labels in `C` that do not occur in `target`.
"""
function number_wrong_labels(C::WSCollection, target::WSCollection) 
    n = C.n
    return @inbounds @views setdiff_length(C.labels[n+1:end], target.labels[n+1:end])
end


function number_wrong_labels_change(old_label, new_label, h_value, current::WSCollection, su_target)
    return h_value + (old_label in su_target) - (new_label in su_target)
end

function estimate(w, x)
    return count_ones(w & ~x)
end

@doc raw"""
    min_label_dist(C::WSCollection, target::WSCollection)

Return the sum of minimum label distances, where for each label in `C` 
this distance is calculated as the minimal number of integer pairs one needs 
to exchange in order to obtain a label of `target`.
"""
function min_label_dist(C::WSCollection, target::WSCollection)
    n = C.n
    # TODO may be faster to just use C.labels
    @inbounds @views wrong_labels = setdiff(C.labels[n+1:end], target.labels[n+1:end]) 

    isempty(wrong_labels) && return 0
    return @views sum( w -> cld( minimum( x -> estimate(w, x), target.labels[n+1:end]), 2), wrong_labels)
end


function min_label_dist_change(old_label, new_label, h_value, current::WSCollection, su_target)

    return h_value + cld( minimum( x -> estimate(new_label, x), su_target), 2) - cld( minimum( x -> estimate(old_label, x), su_target), 2)
end

@doc raw"""
    min_label_dist_experimental(C::WSCollection, target::WSCollection)

Return the sum over minimal label distances of wrong labels in `C`. 

This assumes that a minimal sequence of mutations between WSC's can be 
found while never mutating correct labels i.e. labels that are contained 
in the target WSC.
"""
function min_label_dist_experimental(C::WSCollection, target::WSCollection)
    n = C.n
    @inbounds @views wrong_labels = setdiff(C.labels[n+1:end], target.labels[n+1:end])
    @inbounds @views missing_labels = setdiff(target.labels[n+1:end], C.labels[n+1:end])

    isempty(wrong_labels) && return 0
    return sum( w -> cld( minimum( x -> estimate(w, x), missing_labels), 2), wrong_labels)
end

function estimate_exp(w, x, view, n::Int)
    x in view && return n
    return count_ones(w & ~x)
end

# assumption: dont need to mutate correct labels -> consider missing labels only
function min_label_dist_change_experimental(old_label, new_label, h_value, current::WSCollection, su_target)
    @inbounds @views view = current.labels[current.n+1:end]
    return h_value + cld( minimum( x -> estimate_exp(new_label, x, view, current.n), su_target), 2) - cld( minimum( x -> estimate_exp(old_label, x, view, current.n), su_target), 2)
end

################## informed searching ##################

@doc raw"""
    Astar(root::WSCollection, target::WSCollection)

Return a minimal sequence of mutations, transforming `root` into `target`.
This sequence is computed by a the astar algorithm. 

# Keyword arguments:
- `heuristic::String = "number_wrong_labels"`
- `limitSearchSpace::Bool = true`

The available `heuristic's` are `"number_wrong_labels"`, `"min_label_dist"`
and `"min_label_dist_experimental"`.
If `limitSearchSpace` is set to true then labels already contained
in `target` will never be mutated.
"""
function Astar(root::WSCollection{T}, target::WSCollection{T}; 
            heuristic::String = "number_wrong_labels", limitSearchSpace::Bool = true) where T
    
    N = length(root)-root.n
    mutables = Vector{Int}(undef, N)
    num_mutables = N

    su_root = sorted_unfrozen(root)
    su_target = sorted_unfrozen(target)
    su_target_set = Set(su_target)

    if heuristic == "number_wrong_labels"
        h = number_wrong_labels
        h_change = number_wrong_labels_change
        su_target_it = su_target_set
        
    elseif heuristic == "min_label_dist"
        h = min_label_dist
        h_change = min_label_dist_change
        su_target_it = su_target

    elseif heuristic == "min_label_dist_experimental"

        h = min_label_dist_experimental
        h_change = min_label_dist_change_experimental
        su_target_it = su_target
    else
        h = number_wrong_labels
        h_change = number_wrong_labels_change
        su_target_it = su_target_set
    end

    # The set of discovered nodes that may need to be (re-)expanded.
    # Initially, only the root node is known.
    openSet = PriorityQueue{WSCollection, Int}(WSCollection(root) => h(root, target))

    # For node n, gScore_parent[n][1] is the cost of the cheapest path from start to n currently known.
    # gScore_parent[n][2] is the direction in which the parent of n on the currently cheapest path lies.
    gScore_parent = Dict{Vector{T}, Tuple{Int, Int}}()
    gScore_parent[su_root] = (0, 0)

    su = Vector{Int}(undef, N)

    while !isempty(openSet)
        current, f_current = dequeue_pair!(openSet)

        sorted_unfrozen!(current, su) # su_current
        @inbounds h_current = f_current - gScore_parent[su][1]
        
        # reconstruct and return mutation sequence
        if su == su_target
            sequence = Vector{Int}()

            while su != su_root
                @inbounds m = gScore_parent[su][2]
                mutate!(current, m)
                sorted_unfrozen!(current, su)
                push!(sequence, m)
            end

            return reverse!(sequence)
        end

        # get valid mutation directions
        num_mutables = get_mutables!(current, mutables)
        limitSearchSpace && (num_mutables = limit_searchspace!(mutables, num_mutables, current, su_target_set))
        @inbounds camefrom = gScore_parent[su][2]

        # tentative_gScore is the distance from start to next through current
        @inbounds tentative_gScore = gScore_parent[su][1] + 1

        for i in 1:num_mutables
            @inbounds m = mutables[i]
            m == camefrom && continue

            @inbounds old_label = current[m]
            new_label = peek(current, m)
            @inbounds current.labels[m] = new_label
            sorted_unfrozen!(current, su) # su_next
            @inbounds current.labels[m] = old_label

            if @inbounds !haskey(gScore_parent, su) || tentative_gScore < gScore_parent[su][1]
                # This path to next is better than any previous one. Record it!
                gScore_parent[copy(su)] = (tentative_gScore, m)
                openSet[mutate(current, m)] = tentative_gScore + h_change(old_label, new_label, h_current, current, su_target_it)
            end
        end
    end

    return [-1]
end

@doc raw"""
    find_label(root::WSCollection{T}, label::T) where T <: Integer

Returns a sequence of mutations, transforming `root` into a wsc 
containing `label`.

This sequence is computed by a the astar algorithm. 

# Keyword arguments:
- `heuristic::String = "number_wrong_labels"`
- `limitSearchSpace::Bool = true`

The available `heuristic's` are `"number_wrong_labels"`, `"min_label_dist"`
and `"min_label_dist_experimental"`.
If `limitSearchSpace` is set to true then labels already contained
in `target` will never be mutated.
"""
function find_label(root::WSCollection{T}, label::T; heuristic::String = "number_wrong_labels", 
                        limitSearchSpace::Bool = true) where T <: Integer

    seq = Vector{Int}()
    label in root && return seq

    seq = Astar(root, extend_to_collection(label, root); heuristic = heuristic, limitSearchSpace = limitSearchSpace)
    temp = WSCollection(root)

    # only return the subsequence to the first wsc containing label.
    count = 0
    for i in seq
        mutate!(temp, i)
        count += 1
        if temp[i] == label
            break
        end
    end

    return seq[1:count]
end