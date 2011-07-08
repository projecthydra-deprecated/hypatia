# Hypatia overrides of blacklight_config.rb
Blacklight.configure(:shared) do |config|
  
  # Set up and register the default SolrDocument Marc extension
  SolrDocument.extension_parameters[:marc_source_field] = :marc_display
  SolrDocument.extension_parameters[:marc_format_type] = :marc21
  SolrDocument.use_extension( Blacklight::Solr::Document::Marc) do |document|
    document.key?( :marc_display  )
  end

  # DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core document
  SolrDocument.use_extension( Blacklight::Solr::Document::DublinCore)
    
  # Semantic mappings of solr stored fields. Fields may be multi or
  # single valued. See Blacklight::Solr::Document::ExtendableClassMethods#field_semantics
  # and Blacklight::Solr::Document#to_semantic_values
  # Recommendation: Use field names from Dublin Core
  SolrDocument.field_semantics.merge!(    
    :title => "title_display",
    :author => "author_display",
    :language => "language_facet"  
  )
        
  
  
  
  ##############################

  config[:default_solr_params] = {
    :qt => "search",
    :per_page => 10 
  }
  
  config[:public_solr_params] = {
    :qt => "search",
    :per_page => 10
  }
  

  # solr field values given special treatment in the show (single result) view
   config[:show] = {
     :html_title => "title_t",
     :heading => "title_t",
     :display_type => "has_model_s"
   }

   # solr fld values given special treatment in the index (search results) view
   config[:index] = {
     :show_link => "title_facet",
     :num_per_page => 40,
     :record_display_type => "id"
   }

     # solr fields that will be treated as facets by the blacklight application
     #   The ordering of the field names is the order of the display
     config[:facet] = {
       :field_names => (facet_fields = [
         "object_type_facet",
         "set_type_facet",
         "genre_facet",
         "subject_topic_facet",
         "format_facet",
         "mimetype_facet",
         "tag_facet"
         ]),
       :labels => {
         "object_type_facet"=>"Object Type",
         "set_type_facet"=>"Set Type",
         "genre_facet"=>"Genre",
         "subject_topic_facet"=>"Topic",
         "format_facet"=>"Format",
         "mimetype_facet"=>"MIME Type",
         "tag_facet"=>"Tags"
       },

       :limits=> {nil=>10}
     }


     # Have BL send all facet field names to Solr, which has been the default
     # previously. Simply remove these lines if you'd rather use Solr request
     # handler defaults, or have no facets.
     config[:default_solr_params] ||= {}
     config[:default_solr_params][:"facet.field"] = facet_fields


     # solr fields to be displayed in the index (search results) view
     #   The ordering of the field names is the order of the display 
     # solr fields to be displayed in the index (search results) view
      #   The ordering of the field names is the order of the display 
      config[:index_fields] = {
        :field_names => [
          "date_t",
          "title_t",
          "medium_t",
          "location_t"],
        :labels => {
          "date_t"=>"Date",
          "title_t"=>"Title",
          "medium_t"=>"Content Type",
          "location_t"=>"Location"
        }
      }
  
     # solr fields to be displayed in the show (single result) view
     #   The ordering of the field names is the order of the display 
     config[:show_fields] = {
        :field_names => [
          "text",
          "title_facet",
          "date_t",
          "medium_t",
          "location_t",
          "rights_t",
          "access_t"
        ],
        :labels => {
          "text" => "Text:",
          "title_facet" => "Title:",
          "date_t" => "Date:",
          "medium_t" => "Document Type:",
          "location_t" => "Location:",
          "rights_t"  => "Copyright:",
          "access_t" => "Access:"
        }
      }


      # "fielded" search configuration. Used by pulldown among other places.
      # For supported keys in hash, see rdoc for Blacklight::SearchFields
      #
      # Search fields will inherit the :qt solr request handler from
      # config[:default_solr_parameters], OR can specify a different one
      # with a :qt key/value. Below examples inherit, except for subject
      # that specifies the same :qt as default for our own internal
      # testing purposes.
      #
      # The :key is what will be used to identify this BL search field internally,
      # as well as in URLs -- so changing it after deployment may break bookmarked
      # urls.  A display label will be automatically calculated from the :key,
      # or can be specified manually to be different. 
      config[:search_fields] ||= []

      # This one uses all the defaults set by the solr request handler. Which
      # solr request handler? The one set in config[:default_solr_parameters][:qt],
      # since we aren't specifying it otherwise. 

      config[:search_fields] << ['Descriptions', 'search']
      config[:search_fields] << ['Descriptions and full text', 'fulltext']


      # Now we see how to over-ride Solr request handler defaults, in this
      # case for a BL "search field", which is really a dismax aggregate
      # of Solr search fields. 
      config[:search_fields] << {
        :key => 'title',     
        # solr_parameters hash are sent to Solr as ordinary url query params. 
        :solr_parameters => {
          :"spellcheck.dictionary" => "title"
        },
        # :solr_local_parameters will be sent using Solr LocalParams
        # syntax, as eg {! qf=$title_qf }. This is neccesary to use
        # Solr parameter de-referencing like $title_qf.
        # See: http://wiki.apache.org/solr/LocalParams
        :solr_local_parameters => {
          :qf => "$title_qf",
          :pf => "$title_pf"
        }
      }
      config[:search_fields] << {
        :key =>'author',     
        :solr_parameters => {
          :"spellcheck.dictionary" => "author" 
        },
        :solr_local_parameters => {
          :qf => "$author_qf",
          :pf => "$author_pf"
        }
      }

      # Specifying a :qt only to show it's possible, and so our internal automated
      # tests can test it. In this case it's the same as 
      # config[:default_solr_parameters][:qt], so isn't actually neccesary. 
      config[:search_fields] << {
        :key => 'subject', 
        :qt=> 'search',
        :solr_parameters => {
          :"spellcheck.dictionary" => "subject"
        },
        :solr_local_parameters => {
          :qf => "$subject_qf",
          :pf => "$subject_pf"
        }
      }

      # "sort results by" select (pulldown)
      # label in pulldown is followed by the name of the SOLR field to sort by and
      # whether the sort is ascending or descending (it must be asc or desc
      # except in the relevancy case).
      # label is key, solr field is value
      config[:sort_fields] ||= []
      config[:sort_fields] << ['relevance', 'score desc, year_facet desc, month_facet asc, title_facet asc']
      config[:sort_fields] << ['date -', 'year_facet desc, month_facet asc, title_facet asc']
      config[:sort_fields] << ['date +', 'year_facet asc, month_facet asc, title_facet asc']
      config[:sort_fields] << ['title', 'mods_title_info_main_title_facet asc']
      #config[:sort_fields] << ['document type', 'medium_t asc, year_facet desc, month_facet asc, title_facet asc']
      #config[:sort_fields] << ['location', 'series_facet asc, box_facet asc, folder_facet asc, year_facet desc, month_facet asc, title_facet asc']

      # If there are more than this many search results, no spelling ("did you 
      # mean") suggestion is offered.
      config[:spell_max] = 5


  # number of facets to show before adding a more link
  config[:facet_more_num] = 5
  
  
end