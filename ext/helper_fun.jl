
function filler(align::Symbol = :h)
    label = GtkLabel("")
    set_gtk_property!(label, :opacity, 0.0)
    if align == :v
        set_gtk_property!(label, :vexpand, true)
    else
        set_gtk_property!(label, :hexpand, true)
    end

    return label
end

function is_active(widget)
    get_gtk_property(widget, :active, Bool)
end

function icon(icon_name::String)
    im = GtkImage()
    set_gtk_property!(im, :icon_name, icon_name)
    return im
end

function DropDown(choices::String...)
    cb = GtkComboBoxText()
    for choice in choices
        push!(cb, choice)
    end
    set_gtk_property!(cb, :wrap_width, 1)
    return cb
end

function hbox(widgets...; halign = 0)
    box = GtkBox(:h)
    set_gtk_property!(box, :halign, halign)
    isempty(widgets) || push!(box, widgets...)
    return box
end

function vbox(widgets...; valign = 0)
    box = GtkBox(:v)
    set_gtk_property!(box, :valign, valign)
    isempty(widgets) || push!(box, widgets...)
    return box
end

function set_expand!(widget, expandable::Bool)
    set_gtk_property!(widget, :hexpand, expandable)
    set_gtk_property!(widget, :vexpand, expandable)
end

function set_size_request!(widget, width, height)
    set_gtk_property!(widget, :width_request, width)
    set_gtk_property!(widget, :height_request, height)
end

function set_margin!(widget, margin)
    set_gtk_property!(widget, :margin_start, margin)
    set_gtk_property!(widget, :margin_end, margin)
    set_gtk_property!(widget, :margin_top, margin)
    set_gtk_property!(widget, :margin_bottom, margin)
end

function set_margin_top!(widget, margin)
    set_gtk_property!(widget, :margin_top, margin)
end

function set_margin_bottom!(widget, margin)
    set_gtk_property!(widget, :margin_bottom, margin)
end

function set_margin_start!(widget, margin)
    set_gtk_property!(widget, :margin_start, margin)
end

function set_margin_end!(widget, margin)
    set_gtk_property!(widget, :margin_end, margin)
end

function set_upper!(scale, val)
    adj = get_gtk_property(scale, :adjustment, GtkAdjustment)
    set_gtk_property!(adj, :upper, Float64(val))
end

function sep(align::Symbol = :h, margin = 0)
    frame = GtkFrame()
    if align == :h
        set_size_request!(frame, -1, 1)
        set_gtk_property!(frame, :hexpand, true)
        set_margin_top!(frame, margin)
        set_margin_bottom!(frame, margin)
    elseif align == :v
        set_size_request!(frame, 1, -1)
        set_gtk_property!(frame, :vexpand, true)
        set_margin_start!(frame, margin)
        set_margin_end!(frame, margin)
    end
    return frame
end

# function vSep(opacity::AbstractFloat = 0.0, expand = true)
#     sep = GtkSeparator(:v)
#     set_gtk_property!(sep, :opacity, opacity)
#     set_gtk_property!(sep, :hexpand, expand)
#     return sep
# end

function label_emb(label, R_poly, n::Int, s)
    res = LPoint(0, 0)

    for j in 0:n-1
        @inbounds (label >>> j) & 1 == 1 && (res += R_poly[j+1])
    end
    return s*res
end

function label_emb(i, R_poly, C::WSCollection, s) 
    @inbounds label_emb(C[i], R_poly, C.n, s) 
end