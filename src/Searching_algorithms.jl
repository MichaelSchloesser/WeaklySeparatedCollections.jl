


function BFS(root::WSCollection, target::WSCollection; limitSearchSpace::Bool = true)
    queue = Queue{WSCollection}()
    explored = Vector{WSCollection}()
    parent = Dict{WSCollection, Tuple{WSCollection, Int}}()

    push!(explored, WSCollection(root, computeCliques = false))
    enqueue!(queue, WSCollection(root, computeCliques = false))

    while !isempty(queue)
        current = dequeue!(queue)

        if current == target
            sequence = []

            while current != root
                current, m = parent[current]
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
                parent[next] = (current, m)
                enqueue!(queue, next)
            end
        end
    end

end


# TODO DFS(root::WSCollection, target::WSCollection; limitSearchSpace::Bool = true)


function find_label(root::WSCollection, label::Vector{Int}; limitSearchSpace::Bool = true)
    target = extend_to_collection([label], root)
    return BFS(root, target, limitSearchSpace = limitSearchSpace)
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