require File.join(File.dirname(__FILE__), %w[spec_helper])

describe CouchDesignDocs do
  it "should be able to load design and normal documents" do
    CouchDesignDocs.
      should_receive(:put_design_dir).
      with("uri", "fixtures/_design")

    CouchDesignDocs.
      should_receive(:put_document_dir).
      with("uri", "fixtures")

    CouchDesignDocs.put_dir("uri", "fixtures")
  end

  it "should be able to load directory/JS files into CouchDB as design docs" do
    store = mock("Store")
    Store.stub!(:new).and_return(store)

    dir = mock("Design Directory")
    dir.stub!(:to_hash).and_return({ "foo" => "bar" })
    DesignDirectory.stub!(:new).and_return(dir)

    store.
      should_receive(:put_design_documents).
      with({ "foo" => "bar" })

    CouchDesignDocs.put_design_dir("uri", "fixtures")
  end

  it "should be able to load documents into CouchDB" do
    store = mock("Store")
    Store.stub!(:new).and_return(store)

    dir = mock("Document Directory")
    dir.
      stub!(:each_document).
      and_yield('foo', {"foo" => "1"})

    DocumentDirectory.stub!(:new).and_return(dir)

    Store.
      should_receive(:put!).
      with('uri/foo', {"foo" => "1"})

    CouchDesignDocs.put_document_dir("uri", "fixtures")
  end
end


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
      @it.put_design_documents(@hash)
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

describe DocumentDirectory do
  it "should require a root directory for instantiation" do
    lambda { DocumentDirectory.new }.
      should raise_error

    lambda { DocumentDirectory.new("foo") }.
      should raise_error

    lambda { DocumentDirectory.new("fixtures")}.
      should_not raise_error
  end

  context "a valid directory" do
    before(:each) do
      @it = DocumentDirectory.new("fixtures")
    end

    it "should be able to iterate over the documents" do
      everything = []
      @it.each_document do |name, contents|
        everything << [name, contents]
      end
      everything.
        should == [['bar', {"bar" => "2"}],
                   ['foo', {"foo" => "1"}]]
    end
  end
end

describe DesignDirectory do
  it "should require a root directory for instantiation" do
    lambda { DesignDirectory.new }.
      should raise_error

    lambda { DesignDirectory.new("foo") }.
      should raise_error

    lambda { DesignDirectory.new("fixtures/_design")}.
      should_not raise_error
  end

  it "should convert arrays into deep hashes" do
    DesignDirectory.
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
      @it = DesignDirectory.new("fixtures/_design")
    end

    it "should list dirs, basename and contents of a file" do
      @it.expand_file("fixtures/_design/a/b/c.js").
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
