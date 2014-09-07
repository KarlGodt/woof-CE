[indent=4]

uses
    Gtk

class Picviewclass    
    
    pixbuf : Gdk.Pixbuf
    pixbufsuccess : bool
    rotation : int
    vbox : VBox
    cbscale : CheckButton
    hbox_toolbuttons : HBox

    hbox_runbuttons : HBox
    hbox_runbuttons_pdf : HBox
    
    hbox_pagebuttons : HBox
    hbox_top : HBox
    hbox_bottom : HBox
    
    pagecb : ComboBox

    zoomspin : SpinButton
    image : Image
    scrolledwindow : ScrolledWindow

    eventbox : EventBox
    vp : Viewport
    run_button_array : array of string
    run_button_counter : int
    filename : Entry

    current_file : string
    zoomfactor : double
    
    haspages : bool
    ispdf : bool
    
    document : Poppler.Document
    pdfindex : int

    forcescale : bool
    
    last_h : int
    last_w : int
    
    pdfx : int
    pdfy : int
    pdfscale : double
    pdfscalecorrect : double
    pdfpages : int
    windows : bool

    
    def init()
    

        pdfx = 800
        pdfy = 800
        pdfscale = 2
        pdfscalecorrect = 1
        
        //-- in windows, poppler scales erratic ---
        windows = false
            if Environment.get_tmp_dir().contains("\\")
                windows = true
                pdfscalecorrect = pdfscale
                
        filename = new Entry()

        
        run_button_array = new array of string [20]
        run_button_counter = 0
        
        
        vbox = new VBox(false , 1)
        vbox.spacing = 5
        
        hbox_top = new HBox(true , 1) 
        vbox.pack_start (hbox_top, false, true, 0)
        hbox_top.spacing = 10
        
        
        scrolledwindow = new ScrolledWindow(null , null)
        scrolledwindow.set_policy(Gtk.PolicyType.AUTOMATIC , Gtk.PolicyType.AUTOMATIC )
        scrolledwindow.set_shadow_type(Gtk.ShadowType.NONE)
        
        vbox.pack_start (scrolledwindow, true, true, 0)
        eventbox = new EventBox()
        scrolledwindow.add_with_viewport(eventbox)
        

        
        var widget = (Widget) eventbox
        var parent = widget.get_parent()
        var ev = (Viewport) parent
        ev.set_shadow_type(Gtk.ShadowType.NONE)
        image = new Image()
        eventbox.add(image)

        
        hbox_bottom = new HBox(true , 1)          
        vbox.pack_start (hbox_bottom, false, true, 0)
        hbox_bottom.spacing = 10
        
        hbox_pagebuttons = new HBox(false , 1)
        hbox_pagebuttons.spacing = 5
        hbox_top.pack_start(hbox_pagebuttons , false , true , 0)        
        
        pagecb = new ComboBox.text()
        hbox_pagebuttons.pack_start(pagecb , true, true, 0)
        pagecb.changed += page_select
        
        var prevpage = new Button.with_label("<")
        hbox_pagebuttons.pack_start(prevpage , true, true, 0)
        prevpage.clicked += previous_page        
        

        var nextpage = new Button.with_label(">")
        hbox_pagebuttons.pack_start(nextpage , true, true, 0)
        nextpage.clicked += next_page     

        var textpage = new Button.with_label("Text")
        hbox_pagebuttons.pack_start(textpage , true, true, 0)
        textpage.clicked += text_page     

        var alltextpage = new Button.with_label("all Text")
        hbox_pagebuttons.pack_start(alltextpage , true, true, 0)
        alltextpage.clicked += alltext_page        
        
        hbox_toolbuttons = new HBox(false , 1)
        hbox_toolbuttons.spacing = 5
        hbox_top.pack_start(hbox_toolbuttons , false , true , 0)

        hbox_runbuttons_pdf = new HBox(false , 1) 
        hbox_runbuttons_pdf.spacing = 5        
        hbox_bottom.pack_start(hbox_runbuttons_pdf , false , true , 0)
        
        hbox_runbuttons = new HBox(false , 1) 
        hbox_runbuttons.spacing = 5        
        hbox_bottom.pack_start(hbox_runbuttons , false , true , 0)
        

        
        var rotate1 = new Button.with_label("-90°")
        hbox_toolbuttons.pack_start(rotate1 , true, true, 0)
        rotate1.clicked += rotate_left

        var rotate0 = new Button.with_label("0°")
        hbox_toolbuttons.pack_start(rotate0 , true, true, 0)
        rotate0.clicked += rotate_none
        
        var rotate2 = new Button.with_label("+90°") 
        hbox_toolbuttons.pack_start(rotate2 , true, true, 0)        
        rotate2.clicked += rotate_right        
        
        zoomspin = new SpinButton.with_range(50, 1000,50)
        zoomspin.set_value(100)
        hbox_toolbuttons.pack_start(zoomspin , true, true, 0)

        zoomspin.value_changed += zoom 
        
        cbscale = new CheckButton()
        cbscale.set_label("scale")
        cbscale.set_active(true)
        hbox_toolbuttons.pack_start(cbscale , false, false, 0)
        cbscale.clicked += cbscaletoggle 


        //eventbox.drag_dest_set()

        /* setup window as drag dest */
        entry : array of TargetEntry
        entry = TargetEntry[0]
        //entry[1].flags = 0
        
        //target_entry : TargetEntry
        //target_entry : array of TargetEntry = { "text/uri-list" , 1 } 
        var dlist = new Gtk.TargetList(entry)
        dlist.add_uri_targets(0)
        dlist.add_text_targets(0)

        Gtk.drag_dest_set(eventbox, Gtk.DestDefaults.ALL,entry, Gdk.DragAction.MOVE | Gdk.DragAction.COPY);



        //Gtk.drag_dest_set(eventbox, Gtk.DestDefaults.ALL, entry, Gdk.DragAction.DEFAULT | Gdk.DragAction.COPY);
        Gtk.drag_dest_set_target_list(eventbox, dlist);


        //target_entry : TargetEntry
        //target_entry[3]
        
        vbox.show_all()
        last_h = 0
        last_w = 0
        pdfpages = 0
        
        return 
    
    def add_run_button(title : string , action : string)
    
        var b = new Button.with_label(title) 
        b.button_release_event += run_program 
        
        run_button_array [run_button_counter] = action
        b.name = "runbutton_" + run_button_counter.to_string()
        run_button_counter++
        hbox_runbuttons.pack_start (b, true, true, 0)
        b.show()

    
        return
        
    def add_run_button_pdf(title : string , action : string)
    
        var b = new Button.with_label(title) 
        b.button_release_event += run_pdf_program 
        
        run_button_array [run_button_counter] = action
        b.name = "runbutton_" + run_button_counter.to_string()
        run_button_counter++
        hbox_runbuttons_pdf.pack_start (b, true, true, 0)
        b.show()
    
        return

    def run_pdf_program(b : Button , eventbutton : Gdk.EventButton) : bool

        var name = b.name
        var a = name.split("_")

        
        thecmd : string
        thecmd = run_button_array[a[1].to_int()] + " \"" + current_file + "\""
        gfxfile : string
        gfxfile = tempdir() + "/TEMP-output.png"

        thecmd = correct_path_delimter(thecmd)
        print("%s" , thecmd)        
        try
            Process.spawn_command_line_async(thecmd)
        except ex : GLib.Error
            print("%s", "exec failed!")

    
        return false
 
        
    def run_program(b : Button , eventbutton : Gdk.EventButton) : bool

        var name = b.name
        var a = name.split("_")

        
        thecmd : string
        thecmd = run_button_array[a[1].to_int()] + " \"" + current_file + "\""
        gfxfile : string
        gfxfile = tempdir() + "/TEMP-output.png"
        if ispdf

            try
                //-- we rotate before exporting the pdf page --
                pixbufcopy : Gdk.Pixbuf

                pixbufcopy = pixbuf

                if rotation is 0
                    pixbufcopy = pixbuf.copy()

                if rotation is 1
                    pixbufcopy = pixbuf.rotate_simple(Gdk.PixbufRotation.COUNTERCLOCKWISE)
        
                if rotation is 2
                    pixbufcopy = pixbuf.rotate_simple(Gdk.PixbufRotation.CLOCKWISE) 
            
                pixbufcopy.save(gfxfile , "png" , null , 0)
                pixbufcopy = null
                thecmd = run_button_array[a[1].to_int()] + " \"" + gfxfile + "\""                
            except ex : GLib.Error
                thecmd = run_button_array[a[1].to_int()] 
        
        thecmd = correct_path_delimter(thecmd)
        print("%s" , thecmd)        
        try
            Process.spawn_command_line_async(thecmd)
        except ex : GLib.Error
            print("%s", "exec failed!")

    
        return false
 
    def on_size_request()

        //-- if window resizes...
        //.. rescale the displayed image...


        if not cbscale.get_active()
            //update_scroll()
            return

        scale_picture()
        
        
        //update_scroll()
        
    def update_scroll()
    
        //-- this is ignored?
    
        var pw = pixbuf.width
        var ph = pixbuf.height
        ad : Adjustment
        ad = scrolledwindow.get_vadjustment()
        //ad.set_value(((ph * zoomfactor / 100) / 2)   -   (ad.get_page_size() /2)  )
                
        ad = scrolledwindow.get_hadjustment()
        //ad.set_value(((pw * zoomfactor / 100) / 2)   -   (ad.get_page_size() /2)  )  
        //print ("--%f " , ((ph * zoomfactor / 100) / 2)   -   (ad.get_page_size() /2)  )

        //Gdk.flush()
        //print "ok"

    def alltext_page()
    
        if ispdf is false
            return
        

        //print ("%d " , pdfindex)
        
        
        ptext : string
        ptext = ""
        for var n = 0 to (document.get_n_pages () -1)
        
            var page = document.get_page (n)
            dpdfx : double
            dpdfy : double
            page.get_size(out dpdfx , out dpdfy)
        
            r: Poppler.Rectangle
            r = new Poppler.Rectangle()
            r.x1 = 0
            r.y1 = 0
            r.x2 = dpdfx
            r.y2 = dpdfy
        
        
            ptext += "\n- " + (n+1).to_string() + " -------------------------------------------------------------------------------\n\n" + page.get_text(Poppler.SelectionStyle.WORD,r)
            //print ("%s" , ptext)
        
        if windows    
            ptext = ptext.replace("\n" , "\r\n")
        
        textfile : string
        textfile = tempdir() + "/TEMP-text.txt"
        textfile = correct_path_delimter(textfile)
        try
            FileUtils.set_contents(textfile , ptext)
        except ex : FileError
            print ("%s" , "save error")
            
        if windows    
            exec ("notepad \"" + textfile + "\"")
        else
           exec ("leafpad \"" + textfile + "\"")
           
        //print("------%s" , textfile)
        //FileUtils.remove(textfile)
            
        
    def text_page()
    
        if ispdf is false
            return
        

        //print ("%d " , pdfindex)
        var page = document.get_page (pdfindex)
        
        dpdfx : double
        dpdfy : double
        page.get_size(out dpdfx , out dpdfy)
        
        r: Poppler.Rectangle
        r = new Poppler.Rectangle()
        r.x1 = 0
        r.y1 = 0
        r.x2 = dpdfx
        r.y2 = dpdfy
        
        ptext : string
        ptext = page.get_text(Poppler.SelectionStyle.WORD,r)
        //print ("%s" , ptext)
        
        if windows    
            ptext = ptext.replace("\n" , "\r\n")
        
        textfile : string
        textfile = GLib.Environment.get_tmp_dir() + "/TEMP-text.txt"
        try
            FileUtils.set_contents(textfile , ptext)
        except ex : FileError
            print ("%s" , "save error")
            
        if windows    
            exec ("notepad \"" + textfile + "\"")
        else
           exec ("leafpad \"" + textfile + "\"")
        //FileUtils.remove(textfile)
            
            
    def page_select() 

        var sel = pagecb.get_active()
        if pdfindex is sel
            return

        
        pdfindex = sel
        var page = document.get_page (pdfindex)
        page.render_to_pixbuf (0, 0, pdfx* (int)pdfscalecorrect, pdfy* (int)pdfscalecorrect, pdfscale, 0, pixbuf)
        forcescale = true
        scale_picture()        
        
    def next_page()
    
        if haspages is false
            return
        
        if ispdf is true
            if pdfindex is (document.get_n_pages () -1)
                return

            pagecb.set_active(pdfindex+1)

            /*
            pdfindex ++ 
            var page = document.get_page (pdfindex)
            page.render_to_pixbuf (0, 0, pdfx* (int)pdfscalecorrect, pdfy* (int)pdfscalecorrect, pdfscale, 0, pixbuf)
            forcescale = true
            scale_picture()
            */
        
        return
        
    def previous_page()
        
        if haspages is false
            return
            
        if ispdf is true
            if pdfindex is 0
                return
            
            pagecb.set_active(pdfindex-1)
                        
            /*
            pdfindex --
            var page = document.get_page (pdfindex);
            page.render_to_pixbuf (0, 0, pdfx* (int)pdfscalecorrect, pdfy* (int)pdfscalecorrect, pdfscale, 0, pixbuf)
            forcescale = true
            scale_picture()
            */
        return
                

    def rotate_left()
    
        rotation = 1
        forcescale = true
        scale_picture()


    def rotate_right()
    
        rotation = 2
        forcescale = true
        scale_picture()
    
    def rotate_none()
    
        rotation = 0
        forcescale = true
        scale_picture()
    
    def cbscaletoggle ()
        zoomfactor = zoomspin.get_value()
        forcescale = true        
        scale_picture()
        //update_scroll()

 
        
    def zoom()
    
        zoomfactor = zoomspin.get_value()

        //zoomspin.set_range(zoomfactor , zoomfactor)

        zoomspin.hide()
        if cbscale.get_active()
            cbscale.set_active(false)
            zoomspin.show()
            return
        
        forcescale = true
        scale_picture()
        zoomspin.show()

    
    def scale_picture()

        if pixbufsuccess is false
            return


        pixbufcopy : Gdk.Pixbuf

        pixbufcopy = pixbuf

        if rotation is 0
            pixbufcopy = pixbuf.copy()

        if rotation is 1
            pixbufcopy = pixbuf.rotate_simple(Gdk.PixbufRotation.COUNTERCLOCKWISE)
        
        if rotation is 2
            pixbufcopy = pixbuf.rotate_simple(Gdk.PixbufRotation.CLOCKWISE)   
    
        var scale = cbscale.get_active()
    
        var pw = pixbufcopy.width
        var ph = pixbufcopy.height

        //print("scale_picture_1")        
    
        var ww=0
        var wh=0
        ww = scrolledwindow.allocation.width
        wh = scrolledwindow.allocation.height

        
        if ww is last_w
            if wh is last_h
                if forcescale is false
                return
        
        forcescale = false
        last_h = wh
        last_w = ww    
    
        //print("scale_picture_2")
        if not scale


            zoomfactor = zoomspin.get_value()
            if zoomfactor is 100
                image.set_from_pixbuf(pixbufcopy)
            else

                pixbufcopy = pixbufcopy.scale_simple((int) (pw * zoomfactor /100), (int) (ph * zoomfactor / 100)  , Gdk.InterpType.HYPER)

                image.set_from_pixbuf(pixbufcopy)
        

            ad : Adjustment
            ad = scrolledwindow.get_vadjustment()
            // page size not in puppy 4!
            //ad.set_value(((ph * zoomfactor / 100) / 2)   -   (ad.get_page_size() /2)  )
              
            ad.set_value(((ph * zoomfactor / 100) / 2)   -   (wh /2)  )
              
                
            ad = scrolledwindow.get_hadjustment()
            //ad.set_value(((pw * zoomfactor / 100) / 2)   -   (ad.get_page_size() /2)  )                
              
            ad.set_value(((pw * zoomfactor / 100) / 2)   -   (ww /2)  ) 
              
                
            //print ("%f %f" , ad.get_page_size()  ,   (ph * zoomfactor / 100) / 2)

            //print ("%f " , ((ph * zoomfactor / 100) / 2)   -   (ad.get_page_size() /2)  )

            pixbufcopy = null
            return 

        //-- calculate the size for the image --


        //print("scale_picture_2 %d %d" , ww , wh)  
        
        w : float
        h : float

        var aspect = (float)pw /  (float)ph
        
        w = (float)ww
        h = (float)ww / aspect
            
        if (int)h > wh
            //print ("%s" , "AAA")
            h = (float) wh
            w = h * aspect
            
        //print ("a %d %d" , (int)w ,   (int)h)
        pixbufcopy = pixbufcopy.scale_simple((int)w, (int)h , Gdk.InterpType.HYPER)
  
        image.set_from_pixbuf(pixbufcopy)
        

        pixbufcopy = null

    def load_picture(uristring : string)

        
        var uri = uristring.replace("\\" , "/")
        uri = uri.replace("file:///" , "")

        
        var suffix= uri.rchr(-1,'.').down()

        //print("%s" , uri)
        
        var load = false
        ispdf = false
        
        if suffix is ".jpg"
            load = true
    
        if suffix is ".jpeg"
            load = true
                
        if suffix is ".png"
            load = true   
        
        if suffix is ".bmp"
            load = true
        
        if suffix is ".gif"
            load = true   
         
        if suffix is ".xpm"
            load = true   
         
        
        if suffix is ".pdf"
            ispdf = true
            load = true
            //hbox_runbuttons.hide()
            hbox_runbuttons_pdf.show()
            zoomspin.set_increments(10,50)
            zoomspin.set_value(70)
            
        else

            hbox_runbuttons_pdf.hide()        
            hbox_runbuttons.show()
            zoomspin.set_increments(50,50)
         
         
         
        if load is false
            return 
        


        if uri.substring(0,5) is "http:"
            download_and_show(uri)
        else
            if uri.substring(0,4) is "ftp:"
                download_and_show(uri)        
            else
                uri = "file:///" + uri
                uri = Filename.from_uri(uri)
                uri = uri.replace("\\" , "/")
                load_file(uri)
        
        //print "--> loaded file"


        return


    def download_and_show(uri : string)

        var suffix= uri.rchr(-1,'.').down()
        var thecmd = "wget -O /tmp/TEMP-file" + suffix + " " + uri + " 2>/dev/null"
        run (thecmd)
        load_file("/tmp/TEMP-file" + suffix)
        return

    def load_file(thefile : string)


        //-- generate the document --
        pixbufsuccess = false
        haspages = false

        if thefile is ""
            return
        
        if ispdf is true

            try
                //print ("%s" , thefile)
                //document = new Poppler.Document.from_file ("file:///" + thefile, "")
                document = new Poppler.Document.from_file (Filename.to_uri (thefile), "")
            except ex : GLib.Error
                print("%s", "load pdf failed!") 
                return
            

            if document.get_n_pages () > 1
                haspages = true
                
            
                
            pdfindex = 0
            //lastindex = 0
            var page = document.get_page (pdfindex)
            dpdfx : double
            dpdfy : double
            page.get_size(out dpdfx , out dpdfy)
            pdfx = (int) dpdfx
            pdfy = (int) dpdfy
        
            //print("%d %d %f " , pdfx , pdfy , pdfscale)
                       
            pixbuf= new Gdk.Pixbuf(Gdk.Colorspace.RGB, false, 8, pdfx * (int)pdfscale, pdfy * (int)pdfscale)
            page.render_to_pixbuf (0, 0, pdfx* (int)pdfscalecorrect, pdfy* (int)pdfscalecorrect, pdfscale, 0, pixbuf);
            
            //-- test windows poppler bug --
            //page.render_to_pixbuf (pdfx /2, pdfy/2, pdfx/2, pdfy/2, pdfscale, 0, pixbuf);
            
            pixbufsuccess = true
            current_file = thefile
            filename.set_text(thefile)
        
        else
        
            try
                pixbuf= new Gdk.Pixbuf.from_file(thefile)
                pixbufsuccess = true
                current_file = thefile
                filename.set_text(thefile)
            except ex : GLib.Error
                print("%s", "load pixbuf failed!") 
                pixbufsuccess = false
                return
 
 
        for var n = 0 to pdfpages            
            pagecb.remove_text(0) 
 
        if haspages is true
        
                
            pdfpages = document.get_n_pages () -1
            for var n = 0 to pdfpages
                pagecb.append_text((n+1).to_string())
                
            pagecb.set_active(0)
        
            hbox_pagebuttons.show()
        else
            pdfpages = 0
            hbox_pagebuttons.hide()
        
        rotation = 0 

        forcescale = true
        scale_picture()

        return
        
        
    def run(thecmd : string)
        try
            Process.spawn_command_line_sync(thecmd)
        except ex : GLib.Error
            print("%s", "run failed!")

        return

    def exec(thecmd : string)
        try
            Process.spawn_command_line_async(thecmd)
        except ex : GLib.Error
            print("%s", "exec failed!")

        return

    def correct_path_delimter(thepath : string) : string
    
        if windows
            return thepath.replace("/" , "\\")
        
        return thepath.replace("\\" , "/")
            
    def tempdir() : string
        var t = Environment.get_tmp_dir()
        if (FileUtils.test(t , GLib.FileTest.IS_DIR))
            return t
        
        t = Environment.get_home_dir() + "/tmp"
        DirUtils.create(t , 0700)
        return t
        
