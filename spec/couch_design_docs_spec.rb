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

    it "should be able to put a new document" do
      Store.
        should_receive(:put).
        with("uri", { })

      Store.put!("uri", { })
    end

    it "should delete existing docs if first put fails" do
      Store.
        stub!(:put).
        and_raise(RestClient::RequestFailed)

      Store.
        should_receive(:delete_and_put).
        with("uri", { })

      Store.put!("uri", { })
    end

    it "should be able to delete and put" do
      Store.
        should_receive(:delete).
        with("uri")

      Store.
        should_receive(:put).
        with("uri", { })

      Store.delete_and_put("uri", { })
    end

    it "should be able to load a hash into design docs" do
      RestClient.
        should_receive(:put).
        with("uri/_design/a",
             '{"b":{"c":"function(doc) { return true; }"}}',
             :content_type => 'application/json')
      @it.load(@hash)
    end

    it "should be able to retrieve an existing document" do
      RestClient.
        stub!(:get).
        and_return('{"_rev":"1234"}')

      Store.get("uri").should == { '_rev' => "1234" }
    end

    it "should be able to delete an existing document" do
      Store.stub!(:get).and_return({ '_rev' => '1234' })

      RestClient.
        should_receive(:delete).
        with("uri?rev=1234")

      Store.delete("uri")
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
