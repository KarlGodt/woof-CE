[indent=4]

uses
    Gtk
    
    
    
class HtmlViewer

    back_button: ToolButton
    forward_button: ToolButton

    win_button : ToolButton
    close_button : ToolButton
    go_button: ToolButton  
    search_button: ToolButton  
    refresh_button: ToolButton 
    load_button: ToolButton  
    save_button: ToolButton 
    fullscreen_button: ToolButton 
    moz : MozEmbed
    
    toolbox : HBox
    vbox : VBox
    url_entry :  Entry
    topseperator : HSeparator

    current_uri : string
    
    
    gfx_button : ToolButton
    download_button : ToolButton
    embed_button : ToolButton
        
    bookmark_combo : ComboBoxEntry
    bookmarks : list of string
    bookmarknames : list of string
    
    book_add_button : ToolButton
    book_remove_button : ToolButton
    bindex : int
    bookmarklength : int
    
    status : Statusbar
    norefresh : bool
    
    note : Notebook

    cb : CheckButton
    clickmode : bool
    
    isfullscreen : bool
    tempuri : string
    lasttab : int
    pbprofile : string
    
    topev : EventBox
    topev2 : EventBox
    bottomev : EventBox
    bottomev2 : EventBox
    
    //---- profile rc settings --
    always_show_tabs : bool
    show_bookmarks : bool
    show_status : bool
    show_urlbar : bool
    use_tabs : bool
    show_no_bars : bool
    start_fullscreen : bool

    def init(profile:string)
        pbprofile = profile
        create_widgets ()
        connect_signals ()

    def create_widgets () 


        //pbprofile = "default"
        
        
        isfullscreen = false
        always_show_tabs = false
        show_bookmarks=true
        show_status=true
        show_urlbar=true
        use_tabs=true
        show_no_bars=false
        start_fullscreen=false
        
        load_pbprofile(pbprofile)
        
            
        if show_no_bars is true
            use_tabs = false
            show_status = false

        if use_tabs is false
            always_show_tabs = false


        
        norefresh = true
        
        lasttab = 0
        tempuri = ""

        //-- this rc files removes shadows from the toolbars, so they look as one --
        rc_parse ("theme.rc")

        //-- this box holds all bars --
        toolbox = new HBox(false , 0)
        toolbox.spacing = 0


        //-- create 4 toolbars, so that the contents expand when window is huge  -- 
        
        //-- navigation toolbar --
               
        var toolbar_left = new Toolbar ()
        toolbar_left.show_arrow = false
        toolbar_left.icon_size = IconSize.SMALL_TOOLBAR
        toolbar_left.set_style(ToolbarStyle.ICONS)
               

        back_button = new ToolButton.from_stock (STOCK_GO_BACK)
        toolbar_left.add (back_button) 
        back_button.set_tooltip_text("back")
        
        forward_button = new ToolButton.from_stock (STOCK_GO_FORWARD)
        toolbar_left.add (forward_button)
        forward_button.set_tooltip_text("forward")
        
        refresh_button = new ToolButton.from_stock (STOCK_REFRESH)
        toolbar_left.add (refresh_button)
        refresh_button.set_tooltip_text("refresh")
        
        back_button.sensitive = false
        forward_button.sensitive = false


        //-- some buttons to download files --
        
        var toolbar_tools = new Toolbar ()
        toolbar_tools.show_arrow = false
        toolbar_tools.icon_size = IconSize.SMALL_TOOLBAR
        toolbar_tools.set_style(ToolbarStyle.ICONS)

        var tool_item_tools = new ToolItem()
        toolbar_tools.add (tool_item_tools)
        var emptylabel = new Label("    ")
        tool_item_tools.add(emptylabel)


        toolbox.pack_start (toolbar_left , false , false , 0) 
        toolbox.pack_start (toolbar_tools , true , true , 0) 
        
        
        //-- bookmark buttons and combo --


        if show_bookmarks is true

            var toolbar_middle = new Toolbar ()
                
            toolbar_middle.show_arrow = false
            toolbar_middle.icon_size = IconSize.SMALL_TOOLBAR
            toolbar_middle.set_style(ToolbarStyle.ICONS)
    
    
            book_remove_button = new ToolButton.from_stock (STOCK_REMOVE)
            toolbar_middle.add (book_remove_button)
            book_remove_button.set_tooltip_text("DELETE currently selected bookmark")
        
        
            bookmarks_create()
            var tool_item_combo = new ToolItem()
            toolbar_middle.add (tool_item_combo)
            tool_item_combo.add (bookmark_combo)
        
        
            book_add_button = new ToolButton.from_stock (STOCK_ADD)
            toolbar_middle.add (book_add_button)
            book_add_button.set_tooltip_text("add current page as bookmark")
                   
            toolbox.pack_start (toolbar_middle , true , true , 0)  

        //-- toolbar for URL entry and buttons --
                      
        var toolbar_right = new Toolbar ()
        toolbar_right.show_arrow = false        
        toolbar_right.icon_size = IconSize.SMALL_TOOLBAR
        toolbar_right.set_style(ToolbarStyle.ICONS)           
           
           

        var tool_item_entry = new ToolItem()
        toolbar_right.add (tool_item_entry)
        
        url_entry = new Entry()
        url_entry.set_size_request(300 , -1)
        tool_item_entry.add(url_entry)


        go_button = new ToolButton.from_stock (STOCK_OK)
        toolbar_right.add (go_button)
        go_button.set_tooltip_text("go")

        search_button = new ToolButton.from_stock (STOCK_FIND)
        toolbar_right.add (search_button)
        search_button.set_tooltip_text("search text that was entered in the left entry")
        

        // dragn drop definitions
        entry1 : array of TargetEntry
        entry1 = TargetEntry[0]
        var dlist = new Gtk.TargetList(entry1)
        dlist.add_uri_targets(0)
        dlist.add_text_targets(0)
               
        if use_tabs is true        

            var si0 = new SeparatorToolItem()
            toolbar_right.add (si0)

            win_button = new ToolButton.from_stock (STOCK_JUSTIFY_LEFT)
            toolbar_right.add (win_button)
            win_button.set_tooltip_text("open current page in new tab")

            /* setup window as drag dest */
            Gtk.drag_dest_set(win_button, Gtk.DestDefaults.ALL,entry1, Gdk.DragAction.MOVE | Gdk.DragAction.COPY);
            Gtk.drag_dest_set_target_list(win_button, dlist);
            win_button.drag_data_received += win_button_drop
 
 
            close_button = new ToolButton.from_stock (STOCK_CLOSE)
            toolbar_right.add (close_button)
            close_button.set_tooltip_text("close current tab")

        //-- pack all bars and gecko in the final layout --
        

        if show_urlbar is true
            toolbox.pack_end (toolbar_right , false , false , 0)          
        
        vbox = new VBox (false, 0)
        vbox.spacing = 0
        vbox.border_width = 0
        

        topev = new EventBox()
        vbox.pack_start(topev , false , false , 0)
        topev.set_size_request(-1,0)

        
        if show_no_bars is false
            vbox.pack_start(toolbox , false , false , 0)
        
        topev2 = new EventBox()
        vbox.pack_start(topev2 , false , false , 0)
        topev2.set_size_request(-1,0)        
        
        topseperator = new HSeparator ()
        if show_no_bars is false
            
            vbox.pack_start(topseperator , false , false , 0)
        

        moz = new MozEmbed ()
        //var wmoz = (Widget)moz

        
        moz.location += location        
        moz.link_message += link
        moz.new_window += new_window
        
        //-- :-( moz catches clicks :-(
        /*
        moz.dom_mouse_down += on_moz_dom_mouse_down
        moz.dom_mouse_up += on_moz_dom_mouse_up
        moz.dom_activate += open_uri
        */
        
        //moz.dom_mouse_out += on_moz_dom_mouse_out
        
        //moz.dom_mouse_click += on_moz_dom_mouse_up
                
        //wmoz.button_release_event += on_moz_button_release_event
        //Signal.connect_after (moz, "button_release_event", moz_button_release_event, null)
        
        //Signal.connect_after (this.moz, "dom_mouse_up", moz_button_release_event, null)
        
        note = new Notebook()
        note.popup_enable ()
        note.set_show_border(false)
        note.set_scrollable(true)
        if always_show_tabs is false
            note.set_show_tabs(false)
        else
            note.set_show_tabs(true)

        note.append_page(moz , null)

        vbox.add (note)


        //-- STATUSBAR --
        
        status  = new Statusbar()
        
        var sbox = new HBox (false, 0)
        sbox.spacing = 0
        sbox.border_width = 0 
        status.pack_start(sbox , false , false , 0)
        
        var toolbar_status = new Toolbar ()
        toolbar_status.show_arrow = false
        toolbar_status.icon_size = IconSize.SMALL_TOOLBAR
        toolbar_status.set_style(ToolbarStyle.ICONS)
        
        sbox.pack_start(toolbar_status , false , false , 0)        

        fullscreen_button = new ToolButton.from_stock (STOCK_FULLSCREEN)
        toolbar_status.add (fullscreen_button)
        fullscreen_button.set_tooltip_text("toggle fullscreen")        

        var si1 = new SeparatorToolItem()
        toolbar_status.add (si1)

        embed_button = new ToolButton.from_stock (STOCK_INDENT)
        toolbar_status.add (embed_button)
        embed_button.set_tooltip_text("Open bookmarks for embedded code")
          
        var si3 = new SeparatorToolItem()
        toolbar_status.add (si3)
        
        gfx_button = new ToolButton.from_stock (STOCK_DND)
        toolbar_status.add (gfx_button)
        gfx_button.set_tooltip_text("run pictureviewer to drop images or PDF documents")

        Gtk.drag_dest_set(gfx_button, Gtk.DestDefaults.ALL,entry1, Gdk.DragAction.MOVE | Gdk.DragAction.COPY);
        Gtk.drag_dest_set_target_list(gfx_button, dlist);
        gfx_button.drag_data_received += gfx_button_drop

        download_button = new ToolButton.from_stock (STOCK_FLOPPY)
        toolbar_status.add (download_button)
        download_button.set_tooltip_text("run /usr/local/PuppyBrowser/pwsget to drop files for download")

        Gtk.drag_dest_set(download_button, Gtk.DestDefaults.ALL,entry1, Gdk.DragAction.MOVE | Gdk.DragAction.COPY);
        Gtk.drag_dest_set_target_list(download_button, dlist);
        download_button.drag_data_received += download_button_drop        
        
        if use_tabs is true

            var si2 = new SeparatorToolItem()
            toolbar_status.add (si2)

            load_button = new ToolButton.from_stock (STOCK_OPEN)
            toolbar_status.add (load_button)
            load_button.set_tooltip_text("load tabs")
        
                
            save_button = new ToolButton.from_stock (STOCK_SAVE)
            toolbar_status.add (save_button)
            save_button.set_tooltip_text("save current tabs")   
        
        var tool_item_status = new ToolItem()
        toolbar_status.add (tool_item_status)
        var emptylabel2 = new Label("    ")
        tool_item_status.add(emptylabel2)
        
        bottomev2 = new EventBox()
        vbox.pack_start(bottomev2 , false , false , 0)
        bottomev2.set_size_request(-1,0)
        
        if show_status is true
            vbox.pack_start(status, false,false,0)
        
        
        bottomev = new EventBox()
        vbox.pack_start(bottomev , false , false , 0)
        bottomev.set_size_request(-1,0)
        
        vbox.show_all()
        
        topev.hide()
        topev2.hide()
        bottomev.hide()
        bottomev2.hide()  
            
        if start_fullscreen is true
            fullscreen()
            
        


    def connect_signals () : void


        topev.enter_notify_event += showtoolbox
        
        bottomev.enter_notify_event += showstatus

        topev2.enter_notify_event += hidetoolbox
        bottomev2.enter_notify_event += hidestatus
        
        //cb.toggled += cb_toggled

        back_button.clicked += go_back
        forward_button.clicked += go_forward
        url_entry.activate += goto_url
        url_entry.button_release_event += entry_clicked
        
        go_button.clicked += goto_url
        search_button.clicked += search
        refresh_button.clicked += refresh 

        if use_tabs is true
            load_button.clicked += load_tabs        
            save_button.clicked += save_tabs
            win_button.clicked += new_tab
            
            close_button.clicked += close_tab    

        fullscreen_button.clicked += fullscreen
            
        gfx_button.clicked += gfx
        download_button.clicked += download
        embed_button.clicked += embed
                
        if show_bookmarks is true
            bookmark_combo.changed += bookmark_box_changed
            book_add_button.clicked  += add_bookmark
            book_remove_button.clicked  += remove_bookmark

        if use_tabs is true
            note.switch_page += note_page_changed

    def win_button_drop(d : Gdk.DragContext , x : int, y : int , sel : Gtk.SelectionData, info : uint , timestamp : uint) 


        //-- manage drag n drop --
    
        var uriustring =  (string) sel.data
        var uri = uriustring.split("\n")[0].strip()

        //print("%s" , uri)
        new_tab_with_url(uri)

        return

    def load_pbprofile(theprofile: string)
    
        //print "loading profile"

        var rchome = Environment.get_home_dir() + "/.PuppyBrowser"   
        DirUtils.create(rchome  +  "/profiles/" , 0700)     
        DirUtils.create(rchome  +  "/profiles/" + theprofile , 0700)  
            
        f:FileStream
        var c=1
        if (f = FileStream.open( rchome  +  "/profiles/" + theprofile + "/settings.rc" , "r")) is not null

            var a = new array of char[10240]
            while f.gets(a) is not null     /*read one line from file*/
                a[a.length - 1] = 0         /*make it null-terminated*/
                var s = (string)a           /*caste array-of-char to a string*/
                s.strip()
                if s.has_prefix("#") == true do continue
                if s is not ""
                    //print ("%s" , s)
                    get_rc_setting(s)
                    c++



    def get_rc_setting(s:string)
        
        var s2 = s.split("=",2)
        var a = s2[0].strip()
        var b = s2[1].strip()
        
        if a is "always_show_tabs" 
            always_show_tabs = string_to_bool(b)
            return
            
        if a is "show_bookmarks" 
            show_bookmarks = string_to_bool(b)
            return     
            
        if a is "use_tabs" 
            use_tabs = string_to_bool(b)
            return          
            
        if a is "show_status" 
            show_status = string_to_bool(b)
            return                 
            

        if a is "show_urlbar" 
            show_urlbar = string_to_bool(b)
            return       

        if a is "show_no_bars" 
            show_no_bars = string_to_bool(b)
            return       


        if a is "start_fullscreen" 
            start_fullscreen = string_to_bool(b)
            return      



    def string_to_bool(s:string): bool
    
        
        if s is "1"
            return true
    
        return false

    def fullscreen()
    
        if isfullscreen is true
            isfullscreen = false
            window1.unfullscreen()
            toolbox.show()
            topseperator.show()
            status.show()
            topev.hide()
            topev2.hide()
            bottomev.hide()
            bottomev2.hide()            
            
            return
        isfullscreen = true
        window1.fullscreen()
        toolbox.hide()
        topseperator.hide()
        status.hide()
        topev.show()
        topev2.show()
        bottomev.show()
        bottomev2.show()  
            
                    
    //unused
    def cb_toggled()
    
        if clickmode is true
            clickmode = false
            return
        
        clickmode = true

    def new_window()
    
        /*
        var index = note.get_current_page()
        var themoz = (MozEmbed)note.get_nth_page (index)
        var l=themoz.get_link_message()
        print ("%s" , l) 
        load(l)
        */


        var index = note.get_current_page()
        var themoz = (MozEmbed)note.get_nth_page (index)
        var l=themoz.get_link_message() 
        
        if l.len() > 9
            var ok=false
            if l.substring(0,10) is "javascript"
                if l.contains("window")
                    ok = true
                if l.contains("location")
                    ok = true
                if ok is false
                    status.push(1 , "info: javascript generated popups are unsupported!") 
                    return  
                   
        if l is not ""
            if use_tabs is true
                new_tab_with_url(l)
            else
                load(l)
            
    def link()
    
        var index = note.get_current_page()
        var themoz = (MozEmbed)note.get_nth_page (index)
        var l=themoz.get_link_message()
        //print ("%s" , l) 
        status.push(1,l)
        
    def load(uri : string)

        var index = note.get_current_page()

        var themoz = (MozEmbed)note.get_nth_page (index)
        url_entry.set_text(uri)
        themoz.load_url(uri)
        url_entry.set_text(uri)


    def goto_url()

        var index = note.get_current_page()
        var themoz = (MozEmbed)note.get_nth_page (index)
        current_uri = url_entry.get_text()
        themoz.load_url(current_uri)

        
    def refresh()
        var index = note.get_current_page()
        var themoz = (MozEmbed)note.get_nth_page (index)    
        themoz.reload(MozEmbedReloadFlags.RELOADNORMAL)


    //-- this runs, every time a new location was loaded --
    
    def location()
    
    

    
        var index = note.get_current_page()
        var themoz = (MozEmbed)note.get_nth_page (index)
        current_uri = themoz.get_location()




        url_entry.set_text(current_uri)
        
        //var w = note.get_menu_label(themoz)
        //w.set_tooltip_text(current_uri)
        
        var thetext = current_uri
        //print("--- %s" , thetext)
        
        try
            var r = new Regex (".*://")

            thetext = r.replace(current_uri,current_uri.len() , 0, "")
            thetext = thetext.replace("www." , "") 

            r = new Regex ("/$")
            thetext = r.replace(thetext,thetext.len() , 0, "")

            note.set_menu_label_text(themoz , thetext)

            r = new Regex ("\\.[^.]*$")
            thetext = r.replace(thetext,thetext.len() , 0, "")
        except ex : Error
            note.set_menu_label_text(themoz , thetext)

        
        if thetext.len() > 10
            thetext = thetext.substring(0,10) + "..."

        note.set_tab_label_text(themoz , thetext)

                
        back_button.sensitive = themoz.can_go_back ()
        forward_button.sensitive = themoz.can_go_forward ()
                

    def go_back()
    
        var index = note.get_current_page()
        var themoz = (MozEmbed)note.get_nth_page (index)
        themoz.go_back()

        back_button.sensitive = themoz.can_go_back ()
        forward_button.sensitive = themoz.can_go_forward ()
        
        current_uri = themoz.get_location()
        url_entry.set_text(current_uri) 
        
        
    def go_forward()
    
        var index = note.get_current_page()
        var themoz = (MozEmbed)note.get_nth_page (index)
        themoz.go_forward()

        back_button.sensitive = themoz.can_go_back ()
        forward_button.sensitive = themoz.can_go_forward ()
        
        current_uri = themoz.get_location()
        url_entry.set_text(current_uri)    
           

    //==select all text on click in the URL-bar --
       
    def entry_clicked():bool
    
        start : int
        end : int
        start = 0
        end = 0
        var result = url_entry.get_selection_bounds( start ,  end)
        if result is false
            url_entry.select_region( 0 , -1 )
        return false
    
    
    def search()
        var searchstring = url_entry.get_text()
        if searchstring is ""
            load("http://www.google.com")
            return
        load("http://www.google.com/search?q=" + searchstring)


    //unused
    def moz_button_release_event()

        //var button = (int) eventbutton.button
        print("ok")

    //unused
    //def on_moz_dom_mouse_down(eventbutton : Gdk.EventButton)
    
    def open_uri()
        tempuri = ""
        print "------------"
    

    def hidetoolbox() : bool
    
        toolbox.hide()
        topseperator.hide()
        topev2.hide()
        topev.show()
        return false

    def hidestatus() : bool
    
        status.hide()
        bottomev2.hide()
        bottomev.show()        
        return false

    def showtoolbox():bool

        toolbox.show()
        topseperator.show()
        topev.hide()
        topev2.show()        
        return false

    def showstatus():bool

        status.show()
        bottomev.hide()
        bottomev2.show() 
        return false
        
    def on_moz_dom_mouse_out(moz: MozEmbed , b : int)
    
    
        //if isfullscreen is false
        //    return
            
        //print "out"
        x:int
        y:int
        
        w: Gdk.Window
        sc : Gdk.Screen
        sc = Gdk.Screen.get_default()
        w = sc.get_root_window()
        w.get_pointer(out x,out y,null)
        print("%d" , y)
        
        if y > 0
            toolbox.hide()
            status.hide()
            if y >(sc.get_height() -20)
                status.show()
            return
            
        toolbox.show()
        
        
    
    def on_moz_dom_mouse_up(moz: MozEmbed , b : int)

        
        print("--%d" , b)
        
        var index = note.get_current_page()
        var themoz = (MozEmbed)note.get_nth_page (index)
        //var uri = themoz.get_location()

        //Thread.usleep(1000000)
        var l=themoz.get_link_message()
    
        if tempuri is ""
            return
    
        if tempuri is l
            print "aha" 
    
       
       

    
    def on_moz_dom_mouse_down(moz: MozEmbed , b : int)

        

        //print("%d" , b)


        var index = note.get_current_page()
        var themoz = (MozEmbed)note.get_nth_page (index)
        var uri = themoz.get_location()

        var l=themoz.get_link_message()

        tempuri = l
        if l is ""
            return
            
        if l is uri
            return
            
        //print("%s" , l)

        return 


    

         
    //-- run external helper applications --
    
    def gfx()
        exec ("/usr/local/Pictureviewer/Pictureviewer")

    def gfx_button_drop(d : Gdk.DragContext , x : int, y : int , sel : Gtk.SelectionData, info : uint , timestamp : uint) 
    
        //-- manage drag n drop --
    
        var uriustring =  (string) sel.data
        var uri = uriustring.split("\n")[0].strip()

        //print("%s" , uri)
        exec ("/usr/local/Pictureviewer/Pictureviewer " + uri)

        return

    def embed()
        exec ("/usr/local/EmbeddedBookmarks/embedded-bookmarks")
        
    def download()
        exec ("/usr/local/PuppyBrowser/pwsget")

    def download_button_drop(d : Gdk.DragContext , x : int, y : int , sel : Gtk.SelectionData, info : uint , timestamp : uint) 
    
        //-- manage drag n drop --
    
        var uriustring =  (string) sel.data
        var uri = uriustring.split("\n")[0].strip()

        try
            FileUtils.set_contents("/tmp/pm_source_dir" , "echo -n " + uri)
            FileUtils.chmod("/tmp/pm_source_dir" , 0555)
        except ex : FileError
            print ("%s" , "save error")    

        //print("%s" , uri)
        exec ("/usr/local/PuppyBrowser/pwsget " + uri)

        return
        
    def exec(thecmd : string)
        try
            Process.spawn_command_line_async(thecmd)
        except ex : GLib.Error
            print("%s", "exec failed!")
            status.push(1 , "exec failed!")
        return

    //--------- TABS -------------------------      
    
    def new_tab()
        note.set_show_tabs(true)
        var newmoz = new MozEmbed ()  
        var a = note.append_page(newmoz, null)
        newmoz.show()
        //print("--%d" ,a)

        norefresh = true
        note.set_current_page (a)
        norefresh = false
        load(current_uri)

        newmoz.location += location        
        newmoz.link_message += link
        newmoz.new_window += new_window
        bookmark_combo.set_active(0)


    def new_tab_with_url(url : string)
        note.set_show_tabs(true)
        var newmoz = new MozEmbed ()  
        var a = note.append_page(newmoz, null)
        newmoz.show()
        //print("--%d" ,a)

        norefresh = true
        note.set_current_page (a)
        norefresh = false
        load(url)
        print("%s" , url)

        newmoz.location += location        
        newmoz.link_message += link
        newmoz.new_window += new_window        
        bookmark_combo.set_active(0)

    def close_tab()
        
        var index = note.get_current_page()
        if index < 1
            return
            

        note.set_current_page (lasttab)

            
        //print("remove: %d" ,index)
        var themoz = (MozEmbed)note.get_nth_page (index)
        themoz.destroy()
        
        //note.remove_page(index)

        var n = note.get_n_pages () -1
        
        if always_show_tabs is false
            if n is 0
                note.set_show_tabs(false)
            
            


    def note_page_changed(notebook : void*, pageindex : uint)
    
        bookmark_combo.set_active(0)    
        lasttab = note.get_current_page ()
        //print("-- %d" ,lasttab)
        if norefresh is true
            return

        var index = (int)pageindex
        //print("%d" ,index)
    
    
    
        if index < 0
            return
    
        var themoz = (MozEmbed)note.get_nth_page (index)
        current_uri = themoz.get_location()
        url_entry.set_text(current_uri)
        back_button.sensitive = themoz.can_go_back ()
        forward_button.sensitive = themoz.can_go_forward ()
    
        return

    def load_tabs()

        var n = note.get_n_pages () -1
        for var i = 1 to n
            note.set_current_page (1)
            close_tab()

        var rchome = Environment.get_home_dir() + "/.PuppyBrowser"            
        f:FileStream
        var c=1
        if (f = FileStream.open( rchome +  "/profiles/" + pbprofile  +  "/tabs.rc" , "r")) is not null

            var a = new array of char[10240]
            while f.gets(a) is not null     /*read one line from file*/
                a[a.length - 1] = 0         /*make it null-terminated*/
                var s = (string)a           /*caste array-of-char to a string*/
                s.strip()
                if s.has_prefix("#") == true do continue
                if s is not ""
                    new_tab_with_url(s)
                    //-- timing stuff, must add titles afterwards --
                    set_tab_text(c,s)
                    c++
            n = note.get_n_pages () -1
            
            if n > 0
            
                note.set_current_page (0)
                var themoz = (MozEmbed)note.get_nth_page (0)
                themoz.destroy()
              
                
                
    def set_tab_text(index : int , s : string)
              
        var themoz = (MozEmbed)note.get_nth_page (index)

        var thetext = s
        //print("--- %s" , thetext)
        
        try
            var r = new Regex (".*://")

            thetext = r.replace(s,s.len() , 0, "")
            thetext = thetext.replace("www." , "") 

            r = new Regex ("/$")
            thetext = r.replace(thetext,thetext.len() , 0, "")

            note.set_menu_label_text(themoz , thetext)

            r = new Regex ("\\.[^.]*$")
            thetext = r.replace(thetext,thetext.len() , 0, "")
        except ex : Error
            note.set_menu_label_text(themoz , thetext)

        
        if thetext.len() > 10
            thetext = thetext.substring(0,10) + "..."

        note.set_tab_label_text(themoz , thetext)  
                
                
    def save_tabs()
    
        var msg = "WARNING!\n overwrite previously saved tabs?"
        var messagedialog = new Gtk.MessageDialog (window1, Gtk.DialogFlags.DESTROY_WITH_PARENT | Gtk.DialogFlags.MODAL, Gtk.MessageType.QUESTION, Gtk.ButtonsType.YES_NO, (msg)) 
        var result = messagedialog.run() 
        messagedialog.destroy()
        //print("%d" , result)
    
        if result is not Gtk.ResponseType.YES
            return
    
        var a = note.get_n_pages () -1
        var theuri = ""
        
        var savestring = ""
        for var i = 0 to a
            var themoz = (MozEmbed)note.get_nth_page (i)
            theuri = themoz.get_location()
            //print("%s" , theuri)
            savestring += theuri + "\n"
            
  
        var rchome = Environment.get_home_dir() + "/.PuppyBrowser"
        DirUtils.create(rchome , 0700)
        
        try
            FileUtils.set_contents(rchome +  "/profiles/" + pbprofile  +  "/tabs.rc" , savestring)
            status.push(1 , "saved tabs!")
        except ex : FileError
            print ("%s" , "save error")   
            status.push(1 , "save error!")      
    
    

    //--------- BOOKMARKS -------------------------

    
    def bookmark_box_changed()

        
        var index = bookmark_combo.get_active()
        var text = bookmark_combo.get_active_text() 
        
        //print ("%s    %d    %d" , text,index , bindex)
                

        //-- here I handle, when text in the bookmark combo is modified --
        
        if index > -1
            bindex = index

        if bindex <1
            return
                    
        var mindex = note.get_current_page()
        var themoz = (MozEmbed)note.get_nth_page (mindex)
                           
        if themoz.get_location() is bookmarks[bindex]
            //print "ok1"
            if text is not bookmarknames[bindex]
                //print "ok"
                bookmarknames[bindex] = text
                bookmark_combo.remove_text(bindex)
                bookmark_combo.insert_text( bindex , text )
                save_bookmarks()
            return
        
        if index <1
            return
        
        
        //-- if the text did not change, it was selected, so load bookmark url --
        //bookmark_combo.set_active(0)
        load(bookmarks[index])        
        


    def add_bookmark()

    
        var bm = current_uri.replace("http://www." , "").replace("http://","")
        if bm.substring(-1,1) is "/"
            bm = bm.substring(0,bm.length-1)

    
        for b in bookmarks
            if b is current_uri
                return
            
        bookmarks.add(current_uri)        
        bookmark_combo.append_text(bm)
        bookmarknames.add(bm)
        save_bookmarks()
        status.push(1 , "added bookmark!")
        bookmark_combo.set_active(bookmarklength)


    def remove_bookmark()
    
        var i = bookmark_combo.get_active()
        if i is 0
            return
        bookmark_combo.set_active(0)
        bookmarknames.remove_at(i) 
        bookmarks.remove_at(i)         
        bookmark_combo.remove_text(i)

        
        save_bookmarks()
        status.push(1 , "deleted bookmark!")     

    def save_bookmarks()
    
        var savestring = ""
        var count = 0
        for b in bookmarks
            if count > 0
                savestring += bookmarknames[count]  + "|" + b + "\n"
            
            count ++
        
        bookmarklength = count -1    
        var rchome = Environment.get_home_dir() + "/.PuppyBrowser"
        DirUtils.create(rchome , 0700)
        
        try
            FileUtils.set_contents(rchome +  "/profiles/" + pbprofile  +  "/bookmarks.rc" , savestring)
            status.push(1 , "saved bookmarks!") 
        except ex : FileError
            print ("%s" , "save error")        
            status.push(1 , "save error!") 

    
    def bookmarks_create()
    
        bookmarks = new list of string
        bookmarknames = new list of string
        bookmark_combo = new ComboBoxEntry.text ()
                
        bookmarks.add("test")
        bookmarknames.add("Bookmarks")
        bookmark_combo.append_text("Bookmarks")
        bookmark_combo.set_active(0)

        load_bookmarks()

        
    def load_bookmarks()
    
        var rchome = Environment.get_home_dir() + "/.PuppyBrowser"
        DirUtils.create(rchome , 0700)
        bookmarkstext : string
        bookmarkstext = ""
 
        
        var count = 0
        f:FileStream
        if (f = FileStream.open( rchome +  "/profiles/" + pbprofile  +  "/bookmarks.rc" , "r")) is not null

            var a = new array of char[10240]
            while f.gets(a) is not null     /*read one line from file*/
                a[a.length - 1] = 0         /*make it null-terminated*/
                var s = (string)a           /*caste array-of-char to a string*/
                s.strip()
                if s.has_prefix("#") == true do continue
                var s2 = s.split("|",2)     /*returns array of string*/
                bookmarks.add ( s2[1])      /*add to dictionary*/
                bookmark_combo.append_text(s2[0])
                bookmarknames.add ( s2[0])
                count ++
        
        if count is 0
            bookmarks.add ( "file:///usr/share/doc/home.htm" )
            bookmark_combo.append_text( "welcome" )
            bookmarknames.add( "welcome" )
            bookmarks.add ( "puppylinux.com" )
            bookmark_combo.append_text( "puppylinux.com" )        
            bookmarknames.add( "puppylinux.com" )            
            bookmarks.add ( "puppylinux.org" )
            bookmark_combo.append_text( "puppylinux.org" )
            bookmarknames.add( "puppylinux.org" )            
            bookmarks.add ( "http://wellminded.com/puppy/pupsearch.html" )
            bookmark_combo.append_text( "puppy search" )
            bookmarknames.add( "puppy search" )            
            bookmarks.add ( "dotpups.de" )
            bookmark_combo.append_text( "packages" )
            bookmarknames.add( "packages" )
        
        
        