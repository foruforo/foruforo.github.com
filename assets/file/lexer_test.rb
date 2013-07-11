require "./lexer_new" 
require 'test/unit'

class LexerTest < Test::Unit::TestCase
  def test

  code = <<-CODE 
if 1 {
  print "..."
  if false {
    pass }
  print "done!"
}
print "The End"
CODE

  tokens=[
    [:IF, "if"], [:NUMBER, 1],
    [:INBLOCK, 1],[:NEWLINE, "\n"],
      [:IDENTIFIER, "print"], [:STRING, "..."], [:NEWLINE, "\n"],
      [:IF, "if"], [:FALSE, "false"],
      [:INBLOCK, 2],[:NEWLINE, "\n"],
      [:IDENTIFIER, "pass"],
     [:DEBLOCK, 2], [:NEWLINE, "\n"],
     [:IDENTIFIER, "print"],
     [:STRING, "done!"],[:NEWLINE, "\n"],
    [:DEBLOCK, 1], [:NEWLINE, "\n"],
    [:IDENTIFIER, "print"], [:STRING, "The End"]
   ]
   
  assert_equal(tokens, LexerNew.new.tokenize(code))

 end
end