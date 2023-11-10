
LPoint = Luxor.Point
const scale_factor = 2.4

norm = P -> sqrt(P.x^2 + P.y^2)

function drawTiling(collection::WSCollection, title::String, width = 500, height = 500; 
    backgroundColor = nothing, drawLabels = true, adjustAngle = false, highlightMutables = true, scale = nothing)

    if ismissing(collection.whiteCliques) || ismissing(collection.blackCliques)
        error("cliques needed for drawing are missing!")
    end

    n = collection.n
    k = collection.k
    labels = collection.labels
    W = collection.whiteCliques
    B = collection.blackCliques
    
    s = 1
    v = [LPoint( sin(i*2*pi/n), -cos(i*2*pi/n) ) for i = 0:n-1 ]
    tau = i -> s*sum( v[labels[i]] )

    if isnothing(scale) # autoselect scale such that plabic tiling fits into window
        r = norm(sum(v[1:k]))
        s = min(width, height)/(scale_factor*r) 
    else
        s = scale
    end

    angle = 0
    if adjustAngle
        angle = acos( -sum(v[1:k]).y/norm(sum(v[1:k])) ) - (k-1)*2*pi/n
        v = [LPoint( sin(i*2*pi/n - angle), -cos(i*2*pi/n - angle) ) for i = 0:n-1 ]
    end

    Drawing(width, height, title)
        origin()

        # also nice: "lightblue4"
        if !isnothing(backgroundColor)
            background(backgroundColor)
        end
        
        # draw faces
        sethue("white")
        for w in values(W)
            poly(tau.(w), :fill)
        end
        sethue("black")
        for b in values(B)
            poly(tau.(b), :fill)
        end

        for i = 1:n
            line(tau(i), tau(pmod(i+1, n)), :stroke)
        end
        
        # draw vertices + labels
        if drawLabels
            fontsize( div(s,6))
            for i = 1:length(labels)
                pos = tau(i)

                label = ""
                for j in labels[i]
                    label *= "$j"
                end
                len = length(label)

                if isMutable(collection, i) && highlightMutables
                    sethue("orange")
                else
                    sethue("white")
                end

                ellipse(pos, s/8*(len+1), s/4, :fill)
                sethue("black")
                ellipse(pos, s/8*(len+1), s/4, :stroke)
                text(label, pos, halign=:center, valign=:middle)
            end
        else
            for i = 1:length(labels)
                pos = tau(i)

                if isMutable(collection, i) && highlightMutables
                    sethue("orange")
                    circle(pos, s/8, :fill)
                    sethue("black")
                    circle(pos, s/8, :stroke)
                else
                    sethue("white")
                    circle(pos, s/16, :fill)
                    sethue("black")
                    circle(pos, s/16, :stroke)
                end

                
            end
        end

    finish()

end


function drawPLG_poly(collection::WSCollection, title::String, width = 500, height = 500; backgroundColor = nothing, drawLabels = false, adjustAngle = false, scale = nothing) 

    if ismissing(collection.whiteCliques) || ismissing(collection.blackCliques)
        error("cliques needed for drawing are missing!")
    end

    n = collection.n
    k = collection.k
    labels = collection.labels
    W = collection.whiteCliques
    B = collection.blackCliques
    
    s = 1
    v = [LPoint( sin(i*2*pi/n), -cos(i*2*pi/n) ) for i = 0:n-1 ]
    tau = i -> s*sum( v[labels[i]] )

    if isnothing(scale) # autoselect scale 
        r = norm(sum(v[1:k]))
        s = min(width, height)/(scale_factor*r) 
    else
        s = scale
    end

    angle = 0
    if adjustAngle
        angle = acos( -sum(v[1:k]).y/norm(sum(v[1:k])) ) - (k-1)*2*pi/n
        v = [LPoint( sin(i*2*pi/n - angle), -cos(i*2*pi/n - angle) ) for i = 0:n-1 ]
    end

    Drawing(width, height, title)
        origin()
        
        # also nice: "lightblue4"
        if !isnothing(backgroundColor)
            background(backgroundColor)
        end
        
        fontsize( div(r*s, 10))
        for i = 1:n # outer edges and boundary vertices
            p1, p2 = tau(i), tau(pmod(i+1, n))
            r2 = norm(p1 + p2)
            line((p1 + p2)/2, r*s*(p1 + p2)/r2, :stroke)
            
            text( "$(pmod(i+k,n))", 1.1*(r*s*(p1 + p2)/r2), halign=:center, valign=:middle)
        end

        circle(LPoint(0,0), s*r, :stroke)

        # draw inner edges and vertices
        sethue("black")
        for w in values(W)
            w = tau.(w)
            len_w = length(w)
            c = sum(w)/len_w # LPoint in face. 
            
            for i = 1:len_w # draw lines from c to edge midPoints
                line(c, (w[i] + w[pmod(i+1, len_w)])/2,  :stroke)
            end

            sethue("white") # draw white vertex
            circle(c, s/8, :fill)
            sethue("black")
            circle(c, s/8, :stroke)
        end

        for b in values(B)
            b = tau.(b)
            len_b = length(b)
            c = sum(b)/len_b # LPoint in face. 

            for i = 1:len_b # draw lines from c to edge midPoints
                line(c, (b[i] + b[pmod(i+1, len_b)])/2,  :stroke)
            end

            circle(c, s/8, :fill) # draw black vertex
        end

        # draw face labels.
        if drawLabels
            fontsize( div(s,6))
            for i = 1:n
                label = ""
                for j in labels[i]
                    label *= "$j"
                end

                N_all = collect(all_neighbors(collection.quiver, i))
                dual_vertices = Set()

                for j in N_all
                    K = intersect(labels[i], labels[j])
                    L = sort(union(labels[i], labels[j]))
                    p_w = sum(tau.(W[K]))/length(W[K])
                    p_b = sum(tau.(B[L]))/length(B[L])
                    push!(dual_vertices, p_w)
                    push!(dual_vertices, p_b)
                end

                len = length(dual_vertices)
                push!(dual_vertices, len*tau(i))

                c = sum(dual_vertices)/(2*len)
                text(label, c, halign=:center, valign=:middle)
            end

            for i = n+1:length(labels)
                label = ""
                for j in labels[i]
                    label *= "$j"
                end

                N_out = collect(outneighbors(collection.quiver, i))
                
                dual_vertices = []
                for j in N_out
                    K = intersect(labels[i], labels[j])
                    L = sort(union(labels[i], labels[j]))
                    p_w = sum(tau.(W[K]))/length(W[K])
                    p_b = sum(tau.(B[L]))/length(B[L])
                    push!(dual_vertices, p_w)
                    push!(dual_vertices, p_b)
                end

                c = sum(dual_vertices)/length(dual_vertices)

                text(label, c, halign=:center, valign=:middle)
            end
        end
    finish()
end


function drawPLG_straight(collection::WSCollection, title::String, width = 500, height = 500; 
    backgroundColor = nothing, drawLabels = false, adjustAngle = false, highlightMutables = false, scale = nothing) 

    if ismissing(collection.whiteCliques) || ismissing(collection.blackCliques)
        error("cliques needed for drawing are missing!")
    end

    n = collection.n
    k = collection.k
    labels = collection.labels
    W = collection.whiteCliques
    B = collection.blackCliques

    s = 1
    v = [LPoint( sin(i*2*pi/n), -cos(i*2*pi/n) ) for i = 0:n-1 ]
    tau = i -> s*sum( v[labels[i]] )

    if isnothing(scale) # autoselect scale 
        r = norm(sum(v[1:k]))
        s = min(width, height)/(scale_factor*r) 
    else
        s = scale
    end

    angle = 0
    if adjustAngle
        angle = acos( -sum(v[1:k]).y/norm(sum(v[1:k])) ) - (k-1)*2*pi/n
        v = [LPoint( sin(i*2*pi/n - angle), -cos(i*2*pi/n - angle) ) for i = 0:n-1 ]
    end
    
    Drawing(width, height, title)
        origin()
        
        # also nice: "lightblue4"
        if !isnothing(backgroundColor)
            background(backgroundColor)
        end

        fontsize( div(r*s,10))
        for i = 1:n # outer edges and boundary vertices
            l1, l2 = labels[i], labels[pmod(i+1, n)]
            p1, p2 = tau(i), tau(pmod(i+1, n))
            r2 = norm(p1 + p2)

            adj = intersect(l1, l2) # TODO unessesary complicated. fix it
            if haskey(W, adj)
                w = W[adj]
                len_w = length(w)
                p3 = sum(tau.(w))/len_w
                line(r*s*(p1 + p2)/r2, p3, :stroke)
            else
                adj = sort(union(l1, l2))
                b = B[adj]
                len_b = length(b)
                p3 = sum(tau.(b))/len_b
                line(r*s*(p1 + p2)/r2, p3, :stroke)
            end
            
            text( "$(pmod(i+k,n))", 1.1*(r*s*(p1 + p2)/r2), halign=:center, valign=:middle )
        end

        circle(LPoint(0,0), s*r, :stroke)

        # highlight mutable faces
        if highlightMutables 
            for i = n+1:length(labels)
                if isMutable(collection, i)
                    
                    N_out = collect(outneighbors(collection.quiver, i))

                    function arith_mean(x)
                        len_x = length(x)
                        return sum(tau.(x))/len_x
                    end

                    p1 = arith_mean(W[ intersect(labels[i], labels[N_out[1]]) ])
                    p2 = arith_mean(B[ sort(union(labels[i], labels[N_out[1]])) ])
                    p3 = arith_mean(W[ intersect(labels[i], labels[N_out[2]]) ])
                    p4 = arith_mean(B[ sort(union(labels[i], labels[N_out[2]])) ])
                    
                    sethue("orange")
                    setopacity(0.5)
                    poly([p1, p2, p3, p4], :fill, close = true)
                end
            end
        end
        setopacity(1)

        # draw inner edges and vertices
        sethue("black")
        for w in values(W)
            len_w = length(w)
            p1 = sum(tau.(w))/len_w # LPoint in face. 
            
            for i = 1:len_w 
                opp = sort(union(labels[w[i]], labels[w[pmod(i+1,len_w)]]))
                if haskey(B, opp)
                    b = B[opp]
                    len_b = length(b)
                    p2 = sum(tau.(b))/len_b
                    line(p1, p2,  :stroke)
                end
            end

            sethue("white") # draw white vertex
            circle(p1, s/8, :fill)
            sethue("black")
            circle(p1, s/8, :stroke)
        end

        for b in values(B)
            b = tau.(b)
            len_b = length(b)
            p1 = sum(b)/len_b # LPoint in face. 

            circle(p1, s/8, :fill) # draw black vertex
        end

        # draw face labels
        if drawLabels
            fontsize( div(s,6))
            for i = 1:n
                label = ""
                for j in labels[i]
                    label *= "$j"
                end

                N_all = collect(all_neighbors(collection.quiver, i))
                dual_vertices = Set()

                for j in N_all
                    K = intersect(labels[i], labels[j])
                    L = sort(union(labels[i], labels[j]))
                    p_w = sum(tau.(W[K]))/length(W[K])
                    p_b = sum(tau.(B[L]))/length(B[L])
                    push!(dual_vertices, p_w)
                    push!(dual_vertices, p_b)
                end

                len = length(dual_vertices)
                push!(dual_vertices, len*tau(i))

                c = sum(dual_vertices)/(2*len)
                text(label, c, halign=:center, valign=:middle)
            end

            for i = n+1:length(labels)
                label = ""
                for j in labels[i]
                    label *= "$j"
                end

                N_out = collect(outneighbors(collection.quiver, i))
                
                dual_vertices = []
                for j in N_out
                    K = intersect(labels[i], labels[j])
                    L = sort(union(labels[i], labels[j]))
                    p_w = sum(tau.(W[K]))/length(W[K])
                    p_b = sum(tau.(B[L]))/length(B[L])
                    push!(dual_vertices, p_w)
                    push!(dual_vertices, p_b)
                end

                c = sum(dual_vertices)/length(dual_vertices)

                text(label, c, halign=:center, valign=:middle)
            end
        end

    finish()
end


function drawPLG_smooth(collection::WSCollection, title::String, width = 500, height = 500; backgroundColor = nothing, drawLabels = false, adjustAngle = false, scale = nothing) 

    if ismissing(collection.whiteCliques) || ismissing(collection.blackCliques)
        error("cliques needed for drawing are missing!")
    end

    n = collection.n
    k = collection.k
    labels = collection.labels
    W = collection.whiteCliques
    B = collection.blackCliques

    s = 1
    v = [LPoint( sin(i*2*pi/n), -cos(i*2*pi/n) ) for i = 0:n-1 ]
    tau = i -> s*sum( v[labels[i]] )

    if isnothing(scale) # autoselect scale 
        r = norm(sum(v[1:k]))
        s = min(width, height)/(scale_factor*r) 
    else
        s = scale
    end

    angle = 0
    if adjustAngle
        angle = acos( -sum(v[1:k]).y/norm(sum(v[1:k])) ) - (k-1)*2*pi/n
        v = [LPoint( sin(i*2*pi/n - angle), -cos(i*2*pi/n - angle) ) for i = 0:n-1 ]
    end
    
    Drawing(width, height, title)
        origin()
        
        # also nice: "lightblue4"
        if !isnothing(backgroundColor)
            background(backgroundColor)
        end

        fontsize( div(r*s,10))
        for i = 1:n # outer edges and boundary vertices
            l1, l2 = labels[i], labels[pmod(i+1, n)]
            p1, p2 = tau(i), tau(pmod(i+1, n))
            p3 = midpoint(p1, p2)
            r2 = norm(p1 + p2)

            adj = intersect(l1, l2) # TODO unessesary complicated. fix it
            if haskey(W, adj)
                w = W[adj]
                len_w = length(w)
                p4 = sum(tau.(w))/len_w

                move(r*s*(p1 + p2)/r2)
                curve(r*s*(p1 + p2)/r2, p3, p4) # TODO not quite the correct bezier curve. works for now
                strokepath()
            else
                adj = sort(union(l1, l2)) # TODO unessesary complicated. fix it
                b = B[adj]
                len_b = length(b)
                p4 = sum(tau.(b))/len_b

                move(r*s*(p1 + p2)/r2)
                curve(r*s*(p1 + p2)/r2, p3, p4) # TODO not quite the correct bezier curve. works for now
                strokepath()
            end
            
            text( "$(pmod(i+k,n))", 1.1*(r*s*(p1 + p2)/r2), halign=:center, valign=:middle)
        end

        circle(LPoint(0,0), s*r, :stroke)

        # draw inner edges and vertices
        sethue("black")
        for w in values(W)
            len_w = length(w)
            p1 = sum(tau.(w))/len_w # LPoint in face. 
            
            for i = 1:len_w 
                opp = sort(union(labels[w[i]], labels[w[pmod(i+1,len_w)]]))
                if haskey(B, opp)
                    p2 = midpoint(tau(w[i]), tau(w[pmod(i+1,len_w)]) )
                    b = B[opp]
                    len_b = length(b)
                    p3 = sum(tau.(b))/len_b

                    move(p1)
                    curve(p1, p2, p3) # TODO not quite the correct bezier curve. works for now
                    strokepath()
                end
            end

            sethue("white") # draw white vertex
            circle(p1, s/8, :fill)
            sethue("black")
            circle(p1, s/8, :stroke)
        end

        for b in values(B)
            b = tau.(b)
            len_b = length(b)
            p1 = sum(b)/len_b # LPoint in face. 

            circle(p1, s/8, :fill) # draw black vertex
        end

        # draw face labels. 
        if drawLabels
            fontsize( div(s,6))
            for i = 1:n
                label = ""
                for j in labels[i]
                    label *= "$j"
                end

                N_all = collect(all_neighbors(collection.quiver, i))
                dual_vertices = Set()

                for j in N_all
                    K = intersect(labels[i], labels[j])
                    L = sort(union(labels[i], labels[j]))
                    p_w = sum(tau.(W[K]))/length(W[K])
                    p_b = sum(tau.(B[L]))/length(B[L])
                    push!(dual_vertices, p_w)
                    push!(dual_vertices, p_b)
                end

                len = length(dual_vertices)
                push!(dual_vertices, len*tau(i))

                c = sum(dual_vertices)/(2*len)
                text(label, c, halign=:center, valign=:middle)
            end

            for i = n+1:length(labels)
                label = ""
                for j in labels[i]
                    label *= "$j"
                end

                N_out = collect(outneighbors(collection.quiver, i))
                
                dual_vertices = []
                for j in N_out
                    K = intersect(labels[i], labels[j])
                    L = sort(union(labels[i], labels[j]))
                    p_w = sum(tau.(W[K]))/length(W[K])
                    p_b = sum(tau.(B[L]))/length(B[L])
                    push!(dual_vertices, p_w)
                    push!(dual_vertices, p_b)
                end

                c = sum(dual_vertices)/length(dual_vertices)

                text(label, c, halign=:center, valign=:middle)
            end
        end
        
    finish()
end