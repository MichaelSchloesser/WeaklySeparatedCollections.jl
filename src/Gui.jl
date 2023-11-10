
bin_path = ""

function visualizer(collection::WSCollection = rectangle_collection(4, 9))
    LPoint = Luxor.Point

    main() do app::Application
        
        ####################################################################################
        ###                                Internal data                                 ###
        ####################################################################################
        
        # display data 
        size = 500
        resolution = 500
        plg_drawmode = "smooth"
        draw_vertex_labels = true
        draw_face_labels = true
        highlight_mutables = false
        adjust_angle = false    

        # theme and colors
        theme = "dark"

        # history/undo/redo
        undo_list = Vector()
        redo_list = Vector()

        # initial weakly separated collection 
        G = collection

        function load_settings()
            D = Dict()

            try 
                D = FileIO.load(bin_path * "config.jld2")
            catch e
                # if no config file exists, create one
                D = Dict(
                "size" => size,
                "resolution" => resolution,
                "plg_drawmode" => plg_drawmode,
                "draw_vertex_labels" => draw_vertex_labels,
                "draw_face_labels" => draw_face_labels,
                "highlight_mutables" => highlight_mutables,
                "adjust_angle" => adjust_angle,
                "theme" => theme
                )
                FileIO.save(bin_path * "config.jld2", D)
            end
            
            size = D["size"]
            resolution = D["resolution"]
            plg_drawmode = D["plg_drawmode"]
            draw_vertex_labels = D["draw_vertex_labels"]
            draw_face_labels = D["draw_face_labels"]
            adjust_angle = D["adjust_angle"]
            theme = D["theme"]

            try
                highlight_mutables = D["highlight_mutables"]
            catch e
            end
            
            if theme == "dark"
                set_current_theme!(app, THEME_DEFAULT_DARK)
            else
                set_current_theme!(app, THEME_DEFAULT_LIGHT)
            end
        end
        load_settings()

        # embedding data
        reference_polygon = []
        reference_radius = 1
        scale = resolution/(scale_factor * reference_radius)
        tau = i -> scale*sum( reference_polygon[G.labels[i]] )

        function update_embedding_data()
            reference_polygon = [LPoint( sin(i*2*pi/G.n), -cos(i*2*pi/G.n) ) for i = 0:G.n-1 ]
            reference_radius = norm(sum(reference_polygon[1:G.k]))
            scale = resolution/(scale_factor * reference_radius)

            if adjust_angle
                angle = acos( -sum(reference_polygon[1:G.k]).y/norm(sum(reference_polygon[1:G.k])) ) - (G.k-1)*2*pi/G.n
                reference_polygon = [LPoint( sin(i*2*pi/G.n - angle), -cos(i*2*pi/G.n - angle) ) for i = 0:G.n-1 ]
            end
        end
        update_embedding_data()

        ####################################################################################
        ###                                      GUI                                     ###
        ####################################################################################

        # css classes do not work properly jet

        # add_css!("""
        #     .sharp-corners {
        #     border-radius: 0%;
        #     }
        # """)

        # add_css!(""" 
        #     .larger-font {
        #     font-size: 15pt;
        #     }
        # """) 


        # convenience functions
        function MySeparator(opacity::AbstractFloat)
            sep = Separator()
            set_opacity!(sep, opacity)
            return sep
        end

        function hline(height::Int)
            sep = Separator()
            set_expand_vertically!(sep, false)
            set_expand_horizontally!(sep, true)
            set_size_request!(sep, Vector2f(0, height))
            return sep
        end

        ############## Displays ##############

        # left display
        image_display_left = ImageDisplay()
        set_size_request!(image_display_left, Vector2f(size, size))
        set_expand!(image_display_left, true)

        # right display
        image_display_right = ImageDisplay()
        set_size_request!(image_display_right, Vector2f(size, size))
        set_expand!(image_display_right, true)
        
        function update_displays()
            drawTiling(G, bin_path*"display.png", resolution, resolution, 
            backgroundColor = "lightblue4", drawLabels = draw_vertex_labels, adjustAngle = adjust_angle)

            if plg_drawmode == "smooth"
                drawPLG_smooth(G, bin_path*"display2.png", resolution, resolution, 
                backgroundColor = "lightblue4", drawLabels = draw_face_labels, adjustAngle = adjust_angle)
            elseif plg_drawmode == "straight"
                drawPLG_straight(G, bin_path*"display2.png", resolution, resolution, 
                backgroundColor = "lightblue4", drawLabels = draw_face_labels, adjustAngle = adjust_angle, highlightMutables = highlight_mutables)
            else
                drawPLG_poly(G, bin_path*"display2.png", resolution, resolution, 
                backgroundColor = "lightblue4", drawLabels = draw_face_labels, adjustAngle = adjust_angle)
            end

            create_from_file!(image_display_left, bin_path * "display.png")
            create_from_file!(image_display_right, bin_path * "display2.png")
        end
        
        update_displays() # draw once initially

        ############## Menubar ##############

        root = MenuModel()
        menubar = MenuBar(root)

        # menubar first level
        file_submenu = MenuModel()
        edit_submenu = MenuModel()
        view_submenu = MenuModel()
        
        add_submenu!(root, "File", file_submenu) # open save(as) exit
        add_submenu!(root, "Edit", edit_submenu) # undo redo
        add_submenu!(root, "View", view_submenu) # turn on/off ui elements

        ############## export window ##############

        export_window = Window(app)
        set_layout!(get_header_bar(export_window), ":close")
        set_hide_on_close!(export_window, true)
        set_title!(export_window, "Export")

        export_figure_label = Label("Figure:")
        set_size_request!(export_figure_label, Vector2f(80, 0))
        export_figure_dropdown = DropDown()
        set_size_request!(export_figure_dropdown, Vector2f(115, 0))
        figure_dropdown_item_1 = push_back!(export_figure_dropdown, "Plabic Tiling")
        figure_dropdown_item_2 = push_back!(export_figure_dropdown, "Plabic Graph")

        export_resolution_label = Label("Resolution:")
        set_size_request!(export_resolution_label, Vector2f(80, 0))
        export_width_entry = Entry()
        set_max_width_chars!(export_width_entry, 5)
        set_text!(export_width_entry, "$resolution")
        
        export_width_entry_clamp = ClampFrame(55, ORIENTATION_HORIZONTAL)
        set_child!(export_width_entry_clamp, export_width_entry)
        set_margin_top!(export_width_entry_clamp, 5)
        set_margin_end!(export_width_entry_clamp, 5)
        
        export_height_entry = Entry()
        set_max_width_chars!(export_width_entry, 5)
        set_text!(export_height_entry, "$resolution")
        
        export_height_entry_clamp = ClampFrame(55, ORIENTATION_HORIZONTAL)
        set_child!(export_height_entry_clamp, export_height_entry)
        set_margin_top!(export_height_entry_clamp, 5)

        export_adjust_angle_label = Label("Adjust drawing angle:")
        set_size_request!(export_adjust_angle_label, Vector2f(120, 0))

        export_adjust_angle_check = CheckButton() # TODO could use a tooltip
        if adjust_angle
            set_state!(export_adjust_angle_check, CHECK_BUTTON_STATE_ACTIVE)
        else
            set_state!(export_adjust_angle_check, CHECK_BUTTON_STATE_INACTIVE)
        end
        set_margin_vertical!(export_adjust_angle_check, 5)

        export_ok_button = Button()
        set_child!(export_ok_button, Label("Ok"))
        set_size_request!(export_ok_button, Vector2f(80, 0))
        set_margin_top!(export_ok_button, 10)
        set_margin_end!(export_ok_button, 5)

        export_cancel_button = Button()
        set_child!(export_cancel_button, Label("Cancel"))
        set_size_request!(export_cancel_button, Vector2f(80, 0))
        set_margin_top!(export_cancel_button, 10)

        export_buttons = hbox(export_ok_button, export_cancel_button)
        set_horizontal_alignment!(export_buttons, ALIGNMENT_END)

        export_window_content = vbox(
            hbox(export_figure_label, export_figure_dropdown),
            hbox(export_resolution_label, export_width_entry_clamp, export_height_entry_clamp),
            hbox(export_adjust_angle_label, export_adjust_angle_check),
            export_buttons
        )
        set_margin!(export_window_content, 10)

        set_child!(export_window, export_window_content)

        ############## predefined window ##############

        predefined_window = Window(app)
        set_layout!(get_header_bar(predefined_window), ":close")
        set_hide_on_close!(predefined_window, true)
        set_title!(predefined_window, "Predefined")
    
        predefined_dropdown = DropDown()
        predefined_dropdown_item_1 = push_back!(predefined_dropdown, "Checkboard")
        predefined_dropdown_item_2 = push_back!(predefined_dropdown, "Rectangle")
        predefined_dropdown_item_3 = push_back!(predefined_dropdown, "Dual Checkboard")
        _ = push_back!(predefined_dropdown, "Dual Rectangle")

        predefined_spin_n = SpinButton(4, 100, 1)
        set_margin_top!(predefined_spin_n, 5)
        predefined_spin_k = SpinButton(2, G.n-2, 1)
        set_margin_top!(predefined_spin_k, 5)
        set_value!(predefined_spin_n, G.n)
        set_value!(predefined_spin_k, G.k)

        predefined_label_n = Label("Select n :")
        predefined_label_k = Label("Select k :")
        set_size_request!(predefined_label_n, Vector2f(70, 0))
        set_size_request!(predefined_label_k, Vector2f(70, 0))

        predefined_ok_button = Button()
        set_margin_top!(predefined_ok_button, 10)
        set_child!(predefined_ok_button, Label("Ok"))
        set_size_request!(predefined_ok_button, Vector2f(80, 0))
        set_margin_end!(predefined_ok_button, 5)

        predefined_cancel_button = Button()
        set_margin_top!(predefined_cancel_button, 10)
        set_child!(predefined_cancel_button, Label("Cancel"))
        set_size_request!(predefined_cancel_button, Vector2f(80, 0))

        predefined_buttons = hbox(predefined_ok_button, predefined_cancel_button)
        set_horizontal_alignment!(predefined_buttons, ALIGNMENT_END)

        predefined_window_content = vbox(  
            predefined_dropdown,
            hbox(predefined_label_n, predefined_spin_n), 
            hbox(predefined_label_k, predefined_spin_k),
            predefined_buttons
        )
        set_margin!(predefined_window_content, 10)

        set_child!(predefined_window, predefined_window_content)
        
        ############## settings ##############

        settings_button = Button()
        set_child!(settings_button, Label("Settings"))
        set_size_request!(settings_button, Vector2f(60, 0))
        set_expand!(settings_button, false)
        set_margin!(settings_button, 10)

        settings_window = Window(app)
        set_layout!(get_header_bar(settings_window), ":close")
        set_hide_on_close!(settings_window, true)
        set_title!(settings_window, "Settings")

        display_size_label = Label("Display size:")
        set_size_request!(display_size_label, Vector2f(140, 0))
        display_resolution_label = Label("Display resolution:")
        set_size_request!(display_resolution_label, Vector2f(140, 0))
        plg_drawmode_label = Label("Plg draw mode:")
        set_size_request!(plg_drawmode_label, Vector2f(140, 0))
        draw_vertex_labels_label = Label("Draw vertex labels:")
        set_size_request!(draw_vertex_labels_label, Vector2f(140, 0))
        draw_face_labels_label = Label("Draw face labels:")
        set_size_request!(draw_face_labels_label, Vector2f(140, 0))
        highlight_mutables_label = Label("Highlight mutable faces:")
        set_size_request!(highlight_mutables_label, Vector2f(140, 0))
        adjust_angle_label = Label("Adjust drawing angle:")
        set_size_request!(adjust_angle_label, Vector2f(140, 0))
        theme_label = Label("Theme:")
        set_size_request!(theme_label, Vector2f(140, 0))

        display_size_entry = Entry()
        set_max_width_chars!(display_size_entry, 5)
        set_text!(display_size_entry, "$size")
        display_size_clamp = ClampFrame(55, ORIENTATION_HORIZONTAL)
        set_child!(display_size_clamp, display_size_entry)

        display_resolution_entry = Entry()
        set_max_width_chars!(display_resolution_entry, 5)
        set_text!(display_resolution_entry, "$resolution")
        display_resolution_clamp = ClampFrame(55, ORIENTATION_HORIZONTAL)
        set_child!(display_resolution_clamp, display_resolution_entry)
        set_margin_top!(display_resolution_clamp, 5)

        plg_drawmode_dropdown = DropDown()
        plg_drawmode_dropdown_item_1 = push_back!(plg_drawmode_dropdown, "Straight")
        plg_drawmode_dropdown_item_2 = push_back!(plg_drawmode_dropdown, "Smooth")
        plg_drawmode_dropdown_item_3 = push_back!(plg_drawmode_dropdown, "Polygonal")
        set_size_request!(plg_drawmode_dropdown, Vector2f(110, 0))
        set_margin_top!(plg_drawmode_dropdown, 5)
        if plg_drawmode == "straight"
            set_selected!(plg_drawmode_dropdown, plg_drawmode_dropdown_item_1)
        elseif plg_drawmode == "smooth"
            set_selected!(plg_drawmode_dropdown, plg_drawmode_dropdown_item_2)
        else
            set_selected!(plg_drawmode_dropdown, plg_drawmode_dropdown_item_3)
        end

        draw_vertex_labels_check = CheckButton()
        if draw_vertex_labels
            set_state!(draw_vertex_labels_check, CHECK_BUTTON_STATE_ACTIVE)
        else
            set_state!(draw_vertex_labels_check, CHECK_BUTTON_STATE_INACTIVE)
        end
        set_margin_top!(draw_vertex_labels_check, 5)

        draw_face_labels_check = CheckButton()
        if draw_face_labels
            set_state!(draw_face_labels_check, CHECK_BUTTON_STATE_ACTIVE)
        else
            set_state!(draw_face_labels_check, CHECK_BUTTON_STATE_INACTIVE)
        end
        set_margin_top!(draw_face_labels_check, 5)

        highlight_mutables_check = CheckButton()
        if highlight_mutables
            set_state!(highlight_mutables_check, CHECK_BUTTON_STATE_ACTIVE)
        else
            set_state!(highlight_mutables_check, CHECK_BUTTON_STATE_INACTIVE)
        end
        set_margin_top!(highlight_mutables_check, 5)

        adjust_angle_check = CheckButton()
        if adjust_angle
            set_state!(adjust_angle_check, CHECK_BUTTON_STATE_ACTIVE)
        else
            set_state!(adjust_angle_check, CHECK_BUTTON_STATE_INACTIVE)
        end
        set_margin_vertical!(adjust_angle_check, 5)
        
        theme_dropdown = DropDown()
        theme_dropdown_item_1 = push_back!(theme_dropdown, "Darkmode")
        theme_dropdown_item_2 = push_back!(theme_dropdown, "Lightmode")
        set_size_request!(theme_dropdown, Vector2f(110, 0))
        set_margin_top!(theme_dropdown, 5)
        if theme == "dark"
            set_selected!(theme_dropdown, theme_dropdown_item_1)
        else
            set_selected!(theme_dropdown, theme_dropdown_item_2)
        end

        # TODO
        # color_chooser does not work 
        # colors of background, white, black (via color selector)

        settings_ok_button = Button()
        set_margin_top!(settings_ok_button, 10)
        set_child!(settings_ok_button, Label("Ok"))
        set_size_request!(settings_ok_button, Vector2f(80, 0))
        set_margin_end!(settings_ok_button, 5)

        settings_cancel_button = Button()
        set_margin_top!(settings_cancel_button, 10)
        set_child!(settings_cancel_button, Label("Cancel"))
        set_size_request!(settings_cancel_button, Vector2f(80, 0))

        settings_buttons = hbox(settings_ok_button, settings_cancel_button)
        set_horizontal_alignment!(settings_buttons, ALIGNMENT_END)

        settings_window_content = vbox(
            hbox(display_size_label, display_size_clamp),
            hbox(display_resolution_label, display_resolution_clamp),
            hbox(plg_drawmode_label, plg_drawmode_dropdown),
            hbox(draw_vertex_labels_label, draw_vertex_labels_check),
            hbox(draw_face_labels_label, draw_face_labels_check),
            hbox(highlight_mutables_label, highlight_mutables_check),
            hbox(adjust_angle_label, adjust_angle_check),
            hline(2),
            hbox(theme_label, theme_dropdown),
            # TODO color stuffi
            settings_buttons
        )
        set_margin!(settings_window_content, 10)

        set_child!(settings_window, settings_window_content)

        ############## history ##############

        history_notebook = Notebook()
        set_expand!(history_notebook, true)
        set_has_border!(history_notebook, false)

        history_label = Label()
        set_margin!(history_label, 10)
        set_horizontal_alignment!(history_label, ALIGNMENT_START)
        set_vertical_alignment!(history_label, ALIGNMENT_START)
        set_justify_mode!(history_label, JUSTIFY_MODE_LEFT)
        set_wrap_mode!(history_label, LABEL_WRAP_MODE_ONLY_ON_WORD)
        set_text!(history_label, "")

        undo_label = Label()
        set_margin!(undo_label, 10)
        set_horizontal_alignment!(undo_label, ALIGNMENT_START)
        set_vertical_alignment!(undo_label, ALIGNMENT_START)
        set_justify_mode!(undo_label, JUSTIFY_MODE_LEFT)
        set_wrap_mode!(undo_label, LABEL_WRAP_MODE_ONLY_ON_WORD)
        set_text!(undo_label, "")

        redo_label = Label()
        set_margin!(redo_label, 10)
        set_horizontal_alignment!(redo_label, ALIGNMENT_START)
        set_vertical_alignment!(redo_label, ALIGNMENT_START)
        set_justify_mode!(redo_label, JUSTIFY_MODE_LEFT)
        set_wrap_mode!(redo_label, LABEL_WRAP_MODE_ONLY_ON_WORD)
        set_text!(redo_label, "")

        history_clear_button = Button()
        history_clear_label = Label("Clear") 
        set_tooltip_text!(history_clear_button, "clear selected tab (History or Undos/Redos)")
        set_child!(history_clear_button, history_clear_label)
        set_expand!(history_clear_button, false)
        set_margin!(history_clear_button, 10)

        id_01 = push_back!(history_notebook, vbox(history_label), Label("History"))
        id_02 = push_back!(history_notebook, vbox(undo_label, redo_label), Label("Undos/Redos"))
        goto_page!(history_notebook, 2) 

        ############## main window ##############

        main_window = Window(app)
        set_title!(main_window, "WSC-Visualizer")
        
        display_row = AspectFrame(2.0)
        set_child!(display_row, hbox(image_display_left, image_display_right))
        set_margin!(display_row, 10)

        currently_selected_label = Label("currently selected: nothing")
        set_size_request!(currently_selected_label, Vector2f(0, 20))
        set_margin_bottom!(currently_selected_label, 10)
        
        paned = Paned(ORIENTATION_VERTICAL)
        set_start_child!(paned,  vbox(display_row, currently_selected_label))
        set_end_child!(paned, history_notebook)
        set_start_child_shrinkable!(paned, false)
        set_end_child_shrinkable!(paned, true)
        
        main_window_content = vbox(
                menubar,
                paned,
                hbox(settings_button, MySeparator(0.0), history_clear_button)
        )
        set_expand!(main_window_content, true)
        
        set_child!(main_window, main_window_content)

        ####################################################################################
        ###                                Event handeling                               ###
        ####################################################################################

        ############## (undo/redo) History ##############

        history = ""
        undos = ""
        redos = ""

        function update_history_strings(task, data) # horribly inefficient, but this should not be the bottleneck either way
            
            function task_to_string(task::String, data)
                if task == "mutation"
                    return "(mutate: i=$(data[1]), L=$(data[2]))"
                elseif task == "complement" || task == "swap_colors"
                    return "($task)"
                elseif task == "rotate"
                    return "(rotate by: $(data[1]))"
                elseif task == "reflect"
                    return "(reflected at: $(data[1]))"
                elseif task == "load"
                    filename = replace(data[2], "C:\\Users\\Micha\\My Julia Code\\WSCollection-Visualizer\\saved collections\\"=>"")
                    return "(load: $filename)"
                else 
                    return "($task: k=$(data[2]), n=$(data[3]))"
                end
            end

            # history
            history = history * task_to_string(task, data) * "  "
            set_text!(history_label, history)

            # renew undo string
            if length(undo_list) == 0
                undos = ""
            else
                undos = "Undos: "
                for (undo_task, undo_data) in undo_list
                    undos = undos * task_to_string(undo_task, undo_data) * "  "
                end
            end
            set_text!(undo_label, undos)

            # renew redo string
            if length(redo_list) == 0
                redos = ""
            else
                redos = "Redos: "
                for (redo_task, redo_data) in redo_list
                    redos = redos * task_to_string(redo_task, redo_data) * "  "
                end
            end
            set_text!(redo_label, redos)

        end

    
        clear_history = Action("clear.action", app) do x 
            page = get_current_page(history_notebook)
        
            if page == 1
                history = ""
                set_text!(history_label, "")
            else
                undo_list = Vector()
                redo_list = Vector()
                undos = ""
                redos = ""
                set_text!(undo_label, "")
            set_text!(redo_label, "")
            end

            return nothing
        end
        add_shortcut!(clear_history, "<shift>x")
        set_action!(history_clear_button, clear_history)

        ############## Displays ##############

        # motion_controller_left = MotionEventController()
        # motion_controller_right = MotionEventController()
        click_controller_left = ClickEventController()
        click_controller_right = ClickEventController()

        function set_mouse_input_blocked!(bool::Bool)
            # set_signal_motion_blocked!(motion_controller_left, bool)
            # set_signal_motion_blocked!(motion_controller_right, bool)
            set_signal_click_pressed_blocked!(click_controller_left, bool)
            set_signal_click_pressed_blocked!(click_controller_right, bool)
        end

        # currently selected label
        # function on_motion_left(::MotionEventController, x::AbstractFloat, 
        #                         y::AbstractFloat, data::Widget)
        #     set_signal_motion_blocked!(motion_controller_left, true)
        #     set_signal_motion_blocked!(motion_controller_right, true)
            
        #     w, h = get_allocated_size(data).x, get_allocated_size(data).y
        #     x, y = (x-w/2)*resolution/w, (y-h/2)*resolution/h
            
        #     is_close_mutable = p -> norm(tau(p) - LPoint(x, y)) < 25.0 && isMutable(G, p)
        #     close_mutable = filter(is_close_mutable , [p for p = G.n+1:length(G.labels)])

        #     if length(close_mutable) > 0 # show nearest close mutable label

        #         i = argmin(p -> norm(tau(p) - LPoint(x, y)), close_mutable)
        #         set_text!(currently_selected_label, "currently selected: $(G.labels[i])")
        #     else
        #         set_text!(currently_selected_label, "currently selected: nothing")
        #     end

        #     set_signal_motion_blocked!(motion_controller_right, false)
        #     set_signal_motion_blocked!(motion_controller_left, false)
        #     return nothing
        # end
        # connect_signal_motion!(on_motion_left, motion_controller_left, image_display_left)
        # add_controller!(image_display_left, motion_controller_left)

        # currently selected label
        # function on_motion_right(::MotionEventController, x::AbstractFloat, 
        #                         y::AbstractFloat, data::Widget)
        #     set_signal_motion_blocked!(motion_controller_right, true)
        #     set_signal_motion_blocked!(motion_controller_left, true)

        #     w, h = get_allocated_size(data).x, get_allocated_size(data).y
        #     x, y = (x-w/2)*resolution/w, (y-h/2)*resolution/h
            
        #     function is_surounding_mutable(p::Int)
        #         if isMutable(G, p)
        #             N_out = collect(outneighbors(G.quiver, p))

        #             arith_mean = x -> sum(tau.(x))/length(x)

        #             p1 = arith_mean( G.whiteCliques[ intersect( G.labels[p], G.labels[N_out[1]])  ] )
        #             p2 = arith_mean( G.blackCliques[ sort(union(G.labels[p], G.labels[N_out[1]])) ] )
        #             p3 = arith_mean( G.whiteCliques[ intersect( G.labels[p], G.labels[N_out[2]])  ] )
        #             p4 = arith_mean( G.blackCliques[ sort(union(G.labels[p], G.labels[N_out[2]])) ] )

        #             return isinside(LPoint(x, y), [p1, p2, p3, p4], allowonedge = false)
        #         else
        #             return false
        #         end
        #     end

        #     for i = G.n+1:length(G.labels)
        #         if is_surounding_mutable(i)
        #             set_text!(currently_selected_label, "currently selected: $(G.labels[i])")
        #             break
        #         else
        #             set_text!(currently_selected_label, "currently selected: nothing")
        #         end
        #     end

        #     set_signal_motion_blocked!(motion_controller_left, false)
        #     set_signal_motion_blocked!(motion_controller_right, false)
        #     return nothing
        # end
        # connect_signal_motion!(on_motion_right, motion_controller_right, image_display_right)
        # add_controller!(image_display_right, motion_controller_right)

        # mutate by clicking on vertices 
        function on_click_pressed_left(self::ClickEventController, n_presses::Integer, 
                                    x::AbstractFloat, y::AbstractFloat, data::Widget)

            w, h = get_allocated_size(data).x, get_allocated_size(data).y
            x, y = (x-w/2)*resolution/w, (y-h/2)*resolution/h

            if get_current_button(self) == BUTTON_ID_BUTTON_03 # select label
                
                is_close_mutable = p -> norm(tau(p) - LPoint(x, y)) < 25.0 && isMutable(G, p)
                close_mutable = filter(is_close_mutable , [p for p = G.n+1:length(G.labels)])

                if length(close_mutable) > 0 # show nearest close mutable label

                    i = argmin(p -> norm(tau(p) - LPoint(x, y)), close_mutable)
                    set_text!(currently_selected_label, "currently selected: $(G.labels[i])")
                else
                    set_text!(currently_selected_label, "currently selected: nothing")
                end

            elseif get_current_button(self) == BUTTON_ID_BUTTON_01 # mutate label
                
                set_mouse_input_blocked!(true)
                is_close_mutable = p -> norm(tau(p) - LPoint(x, y)) < 25.0 && isMutable(G, p)
                close_mutable = filter(is_close_mutable , [p for p = G.n+1:length(G.labels)])
        
                if length(close_mutable) > 0 # mutate
                    # select direction of mutation
                    i = argmin(p -> norm(tau(p) - LPoint(x, y)), close_mutable)
                    
                    # mutate and update displays
                    mutate!(G, i)
                    update_displays()

                    # update undo/redo
                    push!(undo_list, ("mutation", [i, G.labels[i]] ))
                    if length(redo_list) > 0 && i != pop!(redo_list)
                        redo_list = Vector() 
                    end
                    update_history_strings("mutation", [i, G.labels[i]] )
                end

                set_mouse_input_blocked!(false)
            end

            return nothing
        end
        connect_signal_click_pressed!(on_click_pressed_left, click_controller_left, image_display_left)
        add_controller!(image_display_left, click_controller_left)

        # select and mutate by clicking on faces 
        function on_click_pressed_right(self::ClickEventController, n_presses::Integer, 
            x::AbstractFloat, y::AbstractFloat, data::Widget)

            function is_surounding_mutable(p::Int)
                if isMutable(G, p)
                    N_out = collect(outneighbors(G.quiver, p))

                    arith_mean = x -> sum(tau.(x))/length(x)

                    p1 = arith_mean( G.whiteCliques[ intersect( G.labels[p], G.labels[N_out[1]])  ] )
                    p2 = arith_mean( G.blackCliques[ sort(union(G.labels[p], G.labels[N_out[1]])) ] )
                    p3 = arith_mean( G.whiteCliques[ intersect( G.labels[p], G.labels[N_out[2]])  ] )
                    p4 = arith_mean( G.blackCliques[ sort(union(G.labels[p], G.labels[N_out[2]])) ] )

                    return isinside(LPoint(x, y), [p1, p2, p3, p4], allowonedge = false)
                else
                    return false
                end
            end

            w, h = get_allocated_size(data).x, get_allocated_size(data).y
            x, y = (x-w/2)*resolution/w, (y-h/2)*resolution/h

            if get_current_button(self) == BUTTON_ID_BUTTON_03 # select label
                for i = G.n+1:length(G.labels)
                    if is_surounding_mutable(i)
                        set_text!(currently_selected_label, "currently selected: $(G.labels[i])")
                        break
                    else
                        set_text!(currently_selected_label, "currently selected: nothing")
                    end
                end

            elseif get_current_button(self) == BUTTON_ID_BUTTON_01 # mutate label
                set_mouse_input_blocked!(true)
                for i = G.n+1:length(G.labels)
                    if is_surounding_mutable(i)

                        # mutate and update displays
                        mutate!(G, i)
                        update_displays()
                        
                        # update undo/redo
                        push!(undo_list, ("mutation", [i, G.labels[i]] ))
                        if length(redo_list) > 0 && i != pop!(redo_list)
                            redo_list = Vector() 
                        end
                        update_history_strings("mutation", [i, G.labels[i]] )

                        break
                    end
                end
                set_mouse_input_blocked!(false)

            end

            return nothing
        end
        connect_signal_click_pressed!(on_click_pressed_right, click_controller_right, image_display_right)
        add_controller!(image_display_right, click_controller_right)

        ############## file submenu ##############

        load_collection = Action("load_collection.action", app) do x

            set_mouse_input_blocked!(true)

            file_chooser = FileChooser(FILE_CHOOSER_ACTION_OPEN_FILE)
            filter = FileFilter("*.jld2")
            add_allowed_suffix!(filter, "jld2")
            set_initial_filter!(file_chooser, filter)
        
            on_accept!(file_chooser) do self::FileChooser, files::Vector{FileDescriptor}
                currently_opened = get_path(files[1])
                D = FileIO.load(currently_opened)
                
                Q, W, B = compute_adjacencies(D["k"], D["n"], D["labels"])
                G2 = WSCollection(D["k"], D["n"], D["labels"], Q, W, B)

                push!(undo_list, ("load", [G, currently_opened]))
                if length(redo_list) > 0
                    task, data = pop!(redo_list)
                    if task != "load" || !isequal(data[1], G) || !isequal(data[2], G2)
                        redo_list = Vector()
                    end
                end

                update_history_strings("load", [G, currently_opened])

                G = G2
                update_embedding_data()
                update_displays()
                
                
                return nothing
            end
            present!(file_chooser)

            set_mouse_input_blocked!(false)
            return nothing
        end
        add_shortcut!(load_collection, "<Control>l")
        add_action!(file_submenu, "Load...", load_collection)
        

        # save = Action("save.action", app) do x

        #     set_mouse_input_blocked!(true)

        #     if currently_opened == ""
        #         activate!(save_as)
        #     else
        #         D = Dict("k" => G.k, "n" => G.n, "labels" => G.labels)
        #         FileIO.save(currently_opened, D)
        #     end

        #     set_mouse_input_blocked!(false)
        #     return nothing
        # end
        # add_shortcut!(save, "<Control>s")
        # add_action!(file_submenu, "Save", save)
        

        save_as = Action("save_as.action", app) do x

            set_mouse_input_blocked!(true)

            chosen_path = save_file(filterlist = "jld2")

            if !isnothing(chosen_path) && chosen_path != ""
                D = Dict("k" => G.k, "n" => G.n, "labels" => G.labels)
                FileIO.save(chosen_path, D)
                # currently_opened = chosen_path
            end

            set_mouse_input_blocked!(false)
            return nothing
        end
        add_shortcut!(save_as, "<Control>s")
        add_action!(file_submenu, "Save As...", save_as)


        open_export_window = Action("open_export_window.action", app) do x    
            set_is_modal!(export_window, true)
            present!(export_window)

            return nothing
        end
        add_shortcut!(open_export_window, "<Control>e")
        add_action!(file_submenu, "Export...", open_export_window)


        export_ok = Action("export_ok.action", app) do x

            set_mouse_input_blocked!(true)

            chosen_path = save_file(filterlist = "pdf;svg;eps;png")
            if !isnothing(chosen_path) && chosen_path != ""
                
                w, h = parse(Int64, get_text(export_width_entry)) , parse(Int64, get_text(export_height_entry))
                export_adjust_angle = get_is_active(export_adjust_angle_check) 

                if get_selected(export_figure_dropdown) == figure_dropdown_item_1
                    drawTiling(G, chosen_path, w, h, adjustAngle = export_adjust_angle, highlightMutables = false, drawLabels = draw_vertex_labels)
                else
                    if plg_drawmode == "smooth"
                        drawPLG_smooth(G, chosen_path, w, h, adjustAngle = export_adjust_angle, drawLabels = draw_face_labels)
                    elseif plg_drawmode == "straight"
                        drawPLG_straight(G, chosen_path, w, h, adjustAngle = export_adjust_angle, drawLabels = draw_face_labels)
                    else
                        drawPLG_poly(G, chosen_path, w, h, adjustAngle = export_adjust_angle, drawLabels = draw_face_labels)
                    end
                end

            end

            set_is_modal!(export_window, false)
            close!(export_window)

            set_mouse_input_blocked!(false)
            return nothing
        end
        set_action!(export_ok_button, export_ok)


        export_cancel = Action("export_cancel.action", app) do x 
            set_is_modal!(export_window, false)
            close!(export_window)
            
            return nothing
        end
        add_shortcut!(export_cancel, "x")
        set_action!(export_cancel_button, export_cancel)


        fallback_width = resolution
        connect_signal_text_changed!(export_width_entry) do self::Entry
            try 
                fallback_width = parse(Int64, get_text(export_width_entry))
            catch e
                set_text!(export_width_entry, "$fallback_width")
            end
            return nothing
        end


        fallback_height = resolution
        connect_signal_text_changed!(export_height_entry) do self::Entry
            try 
                fallback_height = parse(Int64, get_text(export_height_entry))
            catch e
                set_text!(export_height_entry, "$fallback_height")
            end
            return nothing
        end


        exit = Action("exit.action", app) do x
            # emits close request for main window which is handeled further below
            close!(main_window)
            return nothing
        end
        add_action!(file_submenu, "Exit", exit)

        ############## edit submenu ##############

        undo = Action("undo.action", app) do x 
            set_mouse_input_blocked!(true)

            if length(undo_list) > 0
                (task, data) = pop!(undo_list)
                push!(redo_list, (task, data))

                if task == "mutation"
                    mutate!(G, data[1])
                    update_displays()
                elseif task == "complement"
                    G = complement_collection(G)
                    update_embedding_data()
                    update_displays()
                elseif task == "swap_colors"
                    G = swaped_colors_collection(G)
                    update_embedding_data()
                    update_displays()
                elseif task == "rotate"
                    G = rotate_collection(G, -data[1])
                    update_displays()
                elseif task == "reflect"
                    G = reflect_collection(G)
                    update_displays()
                else # task is predefined or load. All handeled the same
                    G = data[1]
                    update_embedding_data()
                    update_displays()
                end

                update_history_strings(task, data)
            end

            set_mouse_input_blocked!(false)
            return nothing
        end
        add_shortcut!(undo, "<Control>z")
        add_action!(edit_submenu, "Undo", undo)


        redo = Action("redo.action", app) do x
            set_mouse_input_blocked!(true)

            if length(redo_list) > 0
                (task, data) = pop!(redo_list)
                push!(undo_list, (task, data))

                # mutate and update displays
                if task == "mutation"
                    mutate!(G, data[1])
                    update_displays()
                elseif task == "checkboard"
                    G = checkboard_collection(data[2], data[3])
                    update_embedding_data()
                    update_displays()
                elseif task == "rectangle"
                    G = rectangle_collection(data[2], data[3])
                    update_embedding_data()
                    update_displays()
                elseif task == "dual_checkboard"
                    G = dual_checkboard_collection(data[2], data[3])
                    update_embedding_data()
                    update_displays()
                elseif task == "dual_rectangle"
                    G = dual_rectangle_collection(data[2], data[3])
                    update_embedding_data()
                    update_displays()
                elseif task == "complement"
                    G = complement_collection(G)
                    update_embedding_data()
                    update_displays()
                elseif task == "swap_colors"
                    G = swaped_colors_collection(G)
                    update_embedding_data()
                    update_displays()
                elseif task == "rotate"
                    G = rotate_collection(G, data[1])
                    update_displays()
                elseif task == "reflect"
                    G = reflect_collection(G)
                    update_displays()
                else # task == "load"
                    # currently_opened = data[2]
                    D = FileIO.load(data[2])

                    Q, W, B = compute_adjacencies(D["k"], D["n"], D["labels"])
                    G = WSCollection(D["k"], D["n"], D["labels"], Q, W, B)

                    update_embedding_data()
                    update_displays()
                end

                update_history_strings(task, data)
            end
        
            set_mouse_input_blocked!(false)
            return nothing
        end
        add_shortcut!(redo, "<Control>y")
        add_action!(edit_submenu, "Redo", redo)

        # predefined window
        open_predefined_window = Action("open_predefined_window.action", app) do x    
            set_is_modal!(predefined_window, true)
            present!(predefined_window)

            return nothing
        end
        add_shortcut!(open_predefined_window, "<control>p")
        add_action!(edit_submenu, "Predefined...", open_predefined_window)


        connect_signal_value_changed!(predefined_spin_n) do self::SpinButton
            set_upper!(predefined_spin_k, get_value(self)-2)
            set_value!(predefined_spin_k, min(get_value(predefined_spin_k), get_value(self)-2))
            return nothing
        end

        
        predefined_ok = Action("predefined_ok.action", app) do x
            set_mouse_input_blocked!(true)

            k = Int(get_value(predefined_spin_k))
            n = Int(get_value(predefined_spin_n))
            selected = get_selected(predefined_dropdown)

            if selected == predefined_dropdown_item_1

                push!(undo_list, ("checkboard", [G, k, n]))
                if length(redo_list) > 0
                    task, data = pop!(redo_list)
                    if task != "checkboard" || !isequal(data[1], G) || (data[2], data[3]) != (k, n)
                        redo_list = Vector()
                    end
                end

                update_history_strings("checkboard", [G, k, n])
                G = checkboard_collection(k, n)

            elseif selected == predefined_dropdown_item_2

                push!(undo_list, ("rectangle", [G, k, n]))
                if length(redo_list) > 0
                    task, data = pop!(redo_list)
                    if task != "rectangle" || !isequal(data[1], G) || (data[2], data[3]) != (k, n)
                        redo_list = Vector()
                    end
                end
                
                update_history_strings("rectangle", [G, k, n])
                G = rectangle_collection(k, n)
            
            elseif selected == predefined_dropdown_item_3

                push!(undo_list, ("dual_checkboard", [G, k, n]))
                if length(redo_list) > 0
                    task, data = pop!(redo_list)
                    if task != "dual_checkboard" || !isequal(data[1], G) || (data[2], data[3]) != (k, n)
                        redo_list = Vector()
                    end
                end
                
                update_history_strings("dual_checkboard", [G, k, n])
                G = dual_checkboard_collection(k, n)

            else # selected == predefined_dropdown_item_4

                push!(undo_list, ("dual_rectangle", [G, k, n]))
                if length(redo_list) > 0
                    task, data = pop!(redo_list)
                    if task != "dual_rectangle" || !isequal(data[1], G) || (data[2], data[3]) != (k, n)
                        redo_list = Vector()
                    end
                end
                
                update_history_strings("dual_rectangle", [G, k, n])
                G = dual_rectangle_collection(k, n)
            end

            update_embedding_data()
            update_displays()

            set_is_modal!(predefined_window, false)
            close!(predefined_window)

            set_mouse_input_blocked!(false)
            return nothing
        end
        set_action!(predefined_ok_button, predefined_ok)


        predefined_cancel = Action("predefined_cancel.action", app) do x 
            set_is_modal!(predefined_window, false)
            close!(predefined_window)

            return nothing
        end
        add_shortcut!(predefined_cancel, "x")
        set_action!(predefined_cancel_button, predefined_cancel)

        # rotating
        rotate_clockwise = Action("rotate_clockwise.action", app) do x

            set_mouse_input_blocked!(true)
            
            push!(undo_list, ("rotate", [1]))
            if length(redo_list) > 0
                task, data = pop!(redo_list)
                if task != "rotate" || data[1] != 1
                    redo_list = Vector()
                end
            end

            G = rotate_collection(G, 1)
            update_displays()
            update_history_strings("rotate", [1])
        
            set_mouse_input_blocked!(false)
            return nothing
        end
        add_shortcut!(rotate_clockwise, "<shift>d")
        add_action!(edit_submenu, "Rotate clockwise", rotate_clockwise)


        rotate_counterclockwise = Action("rotate_counterclockwise.action", app) do x

            set_mouse_input_blocked!(true)
            
            push!(undo_list, ("rotate", [-1]))
            if length(redo_list) > 0
                task, data = pop!(redo_list)
                if task != "rotate" || data[1] != -1
                    redo_list = Vector()
                end
            end

            G = rotate_collection(G, -1)
            update_displays()
            update_history_strings("rotate", [-1])
        
            set_mouse_input_blocked!(false)
            return nothing
        end
        add_shortcut!(rotate_counterclockwise, "<shift>a")
        add_action!(edit_submenu, "Rotate counterclockwise", rotate_counterclockwise)


        reflect = Action("reflect.action", app) do x

            set_mouse_input_blocked!(true)
            
            push!(undo_list, ("reflect", [1]))
            if length(redo_list) > 0
                task, data = pop!(redo_list)
                if task != "reflect" || data[1] != 1
                    redo_list = Vector()
                end
            end

            G = reflect_collection(G)
            update_displays()
            update_history_strings("reflect", [1])
        
            set_mouse_input_blocked!(false)
            return nothing
        end
        add_shortcut!(reflect, "<shift>s")
        add_action!(edit_submenu, "Reflect", reflect)

        # complement
        complement = Action("complement.action", app) do x    
            set_mouse_input_blocked!(true)
            
            push!(undo_list, ("complement", []))
            if length(redo_list) > 0
                task, data = pop!(redo_list)
                if task != "complement"
                    redo_list = Vector()
                end
            end

            G = complement_collection(G)

            update_embedding_data()
            update_displays()
            update_history_strings("complement", [])

            set_mouse_input_blocked!(false)
            return nothing
        end
        add_action!(edit_submenu, "Complement", complement)

        # swap colors
        swap_colors = Action("swap_colors.action", app) do x    
            set_mouse_input_blocked!(true)

            push!(undo_list, ("swap_colors", []))
            if length(redo_list) > 0
                task, data = pop!(redo_list)
                if task != "swap_colors"
                    redo_list = Vector()
                end
            end

            G = swaped_colors_collection(G)

            update_embedding_data()
            update_displays()
            update_history_strings("swap_colors", [])

            set_mouse_input_blocked!(false)
            return nothing
        end
        add_action!(edit_submenu, "Swap colors", swap_colors)

        ############## view submenu ##############

        function save_view_settings()
            D = Dict(
                "menubar_visible" => get_is_visible(menubar),
                "display_left_visible" => get_is_visible(image_display_left),
                "display_right_visible" => get_is_visible(image_display_right),
                "history_visible" => get_is_visible(history_notebook)
            )
            FileIO.save(bin_path * "view_settings.jld2", D)
        end


        function load_view_settings()
            D = Dict()
            try
                D = FileIO.load(bin_path * "view_settings.jld2")
            catch e
                D = Dict(
                "menubar_visible" => get_is_visible(menubar),
                "display_left_visible" => get_is_visible(image_display_left),
                "display_right_visible" => get_is_visible(image_display_right),
                "history_visible" => get_is_visible(history_notebook)
                )
                FileIO.save(bin_path * "view_settings.jld2", D)
            end

            set_is_visible!(menubar, D["menubar_visible"])
            set_is_visible!(image_display_left, D["display_left_visible"])
            set_is_visible!(image_display_right, D["display_right_visible"])
            set_is_visible!(history_notebook, D["history_visible"])
            set_is_visible!(history_clear_button, D["history_visible"])

            if get_is_visible(image_display_left) && get_is_visible(image_display_right)
                set_ratio!(display_row, 2.0)
            else
                set_ratio!(display_row, 1.0)
            end
        end
        load_view_settings()


        view_menubar = Action("view_menubar.action", app) do x 
            if get_is_visible(menubar)
                set_is_visible!(menubar, false)
            else
                set_is_visible!(menubar, true)
            end

            save_view_settings()
            return nothing
        end
        add_shortcut!(view_menubar, "F9")
        add_action!(view_submenu, "Menubar", view_menubar)


        view_display_left = Action("view_display_left.action", app) do x 
            if get_is_visible(image_display_left)
                set_is_visible!(image_display_left, false)
                set_ratio!(display_row, 1.0)

                if !get_is_visible(image_display_right)
                    set_is_visible!(currently_selected_label, false)
                end
            else
                set_is_visible!(image_display_left, true)
                set_is_visible!(currently_selected_label, true)

                if get_is_visible(image_display_right)
                    set_ratio!(display_row, 2.0)
                end
            end

            save_view_settings()
            return nothing
        end
        add_shortcut!(view_display_left, "F8")
        add_action!(view_submenu, "WS-collection", view_display_left)


        view_display_right = Action("view_display_right.action", app) do x 
            if get_is_visible(image_display_right)
                set_is_visible!(image_display_right, false)
                set_ratio!(display_row, 1.0)

                if !get_is_visible(image_display_left)
                    set_is_visible!(currently_selected_label, false)
                end
            else
                set_is_visible!(image_display_right, true)
                set_is_visible!(currently_selected_label, true)

                if get_is_visible(image_display_left)
                    set_ratio!(display_row, 2.0)
                end
            end

            save_view_settings()
            return nothing
        end
        add_shortcut!(view_display_right, "F7")
        add_action!(view_submenu, "Plabic graph" ,view_display_right)


        view_history = Action("view_history.action", app) do x
            if get_is_visible(history_notebook)
                set_is_visible!(history_notebook, false)
                set_is_visible!(history_clear_button, false)
            else
                set_is_visible!(history_notebook, true)
                set_is_visible!(history_clear_button, true)
            end

            save_view_settings()
            return nothing
        end
        add_shortcut!(view_history, "F6")
        add_action!(view_submenu, "History", view_history)

        ############## settings ##############

        open_settings_window = Action("open_settings_window.action", app) do x 
            set_is_modal!(settings_window, true)
            present!(settings_window)

            return nothing
        end
        set_action!(settings_button, open_settings_window)


        settings_ok = Action("settings_ok.action", app) do x

            set_mouse_input_blocked!(true)

            size = parse(Int64, get_text(display_size_entry))
            set_size_request!(image_display_left, Vector2f(size, size))
            set_size_request!(image_display_right, Vector2f(size, size))
            resolution = parse(Int64, get_text(display_resolution_entry))
            plg_drawmode_item = get_selected(plg_drawmode_dropdown)

            if plg_drawmode_item == plg_drawmode_dropdown_item_1
                plg_drawmode = "straight"
            elseif plg_drawmode_item == plg_drawmode_dropdown_item_2
                plg_drawmode = "smooth"
            else
                plg_drawmode = "polygonal"
            end

            draw_vertex_labels = get_is_active(draw_vertex_labels_check)
            draw_face_labels = get_is_active(draw_face_labels_check)
            highlight_mutables = get_is_active(highlight_mutables_check)
            adjust_angle = get_is_active(adjust_angle_check)
            
            theme_dropdown_item = get_selected(theme_dropdown)
            
            if theme_dropdown_item == theme_dropdown_item_1
                theme = "dark"
                set_current_theme!(app, THEME_DEFAULT_DARK)
            else
                theme = "light"
                set_current_theme!(app, THEME_DEFAULT_LIGHT)
            end

            D = Dict(
                "size" => size,
                "resolution" => resolution,
                "plg_drawmode" => plg_drawmode,
                "draw_vertex_labels" => draw_vertex_labels,
                "draw_face_labels" => draw_face_labels,
                "highlight_mutables" => highlight_mutables,
                "adjust_angle" => adjust_angle,
                "theme" => theme
            )
            FileIO.save(bin_path * "config.jld2", D)

            update_embedding_data()
            update_displays()

            set_is_modal!(settings_window, false)
            close!(settings_window)

            set_mouse_input_blocked!(false)
            return nothing
        end
        set_action!(settings_ok_button, settings_ok)


        settings_cancel = Action("settings_cancel.action", app) do x 
            set_is_modal!(settings_window, false)
            close!(settings_window)
            
            return nothing
        end
        add_shortcut!(settings_cancel, "x")
        set_action!(settings_cancel_button, settings_cancel)


        fallback_size = size
        connect_signal_text_changed!(display_size_entry) do self::Entry
            try 
                fallback_size = parse(Int64, get_text(display_size_entry))
            catch e
                set_text!(display_size_entry, "$fallback_size")
            end
            return nothing
        end


        fallback_resolution = resolution
        connect_signal_text_changed!(display_resolution_entry) do self::Entry
            try 
                fallback_resolution = parse(Int64, get_text(display_resolution_entry))
            catch e
                set_text!(display_resolution_entry, "$fallback_resolution")
            end
            return nothing
        end

        ############## close requests ##############

        connect_signal_close_request!(settings_window) do self::Window
            set_text!(display_size_entry, "$size")
            set_text!(display_resolution_entry, "$resolution")
            fallback_size = size
            fallback_resolution = resolution

            return WINDOW_CLOSE_REQUEST_RESULT_ALLOW_CLOSE
        end


        connect_signal_close_request!(export_window) do self::Window
            set_text!(export_width_entry, "$resolution")
            set_text!(export_height_entry, "$resolution")
            fallback_width = resolution
            fallback_height = resolution

            return WINDOW_CLOSE_REQUEST_RESULT_ALLOW_CLOSE
        end


        connect_signal_close_request!(main_window) do self::Window
            # kill all smaller windows
            destroy!(export_window)
            destroy!(predefined_window)
            destroy!(settings_window)
        
            # close main window (and thus the entire app)
            return WINDOW_CLOSE_REQUEST_RESULT_ALLOW_CLOSE
        end

        # present main window atlast
        present!(main_window)

    end
end

function __init__()
    global bin_path = @get_scratch!("bin")
end

