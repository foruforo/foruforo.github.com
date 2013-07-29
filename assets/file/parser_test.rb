require "./parser"
require 'test/unit'

class LexerTest < Test::Unit::TestCase
  def test

code=<<-CODE 
def method (a, b) {
	true
}
CODE

nodes=Nodes.new([ 
	DefNode.new("method", ["a", "b"],
      Nodes.new([TrueNode.new])
    )
])

assert_equal(nodes, Parser.new.parse(code)	)

end
end