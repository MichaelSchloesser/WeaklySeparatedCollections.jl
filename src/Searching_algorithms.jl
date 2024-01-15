
################## uninformed searching ##################

function BFS(root::WSCollection, target::WSCollection; limitSearchSpace::Bool = true)
    queue = Queue{WSCollection}()
    explored = Vector{WSCollection}()
    parent = Dict{WSCollection, Int}()

    push!(explored, WSCollection(root, computeCliques = false))
    enqueue!(queue, WSCollection(root, computeCliques = false))

    while !isempty(queue)
        current = dequeue!(queue)

        if current == target
            sequence::Vector{Int} = []

            while current != root
                m = parent[current]
                current = mutate!(current, m)
                push!(sequence, m)
            end

            return reverse!(sequence)
        end

        mutables = get_mutables(current)
        if limitSearchSpace
            filter!(x -> !(current[x] in target), mutables)
        end

        for m in mutables
            next = mutate(current, m)
            if !(next in explored)
                push!(explored, next)
                parent[next] = m
                enqueue!(queue, next)
            end
        end
    end

end


function DFS(root::WSCollection, target::WSCollection; limitSearchSpace::Bool = true)
    stack = Stack{WSCollection}()
    explored = Vector{WSCollection}()
    parent = Dict{WSCollection, Int}()

    push!(stack, WSCollection(root, computeCliques = false))
    while !isempty(stack)
        current = pop!(stack)

        if current == target
            sequence::Vector{Int} = []

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
            if limitSearchSpace
                filter!(x -> !(current[x] in target), mutables)
            end

            for m in mutables
                next = mutate(current, m)
                if !(next in explored)
                    push!(stack, next)
                    parent[next] = m
                end
            end
        end
    end
    
end


function generalized_associahedron(root::WSCollection)
    queue = Queue{WSCollection}()
    wsc_list = Vector{WSCollection}()
    associahedron = SimpleGraph(1)

    push!(wsc_list, WSCollection(root, computeCliques = false))
    enqueue!(queue, WSCollection(root, computeCliques = false))
    current_index = 1

    while !isempty(queue)
        current = dequeue!(queue)

        mutables = get_mutables(current)

        for m in mutables
            next = mutate(current, m)

            next_index = findfirst(x -> x == next, wsc_list)

            if isnothing(next_index)
                push!(wsc_list, next)
                enqueue!(queue, next)

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


function generalized_associahedron(k::Int, n::Int)
    return generalized_associahedron( rectangle_collection(k, n))
end

################## heuristics ##################

function diff_len(w, x)
    d = 0
    for a in w
        d = d + !(a in x)
    end

    return d
end

# easy estimation of minimum number of mutations needed to reach the target
function number_wrong_labels(collection::WSCollection, target::WSCollection) 
    return length(setdiff(collection, target))
end


function number_wrong_labels_change(old_label, new_label, h_value, target)
    return h_value + (old_label in target) - (new_label in target)
end

# more complicated but better estimation of distance to the target. takes longer
function min_label_dist(collection::WSCollection, target::WSCollection)
    n = target.n
    wrong_labels = setdiff(collection, target)

    if isempty(wrong_labels)
        return 0
    end

    estimate = (w, x) -> Int(ceil(diff_len(w, x)/2))

    return sum( w -> minimum( x -> estimate(w, x), target.labels[n+1:end]), wrong_labels)
end


function min_label_dist_change(old_label, new_label, h_value, target)
    n = target.n
    estimate = (w, x) -> Int(ceil(diff_len(w, x)/2))

    return h_value + minimum( x -> estimate(new_label, x), target.labels[n+1:end]) - minimum( x -> estimate(old_label, x), target.labels[n+1:end]) 
end

# assumption: dont need to mutate correct labels -> consider missing labels only
function min_label_dist_experimental(collection::WSCollection, target::WSCollection)
    wrong_labels = setdiff(collection, target)
    missing_labels = setdiff(target, collection)

    if isempty(wrong_labels)
        return 0
    end

    estimate = (w, x) -> Int(ceil(diff_len(w, x)/2))

    return sum( w -> minimum( x -> estimate(w, x), missing_labels), wrong_labels)
end

# assumption: dont need to mutate correct labels -> consider missing labels only
function min_label_dist_change_experimental(old_label, new_label, h_value, missing_labels)
    estimate = (w, x) -> Int(ceil(diff_len(w, x)/2))

    return h_value + minimum( x -> estimate(x, new_label), missing_labels) - minimum( x -> estimate(x, old_label), missing_labels) 
end

@enum HEURISTIC begin
    NUMBER_WRONG_LABELS
    MIN_LABEL_DIST
    MIN_LABEL_DIST_EXPERIMENTAL
    # MATCHING_DIST
    # MATCHING_DIST_EXPERIMENTAL
end

################## informed searching ##################

function Astar(root::WSCollection, target::WSCollection; heuristic::HEURISTIC = NUMBER_WRONG_LABELS, limitSearchSpace::Bool = true)

    experimental = false
    
    if heuristic == NUMBER_WRONG_LABELS
        h = number_wrong_labels
        h_change = number_wrong_labels_change
        
    elseif heuristic == MIN_LABEL_DIST
        h = min_label_dist
        h_change = min_label_dist_change

    elseif heuristic == MIN_LABEL_DIST_EXPERIMENTAL
        h = min_label_dist_experimental
        h_change = min_label_dist_change_experimental
        experimental = true

    # TODO
    # elseif HEURISTIC == MATCHING_DIST
    #     heuristic = matching_dist
    #     heuristic_change = matching_dist_change
    
    # elseif HEURISTIC == MATCHING_DIST_EXPERIMENTAL
    #     heuristic = matching_dist_experimental
    #     heuristic_change = matching_dist_change_experimental
    #     experimental = true
    end

    # The set of discovered nodes that may need to be (re-)expanded.
    # Initially, only the root node is known.
    openSet = PriorityQueue{WSCollection, Int}(WSCollection(root, computeCliques = false) => h(root, target))
    cameFrom = Dict{WSCollection, Int}()

    # For node n, gScore[n] is the cost of the cheapest path from start to n currently known.
    gScore = Dict{WSCollection, Int}()
    gScore[WSCollection(root, computeCliques = false)] = 0

    while !isempty(openSet)
        current, f_current = dequeue_pair!(openSet)
        h_current = f_current - gScore[current]
        
        # reconstruct and return mutation sequence
        if current == target
            sequence::Vector{Int} = []

            while current != root
                m = cameFrom[current]
                mutate!(current, m)
                push!(sequence, m)
            end

            return reverse!(sequence)
        end

        # get valid mutation directions
        mutables = get_mutables(current)
        if limitSearchSpace
            filter!(x -> !(current[x] in target), mutables)
        end

        if experimental
            missing_labels = setdiff(target, current)
        end

        for i in mutables
            neighbor = mutate(current, i)

            # tentative_gScore is the distance from start to the neighbor through current
            tentative_gScore = gScore[current] + 1

            if !haskey(gScore, neighbor) || tentative_gScore < gScore[neighbor]
                # This path to neighbor is better than any previous one. Record it!
                cameFrom[neighbor] = i
                gScore[neighbor] = tentative_gScore
                
                openSet[neighbor] = tentative_gScore + h_change(current[i], neighbor[i], h_current, experimental ? missing_labels : target)
            end
        end
    end
end


function find_label(root::WSCollection, label::Vector{Int}; heuristic::HEURISTIC = NUMBER_WRONG_LABELS, limitSearchSpace::Bool = true)

    seq::Vector{Int} = []
    if label in root
        return seq
    end

    seq = Astar(root, extend_to_collection([label], root); heuristic = heuristic, limitSearchSpace = limitSearchSpace)
    temp = WSCollection(root, computeCliques = false)

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