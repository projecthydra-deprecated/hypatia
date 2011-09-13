# a Fedora object for the Hypatia ITEM hydra content type
class HypatiaItem < ActiveFedora::Base
  has_metadata :name => "descMetadata", :type=> HypatiaItemDescMetadataDS
  has_metadata :name => "contentMetadata", :type=> HypatiaItemContentMetadataDS
  has_metadata :name => "rightsMetadata", :type => Hydra::RightsMetadata
  
  has_relationship "sets", :is_member_of, :type => HypatiaSet
end