
require File.join(File.dirname(__FILE__), %w[spec_helper])

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
      pending "you can do a better job with deep hash merging than that"
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
