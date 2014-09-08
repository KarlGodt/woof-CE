[indent=4]



/*----------------------------------------------------

  this files contains the tree classes.

  they make it easy to use a treeview.

  you usually should NOT edit this file!

------------------------------------------------------*/


uses
    Gtk


class treeclass


    //-- global variables, so we can use them in the eventhandlers --
    tree : TreeView
    store : TreeStore
    pixbuf1: Gdk.Pixbuf
    imagefile : string
    column : TreeViewColumn 
    selection : TreeSelection
    mode : string
    stopexpand : bool
    rootitem : TreeIter
    current_path : string
    root_expanded : bool
    windows : bool
    drive : string
    

    
    def show_filelist( thepath : string , types: array of string )
        //print("---->%s" , thepath)
        //-- when a folder was clicked, we want to show the files in it in the second tree --
        mydir : Dir  
        mydir = Dir.open (thepath);
        var filename = ""

        var c=0
        while (filename = mydir.read_name ()) != null
            c++
        mydir.rewind()
        var alist = new array of string[c+1]
        c=0       
        //print("----------------------------")
        while (filename = mydir.read_name ()) != null
            if not GLib.FileUtils.test( thepath + "/" + filename , GLib.FileTest.IS_DIR )
                if types[0] is "*"
                    alist[c] = filename
                    c++
                else
                    for var i=0 to (types.length -1)
                        var l=types[i].length+1
                        if filename.substring(-l) is "." + types[i]
                            alist[c] = filename
                            c++

      
        alist=natsortarray(c , alist)      

        var fname=""
        var le = c-1
        for var i=0 to le
            fname = alist[i]        
            add_root_item(fname )
        
        alist=null


    def tree_click() : string

        var selection = tree.get_selection()
        iter : TreeIter

        var rows = selection.get_selected_rows(null)
        if rows.length() is 0
            return ""
        selection.get_selected(null, out iter)
    
        var ret = ""
        tree.model.get( iter ,1 ,out ret)
        return (ret)



    def get_iter_from_string(thestring : string )  : TreeIter 

        var iter = get_first_iter()
        if not store.iter_is_valid(iter)
            iter = TreeIter()
            return iter
            
        var lastone = "-"
        var ret = ""
        while ret is not lastone
        
            iter = get_next_iter(iter)
        
        
            lastone = ret
            tree.model.get( iter ,1 ,out ret)
            //print("%s" , ret)
            if ret is thestring
                return iter
                
        iter = TreeIter()
        return iter 
        

    def select_iter(iter : TreeIter)
    
        selection.select_iter(iter)
        
        var treepath = store.get_path(iter)
        tree.scroll_to_cell(treepath , null, true,(float)0.5,(float)0.5)

        
    def get_first_iter() : TreeIter

        iter : TreeIter
        this.tree.model.get_iter_first(out iter)
        return iter

    def get_next_iter(iter : TreeIter) : TreeIter

        this.tree.model.iter_next(ref iter)
        return iter   
        
    def get_previous_iter(iter : TreeIter) : TreeIter

        var path = this.tree.model.get_path(iter).to_string()
        if path is "0"
            return iter
        var nr = path.to_int()-1

        store.get_iter_from_string(out iter , nr.to_string())
        return iter

    def select_first_item()
    
        var iter = get_first_iter()
        if store.iter_is_valid(iter)
            select_iter(iter)
            
    
    def select_next_item()
    
        var iter = get_selected_iter()
        if store.iter_is_valid(iter)
            var nextiter = get_next_iter(iter)
            select_iter(nextiter)
            
    def select_previous_item()        
        var iter = get_selected_iter()
        if store.iter_is_valid(iter)
            var previousiter = get_previous_iter(iter)
            select_iter(previousiter)


    
    
    def get_selected_iter() : TreeIter
        selection = tree.get_selection()
        iter : TreeIter

        var rows = selection.get_selected_rows(null)
        if rows.length() is 0
            iter = TreeIter()
            return iter
        selection.get_selected(null, out iter)

        return iter

    def get_selected_index(): int
    
        var iter = get_selected_iter()
        var pathstring = tree.model.get_path(iter).to_string()
        return pathstring.to_int()
    

    def expand_selected():bool
    
        selection = tree.get_selection()
        iter : TreeIter


        var rows = selection.get_selected_rows(null)
        if rows.length() is 0
            return true
        selection.get_selected(null, out iter)

        var path = tree.model.get_path(iter)
        var pathstring = path.to_string()
        return expand(pathstring)
        
       def collapse_selected():bool
    
        selection = tree.get_selection()
        iter : TreeIter


        var rows = selection.get_selected_rows(null)
        if rows.length() is 0
            return true
        selection.get_selected(null, out iter)

        var path = tree.model.get_path(iter)
        var pathstring = path.to_string()
        return collapse(pathstring)     

    def expand_filetree(folder : string)
    
        //print("--> %s" , folder)
        
            
        if windows is true
            if folder.substring(0,2) is not drive.substring(0,2)
                drive = folder.substring(0,3)
                destroy_tree()
                build_folder_tree()
                
        if not root_expanded 
            expand( "0" )
        
        var stringlist = folder.split("/")
        var l=stringlist.length -1
        
        iter : TreeIter
        var ret = ""
        var c = 0
        var testpath = ""
        var testfolder = ""
        var prefix="0:"
        var liststart = 1
        if windows is true
            liststart = 1
        for var i = 0 to 255
            for var n = liststart to l
                //print ("---->%s" , stringlist[n])
                c = 0
                
                var lastone = ""
                while true 
            
                    testpath = prefix + c.to_string()
                    var treepath = new TreePath.from_string (testpath)
                    store.get_iter (out iter, treepath)

                    store.get( iter ,1 ,out ret) 
                    
                    if ret is drive
                        return
                
                    //if c is 1000
                    //    return
                    if ret is lastone
                        return
                    lastone = ret
                
                
                    //print("- %s %s" , testpath , ret)
                    if ret is stringlist[n]

                        expand(testpath)
                        //tree.scroll_to_cell(treepath , null, true,(float)0.5,(float)0.5)
                        select_iter(iter)
                        prefix = testpath + ":"
                        testfolder = testfolder + "/" + stringlist[n]
                        //print("%s , %s" , "success" , testfolder)
                        if testfolder is folder
                            return
                        
                        break
                    c++



    def expand (pathstring : string):bool
    
        var treepath = new TreePath.from_string (pathstring)
        return tree.expand_row(treepath , false)

    def collapse (pathstring : string):bool
    
        var treepath = new TreePath.from_string (pathstring)
        return tree.collapse_row(treepath)

    def foldertree_click() : string

        selection = tree.get_selection()
        iter : TreeIter


        var rows = selection.get_selected_rows(null)
        if rows.length() is 0
            return ""
        selection.get_selected(null, out iter)
    
        //-- get the full path --   
        //--determine full path--
        var path = tree.model.get_path(iter)
        var pathstring = path.to_string()
        
        var ret = ""
        var newdir = ""
        var stringlist = pathstring.split(":")
        var n = stringlist.length -1
        var newpathstring = ""
        newiter : TreeIter
        for var i=0 to n
            //print ("%s" , stringlist[i])
            if i is 0
                newpathstring = stringlist[i]
            else
                newpathstring = newpathstring + ":" + stringlist[i]
                
                
            var treepath = new TreePath.from_string (newpathstring)
            
            store.get_iter (out newiter, treepath);
            store.get(newiter ,1 ,out ret)
            if i is 0
                newdir = ret
            else
                newdir = newdir + "/" + ret

            newdir = newdir.replace("//" , "/")
            newdir = newdir.replace("//" , "/")            
        //print (">%s" , newpathstring)

        //print(">>newdir: %s" , newdir)
        path = null
        return (newdir)


/*

    
        var selection = tree.get_selection()
        //-- multiple lines are more complicated
        //s : GLib.List
        //s = selection.get_selected_rows(out store1)
        //-- http://www.vala-project.org/doc/docu/gtk+-2.0.vapi/Gtk/TreeSelection.htm
    

*/

    def destroy_tree()
        root_expanded =  false
        store.clear()

    def init() : TreeView
	

        var tempdir = Environment.get_tmp_dir ()
        drive = "/"  
        if tempdir.contains("\\")
            windows = true
            drive = "C:/"


	
        //-- the treeview is the visible container --
        tree = new TreeView ()
        tree.set_headers_visible (true)
        tree.show()

    
        //-- set how many lines can be selected --
        selection = tree.get_selection()
        selection.set_mode((SelectionMode)1)
        
        //0: GTK_SELECTION_NONE
        //1: GTK_SELECTION_SINGLE
        //2: GTK_SELECTION_BROWSE
        //3: GTK_SELECTION_MULTIPLE
    
    
        //-- add a column to the treeview --
        column = new TreeViewColumn ()
        column.set_title ("column title")


        var columnpic = new CellRendererPixbuf ()




    /*
    GTK_ICON_SIZE_INVALID,
    GTK_ICON_SIZE_MENU,
    GTK_ICON_SIZE_SMALL_TOOLBAR,
    GTK_ICON_SIZE_LARGE_TOOLBAR,
    GTK_ICON_SIZE_BUTTON,
    GTK_ICON_SIZE_DND,
    GTK_ICON_SIZE_DIALOG
    */
    
        //-- this does not work ?
        //var image = new Gtk.Image.from_stock(Gtk.STOCK_DIRECTORY , Gtk.IconSize.BUTTON)

        //-- so load from file --
        var image = new Gtk.Image.from_file("./folder.png")
        pixbuf1 = image.get_pixbuf()

        //-- short code, but throws a warning --
        //var pixbuf1 = new Gdk.Pixbuf.from_file("./folder.png")
    
        var columncell = new CellRendererText ()

        column.pack_start(columnpic,false)    
        column.pack_start(columncell,true)


        column.add_attribute (columnpic, "pixbuf", 0);
        column.add_attribute(columncell, "text" , 1)
        tree.append_column (column)

        //-- the treestore is a model assigned to the treeview , containing the items --    
        store = new TreeStore (2,typeof(Gdk.Pixbuf), typeof (string));
        tree.set_model(store);
        
        
        if mode is "filebrowser"
            //print ("%s" , "filebrowser mode!")
            build_folder_tree()

            tree.row_expanded += foldertree_row_expanded
            tree.row_collapsed += foldertree_row_collapsed 			
        return tree
    
    def build_folder_tree()
    
        rootitem = add_root_item( drive )
    
        stopexpand = false
    
        read_folder( drive , rootitem)
        selection.select_iter(rootitem)
   

    
    def set_image(thefile : string)
        var image = new Gtk.Image.from_file(thefile)
        pixbuf1 = image.get_pixbuf()
        

    def add_root_item (text : string) : TreeIter
        iter : TreeIter
        store.append( out iter,null)
        store.set (iter, 0, pixbuf1,1, text)    
        return iter

    def add_item (text : string , parent : TreeIter) : TreeIter
        iter : TreeIter
        store.append( out iter,parent)
        store.set (iter, 0, pixbuf1,1, text)    
        return iter

    //def delete_all_items()



    
    def read_folder(start_dir : string , iter : TreeIter)

        newiter : TreeIter
        mydir : Dir  
        mydir = Dir.open (start_dir);
        var filename = ""
        var filename2 = ""
        //print("--> %s" , start_dir)
        var c=0
        while (filename = mydir.read_name ()) != null
            c++
        mydir.rewind()
        var alist = new array of string[c+1]
        c=0    
        while (filename = mydir.read_name ()) != null
            if GLib.FileUtils.test( start_dir + "/" + filename , GLib.FileTest.IS_DIR )
                alist[c] = filename
                c++
        
        alist=natsortarray(c , alist)      


        var le = c-1
        for var i=0 to le
            filename = alist[i]             
            newiter = add_item(filename , iter)
            mydir2 : Dir  
            mydir2 = Dir.open (start_dir + "/" + filename)
            c=0    
            while (filename2 = mydir2.read_name ()) != null
                c++
            mydir2.rewind()
            var alist2 = new array of string[c+1]
            c=0
            while (filename2 = mydir2.read_name ()) != null
                if GLib.FileUtils.test( start_dir + "/" + filename + "/" + filename2 , GLib.FileTest.IS_DIR )
                    alist2[c] = filename2
                    c++
                    if c is 2
                        break
            
            alist2=natsortarray(c , alist2)
            var fname2=""
            var le2 = c-1
            for var j=0 to le2
                fname2 = alist2[j] 
                add_item(filename2 , newiter)
            alist2=null
        
        alist=null

        current_path = start_dir 
        current_path = current_path.replace("//" , "/")
        //print("---> %s" , current_path)

    //-- action: a line in the tree1 was collapsed --

    def foldertree_row_collapsed(iter : TreeIter , path : TreePath)


        var path2=path
        if path2.to_string() is "0"
            root_expanded = false

        //var ret = ""

        //store.get(iter ,1 ,out ret)

        //print ("collapsed: %s" , ret)    
        //print ("path: %s" , path.to_string())

        //tree1_row_clicked() 
    

    //-- action: a line in the tree1 was expanded --

    def foldertree_row_expanded(iter : TreeIter , path : TreePath)

        if stopexpand is true
            stopexpand = false
            return

        var path2=path
        if path2.to_string() is "0"
            root_expanded = true


        var ret = ""
        store.get(iter ,1 ,out ret)
    
        //print ("expanded: %s" , ret) 
        //var newpath = ret   
        //print ("path: %s" , path.to_string())
    
        //-- assignement to path 2 removes a warning --
        //var path2=path    
        var pathstring = path2.to_string()
    
        //-- we first delete all children in the expanded branch, to stay up to date --
    
        var n = store.iter_n_children(iter) -1
        //print ("-- %d " , n)
    
        for var i= 0 to n
            iterchild : TreeIter
            store.iter_nth_child (out iterchild , iter ,0)
            store.get(iterchild ,1 ,out ret)
            //print ("---> child: %s" , ret)  
            store.remove(iterchild)


        //print("%s" , current_path)

        //--- now we read in the folders again --
    
        if pathstring is "0"
            read_folder( drive , rootitem)
            selection.select_iter(rootitem) 
        else 
    
            //--determine full path--
            var newdir = ""
            var stringlist = pathstring.split(":")
            n = stringlist.length -1
            var newpathstring = ""
            newiter : TreeIter
            for var i=0 to n
                //print ("%s" , stringlist[i])
                if i is 0
                    newpathstring = stringlist[i]
                else
                    newpathstring = newpathstring + ":" + stringlist[i]
                
                
                var treepath = new TreePath.from_string (newpathstring)
            
                store.get_iter (out newiter, treepath);
                store.get(newiter ,1 ,out ret)
            
                if i is 0
                    newdir = ret
                else
                    newdir = newdir + "/" + ret
				
                newdir = newdir.replace("//" , "/")
                newdir = newdir.replace("//" , "/")            
            //print (">%s" , newpathstring)

            //print(">>newdir: %s" , newdir)  
            read_folder( newdir , iter)
            selection.select_iter(iter) 
     
         stopexpand = true
         var treepath = new TreePath.from_string (pathstring)
         tree.expand_row(treepath , false)

         treepath = null
         //tree1_row_click()


