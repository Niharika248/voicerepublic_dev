module KlusHelper
  
  def bookmark_links(user, klu)
    #puts user.inspect
    #return nil if user.new_record?
    if user && (klu.user != user) &! klu.user.nil?
      if Bookmark.bookmarked?(user.id, klu.id)
        link_to(user_bookmark_path(:user_id => user, :id => Bookmark.bookmark_for(user.id, klu.id).id), :method => :delete, :title => t('.delete_bookmark', :default => "Delete Bookmark"), :class => "klu-bookmark-delete") do
          content_tag('i', '', :class => 'icon-bookmark')
        end
      else
        link_to(create_bookmark_path(:klu_id => klu), :method => :post, :title => t('.add_bookmark', :default => "Add Bookmark"), :class => "klu-bookmark-add") do
          content_tag('i', '', :class => 'icon-bookmark-empty')
        end
      end
    end
  end
  
  # renders the corresponding form for STI-model type Kluuu or NoKluuu
  #
  def form_for_klu(klu)
    klu.instance_of?(Kluuu) ? render(:partial => 'klus/form_kluuu') : render(:partial => 'klus/form_no_kluuu')
  end
  
  def form_for_new_klu(klu)
    klu.instance_of?(Kluuu) ? render(:partial => 'klus/form_new_kluuu') : render(:partial => 'klus/form_new_no_kluuu')
  end
  
  # returns a rendered partial for given kluuu in wanted size
  #
  def partial_for_klu(klu,size=:large)
    tmpl_prefix = case size
                  when :medium
                    'medium_'
                  when :small
                    'small_'
                  when :large
                    ''
                  end
    klu.instance_of?(Kluuu) ? render( :partial => "klus/#{tmpl_prefix}kluuu", :locals => { :klu => klu} ) : render( :partial => "klus/#{tmpl_prefix}no_kluuu", :locals => { :klu => klu} )
  end
  
  # delivers stars to display in a rating
  #
  def rating_stars_for(rating)
    ret = ""
    rating.score.times { ret.concat( content_tag(:i, '', :class => "icon icon-star") ) }
    (Rating::MAX - rating.score).times { ret.concat( content_tag(:i, '', :class => "icon icon-star-empty") ) } 
    ret.html_safe
  end
  
  def overall_rating_stars(klu)
    ret = ""
    klu.rating_score.times { ret.concat( content_tag(:i, '', :class => "icon icon-star") ) } 
    (Rating::MAX - klu.rating_score).times { ret.concat( content_tag(:i, '', :class => "icon icon-star-empty") ) } 
    ret.html_safe
  end
  
  def partial_for_status_or_about(klu)
    if klu.uses_status
      render(:partial => "klus/user_status", :locals => { :klu => klu } )  
    else
      render(:partial => "klus/user_about", :locals => { :klu => klu } )
    end 
  end
  
  def data_attributes_image_url(klu)
    klu.klu_images.map.each_with_index { |ki,i| "data-image-url-#{i}=#{ki.image.url(:large) }" }.join(" ")
  end
  
end
