module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    case page_name

    when /the home\s?page/
      '/'

    when /^the document page for id "(.+)"$/ 
      catalog_path($1)

    when /^the show page for (.+)$/ 
      catalog_path($1)

    when /the edit document page for (.*)$/i
      edit_catalog_path($1)

    when /the edit (.*) page for (.*)$/i
      edit_catalog_path($2,:wf_step=>$1)
      
    when /the download of (.*) from asset (.*)$/i
      asset_downloads_path($2, :download_id=>$1)
      
    else
      begin
        page_name =~ /the (.*) page/
        path_components = $1.split(/\s+/)
        self.send(path_components.push('path').join('_').to_sym)
      rescue Object => e
        raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
          "Now, go and add a mapping in #{__FILE__}"
      end
    end
  end
end

World(NavigationHelpers)
