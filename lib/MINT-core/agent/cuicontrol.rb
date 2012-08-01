module CUIControl
  include MINT

  @active_cios = []
  def CUIControl.find_cio_from_coordinates(result)
    # puts "mouse stopped #{result.inspect}"
     if result == nil or @active_cios.length ==0# we have not finished cui poition calculation, but we already received a mouse stopped event
       return true

     end
     x = result["x"]
     y = result["y"]

     highlighted_cio = MINT::CIO.first(:states=>/highlighted/)

     if (highlighted_cio!=nil && highlighted_cio.x<=x && highlighted_cio.y<=y && highlighted_cio.x+highlighted_cio.width>=x && highlighted_cio.y+highlighted_cio.height>=y)
     #  puts "unchanged"
       return true
     else

       found = @active_cios.select{ |e|  e.x <=x && e.y<=y && e.x+e.width>=x && e.y+e.height>=y}

 #      puts "found #{found.inspect}"

       if (highlighted_cio)
         highlighted_cio.process_event("unhighlight") # old focus
   #      puts "unhighlight:"+highlighted_cio.name
         # @highlighted_cio.update(:state=>"calculated") # old focus
       end

       if (found.first)
         highlighted_cio = MINT::CIO.first(:name=>found.first.name)
         highlighted_cio.process_event("highlight")
  #       puts "highlighted:"+highlighted_cio.name
       else
    #     puts "no highlight"
         return  true
       end
     end
    return true
   end

  def CUIControl.fill_active_cio_cache(result=nil)
    @active_cios = CIO.all.select{ |e| e.is_in?(:displaying) and e.highlightable}
    puts "CIO cache initialized with #{@active_cios.inspect} elements"
  end

  def CUIControl.add_to_cache(cio)
  if cio['highlightable'] and not @active_cios.index{|x|x.name==cio["name"]}
     c =  CIO.get("cui-gfx",cio["name"])
     @active_cios << c
     puts "Added #{cio['name']} to CIO cache #{c.x}/#{c.y}"

    end
    return true
  end

  def CUIControl.update_cache(cio)
    index = @active_cios.index{|x|x.name==cio["name"]}
    if index
     c =  CIO.get("cui-gfx",cio["name"])
     @active_cios[index] = c
     puts "Updated#{cio['name']} to CIO cache #{c.x}/#{c.y} #{c.width}/#{c.height}"

    end
    return true
  end


  def CUIControl.remove_from_cache(cio)
    p "remove cache"
      if cio['highlightable']
        @active_cios.delete_if{|x| x.name == cio['name']}
        puts "Removed #{cio['name']} from CIO cache "
      end
    return true
    end

end
