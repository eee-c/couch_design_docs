require 'pp'

module CouchDesignDocs
  class Directory
    attr_accessor :couch_view_dir

    def self.a_to_hash(a)
      key = a.first
      if (a.length > 2)
        { key => a_to_hash(a[1,a.length]) }
      else
        { key => a.last }
      end
    end

    def initialize(path)
      Dir.new(path) # Just checkin'
      @couch_view_dir = path
    end

    def to_hash
      Dir["#{couch_view_dir}/**/*.js"].inject({}) do |memo, filename|
        hash = Directory.a_to_hash(expand_file(filename))
        deep_hash_merge(memo, hash)
      end
    end

    def expand_file(filename)
      File.dirname(filename).
        gsub(/#{couch_view_dir}\/?/, '').
        split(/\//) +
      [
       File.basename(filename, '.js'),
       File.new(filename).read
      ]
    end

    private
    def deep_hash_merge(h1, h2)
      h2.each_key do |k|
        if h1.key? k
          deep_hash_merge(h1[k], h2[k])
        else
          h1[k] = h2[k]
        end
      end
      h1
    end
  end
end
