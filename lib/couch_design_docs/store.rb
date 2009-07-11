require 'rest_client'
require 'json'

module CouchDesignDocs
  class Store
    attr_accessor :url

    def initialize(url)
      @url = url
    end

    def load(h)
      h.each_pair do |document_name, doc|
        RestClient.put "#{url}/_design/#{document_name}",
          doc.to_json,
          :content_type => 'application/json'
      end
    end
  end
end
