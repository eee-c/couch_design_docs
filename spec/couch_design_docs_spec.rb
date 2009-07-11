require File.join(File.dirname(__FILE__), %w[spec_helper])

describe Store do
  it "should require a CouchDB URL Root for instantiation" do
    lambda { Store.new }.
      should raise_error

    lambda { Store.new("uri") }.
      should_not raise_error
  end

  context "a valid store" do
    before(:each) do
      @it = Store.new("uri")

      @hash = {
        'a' => {
          'b' => {
            'c' => 'function(doc) { return true; }'
          }
        }
      }
    end

    it "should be able to load a hash into design docs" do
      RestClient.
        should_receive(:put).
        with("uri/_design/a",
             '{"b":{"c":"function(doc) { return true; }"}}',
             :content_type => 'application/json')
      @it.load(@hash)
    end
  end
end

describe Directory do
  it "should require a root directory for instantiation" do
    lambda { Directory.new }.
      should raise_error

    lambda { Directory.new("foo") }.
      should raise_error

    lambda { Directory.new("fixtures")}.
      should_not raise_error
  end

  it "should convert arrays into deep hashes" do
    Directory.
      a_to_hash(%w{a b c d}).
      should == {
      'a' => {
        'b' => {
          'c' => 'd'
        }
      }
    }
  end

  context "a valid directory" do
    before(:each) do
      @it = Directory.new("fixtures")
    end

    it "should list dirs, basename and contents of a file" do
      @it.expand_file("fixtures/a/b/c.js").
        should == ['a', 'b', 'c', 'function(doc) { return true; }']
    end

    it "should assemble all documents into a single docs structure" do
      @it.to_hash.
        should == {
        'a' => {
          'b' => {
            'c' => 'function(doc) { return true; }',
            'd' => 'function(doc) { return true; }'
          }
        }

      }
    end
  end
end

# EOF
