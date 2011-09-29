# defines the OM terminology for a Hypatia ITEM object's descMetadata 
#  datastream, which will have Mods XML.
class HypatiaItemDescMetadataDS < ActiveFedora::NokogiriDatastream 
   
  set_terminology do |t|
        
    t.root(:path=>"mods", :xmlns=>"http://www.loc.gov/mods/v3", :schema=>"http://www.loc.gov/standards/mods/v3/mods-3-3.xsd")

    t.specific(:path=>"mods"){
      t.title_info(:ref=>[:title_info], :index_as=>[:sortable])
    }

    t.title_info(:path=>"titleInfo") {
      t.title(:path=>"title", :index_as=>[:searchable, :displayable], :label=>"title")
      # t.title(:path=>"title", :index_as=>[:searchable, :displayable], :label=>"title")
    }
    
    t.related_item(:path=>"relatedItem") {
      t.related_title_info(:path=>"titleInfo") {
        t.related_title(:path=>"title", :index_as=>[:searchable, :displayable], :label=>"related title")
      }
    }
    
    t.type_of_resource(:path=>"typeOfResource", :index_as=>[:searchable, :displayable])
    
    t.physical_desc(:path=>"physicalDescription") {
      t.extent(:path=>"extent", :index_as=>[:searchable])
      t.digital_origin(:path=>"digitalOrigin", :index_as=>[:searchable])
      t.form(:path=>"form", :index_as=>[:searchable, :displayable, :facetable])
    }

    t.located_in(:path=>"note", :attributes=>{:displayLabel=>"Located in"}, :index_as=>[:displayable])
    t.processing_info(:path=>"abstract", :attributes=>{:displayLabel=>"Processing Information note"}, :index_as=>[:searchable, :displayable])    
    t.local_id(:path=>"identifier", :attributes=>{:type=>"local"}, :index_as=>[:searchable, :displayable, :sortable])

    # proxy declarations
    t.title(:proxy=>[:specific, :title_info, :title])
    t.extent(:proxy=>[:physical_desc, :extent])
    t.form(:proxy=>[:physical_desc, :form])
    t.digital_origin(:proxy=>[:physical_desc, :digital_origin])

  end # set_terminology

end # class