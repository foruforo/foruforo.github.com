class Lexer
	KEYWORDS = ["def","class","if","false","nil"]

	def tokenize(code)
		#cleanup code by remove extra line breaks
		code.chomp!

		#current char position we're parsing
		i = 0

		#Collection of all parsed tokens in the form [:TOKEN_TYPE , value]
		tokens = []

		#Current indent level is the number of spaces in the last indent.
		current_indent = 0

		# we keep track of the indentation levels we r in so that when we dedent,
		# we can check if wr're on the correct level
		indent_stack = []

		# This is how to implement a very simple scanner
		# Sacn one char at the time util u find something to parse.
		while i < code.size
			chunk = code[i..-1]

			# matching standard tokens
			#
			# matching if, print,method names, etc.
			if identifier = chunk[/\A([a-z]\w*)/,1]
				# Keywords are special identifiers tagged with their own name, 'if' will result
				# in an [:IF, "if"] token
				if KEYWORDS.include?(identifier)
					tokens << [identifier.upcase.to_sym,identifier]
				# Non-keyword identifiers include method and variable names.
				else
					tokens << [:IDENTIFIER,identifier]
				end
				# SKIP WHAT WE JUST PARSED
				i += identifier.size

			elsif number = chunk[/\A([0-9]+)/,1]
				tokens << [:NUMBER,number.to_i]
				i += number.size

			elsif string = chunk[/\A"(.*?)"/,1]
				tokens << [:STRING,string]
				i += string.size + 2

			# Here's the indentation magic!
			# 
			# We have to take care of 4 cases:
			#
			#    if true :  # 1) the block is created
			#      line 1
			#      line 2   # 2) new line inside a block
			#    continue   # 3) dedent
			#this elsif takes care of the first case. The number of spaces will determine
			# the indent level

			elsif indent = chunk[/\A\:\n( +)/m,1]  # matches ": <newline> <spaces>"
				# when we create a new block we expect the indent level to go up
				if indent.size <= current_indent
					raise "Bad indent level, got #{indent.size} indents ," +
					      "expected > #{current_indent}"
				end
				# Adjust the current indentation level.
				current_indent = indent.size
				indent_stack.push(current_indent)
				tokens << [:INDENT,indent.size]
				i += indent.size + 2

			# this elsif takes care of the two last cases:
			# case 2: we stay in the same block if the indent level (number of spaces) 
			#         is the same as cuttrent_indent.   
			# case 3: close the current block. if indent level is lower than current_indent
			elsif indent = chunk[/\A\n( *)/m,1] # matches "<newline> <spaces>"
				if indent.size == current_indent # case 2
					# nothing to do ,we'r still in the same block
					tokens << [:NEWLINE,"\n"]
				elsif indent.size < current_indent # case 3 
					while indent.size < current_indent
						indent_stack.pop
						current_indent = indent_stack.first || 0
						tokens << [:DEDENT,indent.size]
					end
					tokens << [:NEWLINE,"\n"]
				else # indent.size > current_indent,error!
				     # cannot increase indent level without using ":", so this is an error.
				     raise "Missing ':'"		
						
				end
				i += indent.size + 1
				

			# match long operators such as ||,&&,==,!=,<= and >=
			# one char long operators r mathced by the catch all 'else' at the bottom
			elsif operator = chunk[/\A(\|\||&&|==|!=|<=|>=)/,1]
				tokens << [operator,operator]
				i +=  operator.size

			# ignore whitespace
			elsif chunk.match(/\A /)
				i += 1

			# catch all single char
			# we treat all other single char as a token eg: (), . ! + - <
			else
				value = chunk[0,1]
				tokens << [value,value]
				i += 1

			end

		end

		# close all open blocks
		while indent = indent_stack.pop
			tokens << [:DEDENT,indent_stack.first || 0]
		end
		
		tokens	

	end
						

end


