
function copy_without_cliques(C::WSCollection{T}) where T <: Integer
    labels = copy_labels(C)
    Q = SimpleDiGraph(C.quiver)
    return WSCollection(C.k, C.n, labels, Q, C.whiteCliques, C.blackCliques)
end

function limit_searchspace!(mutables::Vector{T}, C1::WSCollection{T}, C2::WSCollection{T}) where T <: Integer
    x = 1

    for m in mutables
        @inbounds C1[m] in C2 || (mutables[x] = m; x += 1)
    end

    return resize!(mutables, x-1)
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
function BFS(root::WSCollection, target::WSCollection; limitSearchSpace::Bool = false)
    queue = Queue{WSCollection}()
    explored = Vector{WSCollection}()
    parent = Dict{WSCollection, Int}()

    push!(explored, root)
    enqueue!(queue, WSCollection(root, computeCliques = false))

    first = true
    while !isempty(queue)
    
        current = dequeue!(queue)

        if current == target
            sequence = Vector{Int}()

            while current != root
                m = parent[current]
                mutate!(current, m)
                push!(sequence, m)
            end

            return reverse!(sequence)
        end

        mutables = get_mutables(current)
        limitSearchSpace && limit_searchspace!(mutables, current, target)

        for m in mutables

            !first && m == parent[current] && continue
            next = mutate!(copy_without_cliques(current), m)

            if !(next in explored)
                push!(explored, next)
                parent[next] = m
                enqueue!(queue, next)
            end
        end
        first = false
    end
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
function DFS(root::WSCollection, target::WSCollection; limitSearchSpace::Bool = false)
    stack = Stack{WSCollection}()
    explored = Vector{WSCollection}()
    parent = Dict{WSCollection, Int}()

    push!(stack, WSCollection(root, computeCliques = false))
    first = true
    while !isempty(stack)
        current = pop!(stack)

        if current == target
            sequence = Vector{Int}()

            while current != root
                m = parent[current]
                current = mutate!(current, m)
                push!(sequence, m)
            end

            return reverse!(sequence)
        end

        if !(current in explored)
            push!(explored, current)
            
            mutables = get_mutables(current)
            limitSearchSpace && limit_searchspace!(mutables, current, target)

            for m in mutables
                !first && m == parent[current] && continue
                next = mutate!(copy_without_cliques(current), m)
                if !(next in explored)
                    push!(stack, next)
                    parent[next] = m
                end
            end
            first = false
        end
    end
end

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
    return generalized_associahedron( rectangle_collection(k, n, T))
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
    return @views setdiff_length(C.labels[n+1:end], target.labels[n+1:end])
end


function number_wrong_labels_change(old_label, new_label, h_value, current::WSCollection, target::WSCollection)
    return h_value + (old_label in target) - (new_label in target)
end

@doc raw"""
    min_label_dist(C::WSCollection, target::WSCollection)

Return the sum of minimum label distances, where for each label in `C` 
this distance is calculated as the minimal number of integer pairs one needs 
to exchange in order to obtain a label of `target`.
"""
function min_label_dist(C::WSCollection, target::WSCollection)
    n = C.n
    wrong_labels = @views setdiff(C.labels[n+1:end], target.labels[n+1:end])

    isempty(wrong_labels) && return 0
    estimate = (w, x) -> cld(setdiff_length(w, x), 2)

    return @views sum( w -> minimum( x -> estimate(w, x), target.labels[n+1:end]), wrong_labels)
end


function min_label_dist_change(old_label, new_label, h_value, current::WSCollection, target::WSCollection)
    n = target.n
    estimate = (w, x) -> cld(setdiff_length(w, x), 2)

    return @views h_value + minimum( x -> estimate(new_label, x), target.labels[n+1:end]) - minimum( x -> estimate(old_label, x), target.labels[n+1:end]) 
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
    wrong_labels = @views setdiff(C.labels[n+1:end], target.labels[n+1:end])
    missing_labels = @views setdiff(target.labels[n+1:end], C.labels[n+1:end])

    isempty(wrong_labels) && return 0
    estimate = (w, x) -> cld(setdiff_length(w, x), 2)

    return sum( w -> minimum( x -> estimate(w, x), missing_labels), wrong_labels)
end

function estimate_exp(w, x, current::WSCollection{T}) where T <:Integer
    @views x in current.labels[current.n+1:end] && return typemax(T)
    return cld(setdiff_length(w, x), 2)
end

# assumption: dont need to mutate correct labels -> consider missing labels only
function min_label_dist_change_experimental(old_label, new_label, h_value, current::WSCollection, target::WSCollection)

    non_frozen = @view target.labels[target.n+1:end]
    return h_value + minimum( x -> estimate_exp(new_label, x, current), non_frozen) - minimum( x -> estimate_exp(old_label, x, current), non_frozen) 
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
function Astar(root::WSCollection, target::WSCollection; heuristic::String = "number_wrong_labels", limitSearchSpace::Bool = true)
    
    if heuristic == "number_wrong_labels"
        h = number_wrong_labels
        h_change = number_wrong_labels_change
        
    elseif heuristic == "min_label_dist"
        h = min_label_dist
        h_change = min_label_dist_change

    elseif heuristic == "min_label_dist_experimental"

        h = min_label_dist_experimental
        h_change = min_label_dist_change_experimental
    else
        h = number_wrong_labels
        h_change = number_wrong_labels_change
    end
    
    # The set of discovered nodes that may need to be (re-)expanded.
    # Initially, only the root node is known.
    openSet = PriorityQueue{WSCollection, Int}(WSCollection(root, computeCliques = false) => h(root, target))
    cameFrom = Dict{WSCollection, Int}()

    # For node n, gScore[n] is the cost of the cheapest path from start to n currently known.
    gScore = Dict{WSCollection, Int}()
    gScore[WSCollection(root, computeCliques = false)] = 0

    first = true
    while !isempty(openSet)
        current, f_current = dequeue_pair!(openSet)
        h_current = f_current - gScore[current]
        
        # reconstruct and return mutation sequence
        if current == target
            sequence = Vector{Int}()

            while current != root
                m = cameFrom[current]
                mutate!(current, m)
                push!(sequence, m)
            end

            return reverse!(sequence)
        end

        # get valid mutation directions
        mutables = get_mutables(current) 
        limitSearchSpace && limit_searchspace!(mutables, current, target)
            
        for i in mutables

            !first && cameFrom[current] == i && continue
            neighbor = mutate!(copy_without_cliques(current), i)

            # tentative_gScore is the distance from start to the neighbor through current
            tentative_gScore = gScore[current] + 1

            if !haskey(gScore, neighbor) || tentative_gScore < gScore[neighbor]
                # This path to neighbor is better than any previous one. Record it!
                cameFrom[neighbor] = i
                gScore[neighbor] = tentative_gScore
                
                openSet[neighbor] = tentative_gScore + h_change(current[i], neighbor[i], h_current, current, target)
            end
        end
        first = false
    end

    return [-1]
end

@doc raw"""
    Astar(root::WSCollection, target::WSCollection)

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
function find_label(root::WSCollection{T}, label::Vector{T}; heuristic::String = "number_wrong_labels", 
                        limitSearchSpace::Bool = true) where T <: Integer

    seq = Vector{Int}()
    label in root && return seq

    seq = Astar(root, extend_to_collection([label], root); heuristic = heuristic, limitSearchSpace = limitSearchSpace)
    temp = WSCollection(root, computeCliques = false)

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