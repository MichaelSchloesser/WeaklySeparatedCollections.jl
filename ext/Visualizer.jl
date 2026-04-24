module Visualizer

using WeaklySeparatedCollections
import WeaklySeparatedCollections as WSC
import Luxor
import Luxor: Point as LPoint
import Luxor: distance as dist

using Gtk

import Graphs: outneighbors
using Scratch
using JLD2
using FileIO
using Suppressor
using Colors

include("helper_fun.jl")

bin_path = ""

function WSC.visualizer!(G::WSCollection = rec_collection(4, 9; keepCliques = true))

    # data for drawing 
    size::Int = 500
    resolution::Int = 500
    drawmode::Symbol = :straight
    draw_labels::Bool = true
    highlight_mutables::Bool = false
    top_label::Float64 = -1.0
    label_direction::Symbol = :left # TODO make this a Symbol

    # theme and colors
    theme = "dark" # TODO make this a Symbol and figure out themes

    # undo/redo
    undo_list = Vector()
    redo_list = Vector()

    function activate()
        load_settings()
    
        _, s, R_poly = WSC.embedding_data(G, resolution, resolution, top_label)
        tau = i -> label_emb(i, R_poly, G, s)

        ############################ GUI ############################

        ############## Main window ##############

        begin
            #### Menubar ####

            # File

            file = GtkMenuItem("File")
            file_menu = GtkMenu(file)
            
            item_load = GtkMenuItem("Load...")
            item_save_as = GtkMenuItem("Save as...")
            item_export = GtkMenuItem("Export...")
            item_quit = GtkMenuItem("Quit")

            push!(file_menu, item_load)
            push!(file_menu, item_save_as)
            push!(file_menu, item_export)
            push!(file_menu, item_quit)

            # Edit

            edit = GtkMenuItem("Edit")
            edit_menu = GtkMenu(edit)

            item_undo = GtkMenuItem("Undo")
            item_redo = GtkMenuItem("Redo")
            item_predefined = GtkMenuItem("Predefined...")
            item_rotate_clockwise = GtkMenuItem("Rotate clockwise")
            item_rotate_counterclockwise = GtkMenuItem("Rotate counterclockwise")
            item_mirror = GtkMenuItem("Mirror")
            item_complement = GtkMenuItem("Complement")
            item_swap_colors = GtkMenuItem("Swap colors")

            push!(edit_menu, item_undo)
            push!(edit_menu, item_redo)
            push!(edit_menu, item_predefined)
            push!(edit_menu, item_rotate_clockwise)
            push!(edit_menu, item_rotate_counterclockwise)
            push!(edit_menu, item_mirror)
            push!(edit_menu, item_complement)
            push!(edit_menu, item_swap_colors)

            # Menubar
            
            menubar = GtkMenuBar()
            push!(menubar, file)
            push!(menubar, edit) 

            #### Image ####

            image = GtkImage()
            # set_expand!(image, true)
            set_size_request!(image, size, size)
            update_image!(image) # update once initially
            image_box = GtkEventBox(image)

            #### Undo/Redo ####

            undo_button = GtkButton("Undo")
            set_margin!(undo_button, 5)

            redo_button = GtkButton("Redo")
            set_margin!(redo_button, 5)
            set_margin_start!(redo_button, 0)

            #### Settings ####
            
            settings_button = GtkButton(icon("emblem-system-symbolic"))
            set_margin!(settings_button, 5)

            inv_button = GtkButton(icon("emblem-system-symbolic"))
            set_gtk_property!(inv_button, :opacity, 0.0)
            set_gtk_property!(inv_button, :sensitive, false)
            set_margin!(inv_button, 5)

            #### Window ####

            main_window = GtkWindow("Visualizer")
            set_gtk_property!(main_window, :resizable, false)

            # TODO find gtk3 equivalent
            # header_bar = GtkHeaderBar()
            # Gtk4.G_.set_decoration_layout(header_bar, "menu:minimize,maximize,close")
            # Gtk4.G_.set_titlebar(main_window, header_bar)
            
            main_window_content = vbox(
                    menubar,
                    image_box,
                    hbox( settings_button, filler(), undo_button, redo_button, filler(), inv_button)
            )
            set_expand!(main_window_content, true)

            push!(main_window, main_window_content)
        end

        ############## Settings window ##############

        begin
            display_size_label = GtkLabel("Display size:")
            set_size_request!(display_size_label, 190, 0)

            display_resolution_label = GtkLabel("Resolution:")
            set_size_request!(display_resolution_label, 190, 0)

            drawmode_label = GtkLabel("Draw mode:")
            set_size_request!(drawmode_label, 190, 0)

            draw_labels_label = GtkLabel("Draw labels:")
            set_size_request!(draw_labels_label, 190, 0)

            label_direction_label = GtkLabel("Label direction:")
            set_size_request!(label_direction_label, 190, 0)

            highlight_mutables_label = GtkLabel("Highlight mutables:")
            set_size_request!(highlight_mutables_label, 190, 0)

            top_label_label = GtkLabel("Top label:")
            set_size_request!(top_label_label, 190, 0)

            theme_label = GtkLabel("Theme:")
            set_size_request!(theme_label, 190, 0)

            display_size_entry = GtkEntry()
            set_gtk_property!(display_size_entry, :width_chars, 5)
            set_gtk_property!(display_size_entry, :text, "$size")

            resolution_entry = GtkEntry()
            set_gtk_property!(resolution_entry, :width_chars, 5)
            set_gtk_property!(resolution_entry, :text, "$resolution")
            set_margin_top!(resolution_entry, 5)

            drawmode_dropdown = DropDown("Straight", "Smooth", "Tiling")
            
            set_size_request!(drawmode_dropdown, 110, 0)
            set_margin_top!(drawmode_dropdown, 5)
            if drawmode == :smooth
                set_gtk_property!(drawmode_dropdown, :active, 1)
            elseif drawmode == :tiling
                set_gtk_property!(drawmode_dropdown, :active, 2)
            else
                set_gtk_property!(drawmode_dropdown, :active, 0)
            end

            label_direction_dropdown = DropDown("Left", "Right")
            set_size_request!(label_direction_dropdown, 110, 0)
            set_margin_top!(label_direction_dropdown, 5)
            if label_direction == :right
                set_gtk_property!(label_direction_dropdown, :active, 1)
            else  
                set_gtk_property!(label_direction_dropdown, :active, 0)
            end

            draw_labels_check = GtkCheckButton()
            if draw_labels
                set_gtk_property!(draw_labels_check, :active, true)
            end
            set_margin_top!(draw_labels_check, 5)

            highlight_mutables_check = GtkCheckButton()
            if highlight_mutables
                set_gtk_property!(highlight_mutables_check, :active, true)
            end
            set_margin_top!(highlight_mutables_check, 5)

            top_label_check = GtkCheckButton() 
            if 0 <= top_label <= G.n
                set_gtk_property!(top_label_check, :active, true)
            end
            set_margin_top!(top_label_check, 5)
            set_margin_bottom!(top_label_check, 5)

            top_label_scale = GtkScale(:h, 0.0, Float64(G.n), 0.1)
            set_gtk_property!(top_label_scale, :draw_value, true)
            set_size_request!(top_label_scale, 320, 0)

            if 0 <= top_label <= G.n
                GAccessor.value(top_label_scale, top_label)
            end
            set_gtk_property!(top_label_scale, :sensitive, is_active(top_label_check))

            # TODO figure out themes
            # theme_dropdown = DropDown("Dark", "Light")
            # set_size_request!(theme_dropdown, 110, 0)
            # set_margin_top!(theme_dropdown, 10)
            # if theme == "dark"
            #     set_gtk_property!(theme_dropdown, :selected, 1)
            # else
            #     set_gtk_property!(theme_dropdown, :selected, 2)
            # end

            # TODO
            # color_chooser  
            # colors of background, white, black vertices

            settings_ok_button = GtkButton("Ok")
            set_margin_top!(settings_ok_button, 10)
            set_size_request!(settings_ok_button, 80, 0)
            set_margin_end!(settings_ok_button, 5)

            settings_cancel_button = GtkButton("Cancel")
            set_margin_top!(settings_cancel_button, 10)
            set_size_request!(settings_cancel_button, 80, 0)

            settings_buttons = hbox(settings_ok_button, settings_cancel_button)
            set_gtk_property!(settings_buttons, :halign, 2)

            settings_window_content = vbox(
                hbox(display_size_label, display_size_entry),
                hbox(display_resolution_label, resolution_entry),
                hbox(drawmode_label, drawmode_dropdown),
                hbox(label_direction_label, label_direction_dropdown),
                hbox(draw_labels_label, draw_labels_check),
                hbox(highlight_mutables_label, highlight_mutables_check),
                hbox(top_label_label, top_label_check),
                hbox(top_label_scale),
                sep(:h, 5),
                # hbox(theme_label, theme_dropdown),
                # TODO color stuff
                settings_buttons
            )
            set_margin!(settings_window_content, 10)

            settings_window = GtkWindow("Settings")
            set_gtk_property!(settings_window, :transient_for, main_window)
            set_gtk_property!(settings_window, :modal, true)
            push!(settings_window, settings_window_content)

            hide(settings_window)
        end

        ############## Export window ##############

        begin
            export_figure_label = GtkLabel("Figure:")
            set_size_request!(export_figure_label, 170, 0)
            export_figure_dropdown = DropDown("Straight", "Smooth", "Tiling")
            set_size_request!(export_figure_dropdown, 115, 0)
            if drawmode == :smooth
                set_gtk_property!(export_figure_dropdown, :active, 1)
            elseif drawmode == :tiling
                set_gtk_property!(export_figure_dropdown, :active, 2)
            else
                set_gtk_property!(export_figure_dropdown, :active, 0)
            end

            export_resolution_label = GtkLabel("Resolution:")
            set_size_request!(export_resolution_label, 170, 0)

            export_width_entry = GtkEntry()
            set_gtk_property!(export_width_entry, :width_chars, 5)
            set_gtk_property!(export_width_entry, :text, "$resolution")
            set_margin_top!(export_width_entry, 5)
            set_margin_end!(export_width_entry, 5)
            
            export_height_entry = GtkEntry()
            set_gtk_property!(export_height_entry, :width_chars, 5)
            set_gtk_property!(export_height_entry, :text, "$resolution")
            set_margin_top!(export_height_entry, 5)

            export_background_label = GtkLabel("Background:")
            set_size_request!(export_background_label, 170, 0)

            export_background_entry = GtkEntry()
            set_gtk_property!(export_background_entry, :width_chars, 20)
            set_gtk_property!(export_background_entry, :text, "lightgrey")
            set_margin_top!(export_background_entry, 5)

            export_top_label_label = GtkLabel("Adjust top label:")
            set_size_request!(export_top_label_label, 170, 0)

            export_top_label_check = GtkCheckButton()
            if 0 <= top_label <= G.n
                set_gtk_property!(export_top_label_check, :active, true)
            end
            set_margin_top!(export_top_label_check, 5)

            export_top_label_scale = GtkScale(:h, 0.0, Float64(G.n), 0.1)
            set_gtk_property!(export_top_label_scale, :draw_value, true)
            set_size_request!(export_top_label_scale, 320, 0)

            if 0 <= top_label <= G.n
                GAccessor.value(export_top_label_scale, top_label)
            end
            set_gtk_property!(export_top_label_scale, :sensitive, is_active(export_top_label_check))

            export_draw_labels_label = GtkLabel("Draw labels:")
            set_size_request!(export_draw_labels_label, 170, 0)

            export_draw_labels_check = GtkCheckButton()
            if draw_labels
                set_gtk_property!(export_draw_labels_check, :active, true)
            end
            set_margin_top!(export_draw_labels_check, 5)

            export_ok_button = GtkButton("Ok")
            set_size_request!(export_ok_button, 80, 0)
            set_margin_top!(export_ok_button, 10)
            set_margin_end!(export_ok_button, 5)

            export_cancel_button = GtkButton("Cancel")
            set_size_request!(export_cancel_button, 80, 0)
            set_margin_top!(export_cancel_button, 10)

            export_buttons = hbox(export_ok_button, export_cancel_button)
            set_gtk_property!(export_buttons, :halign, 2)

            export_window_content = vbox(
                hbox(export_figure_label, export_figure_dropdown),
                hbox(export_resolution_label, export_width_entry, export_height_entry),
                hbox(export_background_label, export_background_entry),
                hbox(export_draw_labels_label, export_draw_labels_check),
                hbox(export_top_label_label, export_top_label_check),
                hbox(export_top_label_scale),
                export_buttons
            )
            set_margin!(export_window_content, 10)

            export_window = GtkWindow("Export")
            set_gtk_property!(export_window, :transient_for, main_window)
            set_gtk_property!(export_window, :modal, true)
            push!(export_window, export_window_content)

            hide(export_window)
        end

        ############## Predefined window ##############

        begin
            predefined_dropdown = DropDown("Checkboard", "Rectangle", "Dual Checkboard", "Dual Rectangle")
            set_gtk_property!(predefined_dropdown, :active, 1)

            predefined_spin_n = GtkSpinButton(4, 64, 1)
            set_margin_top!(predefined_spin_n, 5)
            predefined_spin_k = GtkSpinButton(2, G.n-2, 1)
            set_margin_top!(predefined_spin_k, 5)
            set_gtk_property!(predefined_spin_n, :value, G.n)
            set_gtk_property!(predefined_spin_k, :value, G.k)

            predefined_label_n = GtkLabel("Select n :")
            predefined_label_k = GtkLabel("Select k :")
            set_size_request!(predefined_label_n, 70, 0)
            set_size_request!(predefined_label_k, 70, 0)

            predefined_ok_button = GtkButton("Ok")
            set_size_request!(predefined_ok_button, 80, 0)
            set_margin_top!(predefined_ok_button, 10)
            set_margin_end!(predefined_ok_button, 5)

            predefined_cancel_button = GtkButton("Cancel")
            set_margin_top!(predefined_cancel_button, 10)
            set_size_request!(predefined_cancel_button, 80, 0)

            predefined_buttons = hbox(predefined_ok_button, predefined_cancel_button; halign = 2)

            predefined_window_content = vbox(
                predefined_dropdown,
                hbox(predefined_label_n, predefined_spin_n), 
                hbox(predefined_label_k, predefined_spin_k),
                predefined_buttons
            )
            set_margin!(predefined_window_content, 10)

            predefined_window = GtkWindow("Predefined")
            set_gtk_property!(predefined_window, :transient_for, main_window)
            set_gtk_property!(predefined_window, :modal, true)
            push!(predefined_window, predefined_window_content)

            hide(predefined_window)
        end

        ############################ Event handeling ############################

        ############## main window ##############

        #### image ####

        signal_connect(image_box, :button_press_event) do widget, event
            
            if drawmode == :tiling
                on_click_pressed_tiling(event.x, event.y)
            else
                on_click_pressed_plg(event.x, event.y)
            end
                        
            true
        end

        # mutate by clicking on vertices 
        function on_click_pressed_tiling(x::AbstractFloat, y::AbstractFloat)

            # w, h = get_allocated_size(data).x, get_allocated_size(data).y
            w, h = resolution, resolution
            x, y = (x/w-0.5)*resolution, (y/h-0.5)*resolution

            is_close = p -> dist(tau(p), LPoint(x, y)) < 30.0
            close_mutables = filter!(is_close , get_mutables(G))
    
            if !isempty(close_mutables) # mutate
                # select direction of mutation
                i = argmin(p -> dist(tau(p), LPoint(x, y)), close_mutables)
                
                # mutate and update displays
                mutate!(G, i; updateCliques = true)
                update_image!(image)

                # update undo/redo
                push_undo!(undo_list, redo_list, "mutation", (i, ))
            end
            
            return nothing
        end

        # select and mutate by clicking on faces 
        function on_click_pressed_plg(x::AbstractFloat, y::AbstractFloat)

            # TODO
            function is_surounding_mutable(p::Int)
                N_out = outneighbors(G.quiver, p)
                arith_mean = clique -> sum(tau, clique)/length(clique) 

                p1 = arith_mean( G.whiteCliques[ G[p] & G[N_out[1]] ])
                p2 = arith_mean( G.blackCliques[ G[p] | G[N_out[1]] ])
                p3 = arith_mean( G.whiteCliques[ G[p] & G[N_out[2]] ])
                p4 = arith_mean( G.blackCliques[ G[p] | G[N_out[2]] ])

                return Luxor.isinside(LPoint(x, y), [p1, p2, p3, p4], allowonedge = false)
            end

            # w, h = get_allocated_size(data).x, get_allocated_size(data).y
            w, h = resolution, resolution
            x, y = (x/w-0.5)*resolution, (y/h-0.5)*resolution
            
            for i in get_mutables(G)
                if is_surounding_mutable(i)

                    # mutate and update displays
                    mutate!(G, i; updateCliques = true)
                    update_image!(image)
                    
                    # update undo/redo
                    push_undo!(undo_list, redo_list, "mutation", (i, ))
                    break
                end
            end

            return nothing
        end
        
        #### undo redo buttons ####

        # undo last action
        signal_connect(undo_button, :clicked) do widget
            undo!(undo_list, redo_list, image)
        end
        # add_shortcut!(undo, "<Control>z")
        
        # redo last undone action
        signal_connect(redo_button, :clicked) do widget
            redo!(undo_list, redo_list, image)
        end
        # add_shortcut!(redo, "<Control>y")

        #### window ####

        # destroy all hidden windows before closing main window
        signal_connect(main_window, :delete_event) do widget, others...
            destroy(settings_window)
            destroy(export_window)
            destroy(predefined_window)
            return false
        end

        ############## file submenu ##############

        # load a WSC
        function load_callback(widget)
            chosen_path = open_dialog("Pick a file", main_window, ("*.jld2",))
            chosen_path == "" && return nothing

            D = FileIO.load(chosen_path)
            
            W, B = WSC.compute_cliques(D["labels"])
            Q = WSC.compute_quiver(D["n"], D["labels"], W)
            H = WSCollection(D["k"], D["n"], D["labels"], Q, W, B)

            G == H && return nothing
            push_undo!(undo_list, redo_list, "load", (G, chosen_path))
            
            G = H
            _, s, R_poly = WSC.embedding_data(G, resolution, resolution, top_label)
            tau = i -> label_emb(i, R_poly, G, s)
            
            update_image!(image)
            return nothing
        end
        signal_connect(load_callback, item_load, :activate)

        # save a WSC
        function save_callback(widget)
            chosen_path = save_dialog("Save as...", main_window, ("*.jld2",))
            chosen_path == "" && return nothing
            chosen_path = splitext(chosen_path)[1]*".jld2"

            D = Dict("k" => G.k, "n" => G.n, "labels" => G.labels)
            FileIO.save(chosen_path, D) 
        end
        signal_connect(save_callback, item_save_as, :activate) 

        ############## edit submenu ##############

        # undo last action
        signal_connect(item_undo, :activate) do widget
            undo!(undo_list, redo_list, image)
        end
        # add_shortcut!(undo, "<Control>z")
        
        # redo last undone action
        signal_connect(item_redo, :activate) do widget
            redo!(undo_list, redo_list, image)
        end

        # rotating
        signal_connect(item_rotate_clockwise, :activate) do widget
            _rotate!(1, undo_list, redo_list, image)
        end
        # add_shortcut!(rotate_clockwise, "<shift>d")
        
        
        signal_connect(item_rotate_counterclockwise, :activate) do widget
            _rotate!(-1, undo_list, redo_list, image)
        end
        # add_shortcut!(rotate_counterclockwise, "<shift>a")
        
        signal_connect(item_mirror, :activate) do widget
            _mirror!(undo_list, redo_list, image)
        end
        # add_shortcut!(mirror, "<shift>s")
        
        # complements
        signal_connect(item_complement, :activate) do widget   
            _complements!(undo_list, redo_list, image)
        end
        # add_shortcut

        # swap colors
        signal_connect(item_swap_colors, :activate) do widget     
            _swap_colors!(undo_list, redo_list, image)
        end
        # add_shortcut

        ############## settings ##############

        # open
        signal_connect(settings_button, :clicked) do widget
            set_upper!(top_label_scale, G.n)
            showall(settings_window)

            return nothing
        end

        # close
        signal_connect(settings_cancel_button, :clicked) do widget
            hide(settings_window)
        end
        # add_shortcut x or esc

        signal_connect(settings_window, :delete_event) do widget, others...
            hide(settings_window)
            return true
        end

        signal_connect(settings_ok_button, :clicked) do widget

            # TODO just use resolution. size is obsolete
            # size = tryparse(Int, get_gtk_property(display_size_entry, :text, String) )
            # isnothing(size) && size = resolution

            # if size > 1000 
            #     size = 1000
            # end

            res = tryparse(Int, get_gtk_property(resolution_entry, :text, String) )
            isnothing(res) && (res = resolution)
            (100 <= res <= 1024) || (res = 512)
            # TODO make stuff scrollable instead or add settings in menubar

            resolution = res
            
            signal_handler_block(resolution_entry, changed_res_id)
            set_gtk_property!(resolution_entry, :text, "$resolution")
            signal_handler_unblock(resolution_entry, changed_res_id)

            set_size_request!(image, resolution, resolution)
            
            drawmode_id = get_gtk_property(drawmode_dropdown, :active, Int)
            drawmode = (:straight, :smooth, :tiling)[drawmode_id+1]

            direction_id = get_gtk_property(label_direction_dropdown, :active, Int) 
            label_direction = (:left, :right)[direction_id+1]

            draw_labels = is_active(draw_labels_check)
            highlight_mutables = is_active(highlight_mutables_check)

            if is_active(top_label_check)
                top_label = GAccessor.value(top_label_scale)
            else
                top_label = -1.0
                GAccessor.value(top_label_scale)
            end
            
            # theme_dropdown_item = get_selected(theme_dropdown)
            
            # if theme_dropdown_item == theme_dropdown_item_1
            #     theme = "dark"
            #     set_current_theme!(app, THEME_DEFAULT_DARK)
            # else
            #     theme = "light"
            #     set_current_theme!(app, THEME_DEFAULT_LIGHT)
            # end

            D = Dict(
                "size" => size,
                "resolution" => resolution,
                "drawmode" => drawmode,
                "draw_labels" => draw_labels,
                "highlight_mutables" => highlight_mutables,
                "top_label" => top_label,
                "label_direction" => label_direction,
                "theme" => theme
            )
            FileIO.save(bin_path * "config.jld2", D)

            _, s, R_poly = WSC.embedding_data(G, resolution, resolution, top_label)
            tau = i -> label_emb(i, R_poly, G, s)
            update_image!(image)
            
            hide(settings_window)
        end

        fallback_resolution = resolution
        changed_res_id = signal_connect(resolution_entry, :changed) do widget
            try 
                fallback_resolution = parse(Int64, get_gtk_property(resolution_entry, :text, String) )
            catch
                signal_handler_block(resolution_entry, changed_res_id)
                set_gtk_property!(resolution_entry, :text, "$fallback_resolution")
                signal_handler_unblock(resolution_entry, changed_res_id)
            end
        end

        signal_connect(top_label_check, :toggled) do widget
            set_gtk_property!(top_label_scale, :sensitive, is_active(top_label_check))
            is_active(top_label_check) || GAccessor.value(top_label_scale, -1.0)
        end


        ############## export ##############

        # open
        signal_connect(item_export, :activate) do widget
            set_upper!(export_top_label_scale, G.n)
            showall(export_window)
        end

        # close
        signal_connect(export_cancel_button, :clicked) do widget
            hide(export_window)
        end

        signal_connect(export_window, :delete_event) do widget, others...
            hide(export_window)
            return true
        end

        signal_connect(export_ok_button, :clicked) do widget

            chosen_path = save_dialog("Save as...", main_window, ("*.pdf","*.png","*.svg",".eps"))
            chosen_path == "" && return nothing
            chosen_path, ext = splitext(chosen_path)

            ext in (".pdf",".png",".svg",".eps") || (ext = ".pdf")
            chosen_path *= ext

            # TODO allow only numbers as input
            w = tryparse(Int, get_gtk_property(export_width_entry, :text, String) ) 
            h = tryparse(Int, get_gtk_property(export_height_entry, :text, String) )
            isnothing(w) && (w = resolution)
            isnothing(h) && (h = resolution)

            if is_active(export_top_label_check)
                export_top_label = GAccessor.value(export_top_label_scale)
            else
                export_top_label = -1.0
                GAccessor.value(export_top_label_scale, -1.0)
            end
    
            export_draw_labels = is_active(export_draw_labels_check)
            
            col_name = get_gtk_property(export_background_entry, :text, String)
            export_background_color = ""
            try 
                export_background_color = parse(Colors.Colorant, col_name)
            catch end
                
            drawmode_id = get_gtk_property(export_figure_dropdown, :active, Int)
            chosen_drawmode = (:straight, :smooth, :tiling)[drawmode_id+1]

            WSC.draw(G, chosen_path, w, h;
            top_label = export_top_label, 
            font_scale = 1.0,
            drawmode = chosen_drawmode, 
            background_color = export_background_color, 
            draw_labels = export_draw_labels, 
            highlight_mutables = highlight_mutables, 
            highlight = 0, 
            label_direction = label_direction)
            
            hide(export_window)
            return nothing
        end
        
        # TODO figure out how to block signals and use this to only allow numeric input here
        fallback_width = resolution
        changed_w_id = signal_connect(export_width_entry, :changed) do widget
            try
                fallback_width = parse(Int64, get_gtk_property(export_width_entry, :text, String))
            catch
                signal_handler_block(export_width_entry, changed_w_id)
                set_gtk_property!(export_width_entry, :text, "$fallback_width")
                signal_handler_unblock(export_width_entry, changed_w_id)
            end
        end

        fallback_height = resolution
        changed_h_id = signal_connect(export_height_entry, :changed) do widget
            try
                fallback_height = parse(Int64, get_gtk_property(export_height_entry, :text, String))
            catch
                signal_handler_block(export_height_entry, changed_h_id)
                set_gtk_property!(export_height_entry, :text, "$fallback_height")
                signal_handler_unblock(export_height_entry, changed_h_id)
            end
        end

        signal_connect(export_top_label_check, :toggled) do widget
            set_gtk_property!(export_top_label_scale, :sensitive, is_active(export_top_label_check))
            is_active(export_top_label_check) || GAccessor.value(export_top_label_scale, -1.0)
        end

        ############## predefined ##############

        # open
        signal_connect(item_predefined, :activate) do widget
            showall(predefined_window)
        end

        # close
        signal_connect(predefined_cancel_button, :clicked) do widget
            hide(predefined_window)
        end
        # add_shortcut!(predefined_cancel, "x") or esc

        signal_connect(predefined_window, :delete_event) do widget, others... 
            hide(predefined_window)
            return true
        end

        signal_connect(predefined_ok_button, :clicked) do widget
            k = get_gtk_property(predefined_spin_k, :value, Int)
            n = get_gtk_property(predefined_spin_n, :value, Int)
            id = get_gtk_property(predefined_dropdown, :active, Int)

            chosen_wsc = ("checkboard", "rectangle", 
                            "dual_checkboard", "dual_rectangle")[id+1]
            constr = (check_collection, rec_collection, 
                        dcheck_collection, drec_collection)[id+1]

            H = constr(k, n; keepCliques = true)
            H == G && return nothing
             
            push_undo!(undo_list, redo_list, chosen_wsc, (G, k, n))
            G = H

            _, s, R_poly = WSC.embedding_data(G, resolution, resolution, top_label)
            tau = i -> label_emb(i, R_poly, G, s)
            update_image!(image)
            hide(predefined_window)
            return nothing
        end

        signal_connect(predefined_spin_n, :changed) do widget
            upper = get_gtk_property(widget, :value, Int) -2
            set_gtk_property!(predefined_spin_k, :value, min(get_gtk_property(predefined_spin_k, :value, Int), upper))
            set_upper!(predefined_spin_k, upper)
        end

        ############## hotkeys ##############

        signal_connect(main_window, :key_press_event) do widget, event
            k = event.keyval
            if k == 65307 # esc
                set_upper!(top_label_scale, G.n)
                showall(settings_window)
            elseif k == 122 # z
                undo!(undo_list, redo_list, image)
            elseif k == 121 # y
                redo!(undo_list, redo_list, image)
            elseif k == 97 # a
                _rotate!(1, undo_list, redo_list, image)
            elseif k == 100 # d
                _rotate!(-1, undo_list, redo_list, image)
            elseif k == 109 # m
                _mirror!(undo_list, redo_list, image)
            elseif k == 115 # s
                _swap_colors!(undo_list, redo_list, image)
            elseif k == 99 # c
                _complements!(undo_list, redo_list, image)
            elseif k == 80 # P
                showall(predefined_window)
            elseif k == 83 # S
                save_callback(item_save_as)
            elseif k == 69 # NICE (E)
                set_upper!(export_top_label_scale, G.n)
                showall(export_window)
            elseif k == 76 # L
                load_callback(item_load)
            end
        end

        signal_connect(settings_window, :key_press_event) do widget, event
            if event.keyval == 65307 # esc
                hide(settings_window)
            end
        end

        signal_connect(export_window, :key_press_event) do widget, event
            if event.keyval == 65307 # esc
                hide(export_window)
            end
        end

        signal_connect(predefined_window, :key_press_event) do widget, event
            if event.keyval == 65307 # esc
                hide(predefined_window)
            end
        end

        ############################ Start app ############################

        showall(main_window)
        
        if !isinteractive()
            @async Gtk.gtk_main()
            Gtk.waitforsignal(main_window, :destroy)
        end

        return G
    end

    ############################ additional functions ############################

    function load_settings()
        D = Dict()
        try 
            D = FileIO.load(bin_path * "config.jld2")
        catch 
            # if no config file exists, create one
            
            D = Dict(
            "size" => size,
            "resolution" => resolution,
            "drawmode" => drawmode,
            "draw_labels" => draw_labels,
            "highlight_mutables" => highlight_mutables,
            "top_label" => top_label,
            "label_direction" => label_direction,
            "theme" => theme
            )
            FileIO.save(bin_path * "config.jld2", D)
        end
        try 
            size = D["size"]
            resolution = D["resolution"]
            drawmode = D["drawmode"]
            draw_labels = D["draw_labels"]
            theme = D["theme"]
            top_label = D["top_label"]
            highlight_mutables = D["highlight_mutables"]
            label_direction = D["label_direction"]
        catch 
        end
        
        # TODO no idea ho to set a theme in Gtk4
        # if theme == "dark"
        #     set_current_theme!(app, THEME_DEFAULT_DARK)
        # else
        #     set_current_theme!(app, THEME_DEFAULT_LIGHT)
        # end
    end

    function update_image!(image)
        WSC.draw(G, bin_path*"image.svg", resolution, resolution;
        top_label, 
        font_scale = 1.0,
        drawmode, 
        background_color = "lightgrey", 
        draw_labels, 
        highlight_mutables, 
        highlight = 0, 
        label_direction)

        set_gtk_property!(image, :file, bin_path * "image.svg")
    end

    function undo!(undo_list, redo_list, image)
        if !isempty(undo_list)
            (task, data) = pop!(undo_list)
            push!(redo_list, (task, data))

            if task == "mutation"
                mutate!(G, data[1]; updateCliques = true)
                update_image!(image)
            elseif task == "complements"
                complements!(G)
                _, s, R_poly = WSC.embedding_data(G, resolution, resolution, top_label)
                tau = i -> label_emb(i, R_poly, G, s)
                update_image!(image)
            elseif task == "swap_colors"
                swap_colors!(G)
                _, s, R_poly = WSC.embedding_data(G, resolution, resolution, top_label)
                tau = i -> label_emb(i, R_poly, G, s)
                update_image!(image)
            elseif task == "rotate"
                WSC.rotate!(G, -data[1])
                update_image!(image)
            elseif task == "mirror"
                mirror!(G)
                update_image!(image)
            else # task is predefined or load. All handeled the same
                G = data[1]
                _, s, R_poly = WSC.embedding_data(G, resolution, resolution, top_label)
                tau = i -> label_emb(i, R_poly, G, s)
                update_image!(image)
            end
        end
    end

    function redo!(undo_list, redo_list, image)
        if !isempty(redo_list)
            (task, data) = pop!(redo_list)
            push!(undo_list, (task, data))

            # mutate and update displays
            if task == "mutation"
                mutate!(G, data[1]; updateCliques = true)
                update_image!(image)
            elseif task == "checkboard"
                G = check_collection(data[2], data[3]; keepCliques = true)
                _, s, R_poly = WSC.embedding_data(G, resolution, resolution, top_label)
                tau = i -> label_emb(i, R_poly, G, s)
                update_image!(image)
            elseif task == "rectangle"
                G = rec_collection(data[2], data[3]; keepCliques = true)
                _, s, R_poly = WSC.embedding_data(G, resolution, resolution, top_label)
                tau = i -> label_emb(i, R_poly, G, s)
                update_image!(image)
            elseif task == "dual_checkboard"
                G = dcheck_collection(data[2], data[3]; keepCliques = true)
                _, s, R_poly = WSC.embedding_data(G, resolution, resolution, top_label)
                tau = i -> label_emb(i, R_poly, G, s)
                update_image!(image)
            elseif task == "dual_rectangle"
                G = drec_collection(data[2], data[3]; keepCliques = true)
                _, s, R_poly = WSC.embedding_data(G, resolution, resolution, top_label)
                tau = i -> label_emb(i, R_poly, G, s)
                update_image!(image)
            elseif task == "complements"
                complements!(G)
                _, s, R_poly = WSC.embedding_data(G, resolution, resolution, top_label)
                tau = i -> label_emb(i, R_poly, G, s)
                update_image!(image)
            elseif task == "swap_colors"
                swap_colors!(G)
                _, s, R_poly = WSC.embedding_data(G, resolution, resolution, top_label)
                tau = i -> label_emb(i, R_poly, G, s)
                update_image!(image)
            elseif task == "rotate"
                WSC.rotate!(G, data[1])
                update_image!(image)
            elseif task == "mirror"
                mirror!(G)
                update_image!(image)
            else # task == "load"
                D = FileIO.load(data[2])

                W, B = WSC.compute_cliques(D["labels"])
                Q = WSC.compute_quiver(D["n"], D["labels"], W)
                G = WSCollection(D["k"], D["n"], D["labels"], Q, W, B)
                
                _, s, R_poly = WSC.embedding_data(G, resolution, resolution, top_label)
                tau = i -> label_emb(i, R_poly, G, s)
                update_image!(image)
            end
        end
    end

    function push_undo!(undo_list, redo_list, task, data)
        push!(undo_list, (task, data))
        if !isempty(redo_list)
            rtask, rdata = pop!(redo_list)
            if rtask != task || rdata != data
                empty!(redo_list)
            end
        end
    end

    function _rotate!(val, undo_list, redo_list, image)
        push_undo!(undo_list, redo_list, "rotate", (val,))
        WSC.rotate!(G, val)
        update_image!(image)
    end

    function _mirror!(undo_list, redo_list, image)
        push_undo!(undo_list, redo_list, "mirror", (1,))
        mirror!(G)
        update_image!(image)
    end

    function _complements!(undo_list, redo_list, image)
        push_undo!(undo_list, redo_list, "complements", ())
        complements!(G)
        _, s, R_poly = WSC.embedding_data(G, resolution, resolution, top_label)
        tau = i -> label_emb(i, R_poly, G, s)
        update_image!(image)
    end

    function _swap_colors!(undo_list, redo_list, image)
        push_undo!(undo_list, redo_list, "swap_colors", ())
        swap_colors!(G)
        _, s, R_poly = WSC.embedding_data(G, resolution, resolution, top_label)
        tau = i -> label_emb(i, R_poly, G, s)
        update_image!(image)
    end

     
    @suppress_err activate()
    
end

function __init__()
    global bin_path = @get_scratch!("bin")
end

end