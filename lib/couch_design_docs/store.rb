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
        Store.put("#{url}/_design/#{document_name}", doc)
      end
    end

    def self.put(path, doc)
      RestClient.put path,
        doc.to_json,
        :content_type => 'application/json'
    end

    def self.delete(path)
      # retrieve existing to obtain the revision
      old = self.get(path)
      RestClient.delete(path + "?rev=#{old['_rev']}")
    end

    def self.get(path)
      JSON.parse(RestClient.get(path))
    end
  end
end
