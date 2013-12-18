---
layout: post
title: "创造一个自己的开发语言 （runtime）"
description: ""
category: learn
tags: [tec]
---
{% include JB/setup %}
##简介
一个语言的运行时模式是我们怎样表现这门语言的对象、方法、类型和内存结构。如果编译器是你怎样和这门语言讲话，那么运行时就是定义这门语言的行为。两门语言可以用同一个编译器，但是使用不同的运行时表现也会大相径庭。

当你设计你自己的运行时，有三个因素需要考虑

* 速度(speed)
* 灵活度(Flexibility)
* 内存占用(Memory footprint)

设计一个语言，大部分情况是这三个因素相互妥协的游戏。

##PROCEDURAL
像c和php(4以前)这样简单的运行时模型，所以的都以方法为中心。没有任何对象，并且所有的方法大多在同一个命名空间(namespace)下。他们很快就变得很混乱。

##CLASS-BASED
class-based model是现在比较流行的运行时模型。像java, Python, Ruby等等都是这种模型。

##PROTOTYPE-BASED
除了javascript以外,非 Prototype-based模式的语言已经相当的广泛和流行。这种模式是最容易实现也是最灵活的。因为所有的东西都是一个对象的clone.

##FUNCTIONAL
像Lisp、Haskell、Scala、clojure、Erlang等都是functional模型。其根源是数学中的λ演算（lambda Calculus).


##OUR AWESOME RUNTIME
因为大家对面向对象的编程模式比较熟悉，所有awesome也采用类似面向对象的运行时模式。例子中将定义对象、方法、类怎样存储和他们之间怎样相互配合和工作的.

AwesomeObject类是我们runtime的核心对象.

	runtime/object.rb

	# Represents an Awesome object instance in the Ruby world.
	class RumObject 
	  attr_accessor :runtime_class, :ruby_value

	  # Each object have a class (named runtime_class to prevent errors with Ruby's class
	  # method). Optionaly an object can hold a Ruby value (eg.: numbers and strings).
	  def initialize(runtime_class, ruby_value=self)
	    @runtime_class = runtime_class
	    @ruby_value = ruby_value
	  end

	  # Call a method on the object.
	  def call(method, arguments=[])
	    # Like a typical Class-based runtime model, we store methods in the class of the
	    # object.
	    @runtime_class.lookup(method).call(self, arguments)
	  end
	end

在Awesome中所有的事物都是对象,所以所有的类都是class类的实例。

	runtime/class.rb

	# Represents a Awesome class in the Ruby world. Classes are objects in Awesome so they
	# inherit from AwesomeObject.
	class RumClass < RumObject 
	  attr_reader :runtime_methods

	  # Creates a new class. Number is an instance of Class for example.
	  def initialize(superclass=nil)
	    @runtime_methods = {}
	    @runtime_superclass = superclass
	  
	    # Check if we're bootstrapping (launching the runtime). During this process the 
	    # runtime is not fully initialized and core classes do not yet exists, so we defer 
	    # using those once the language is bootstrapped.
	    # This solves the chicken-or-the-egg problem with the Class class. We can 
	    # initialize Class then set Class.class = Class.
	    if defined?(Runtime)
	      runtime_class = Runtime["Class"]
	    else
	      runtime_class = nil
	    end
	  
	    super(runtime_class)
	  end

	  # Lookup a method
	  def lookup(method_name)
	    method = @runtime_methods[method_name]
	    unless method
	      if @runtime_superclass
	        return @runtime_superclass.lookup(method_name)
	      else
	        raise "Method not found: #{method_name}"
	      end
	    end
	    method
	  end

	  # Create a new instance of this class
	  def new
	    RumObject.new(self)
	  end
	  
	  # Create an instance of this Rum class that holds a Ruby value. Like a String, 
	  # Number or true.
	  def new_with_value(value)
	    RumObject.new(self, value)
	  end
	end

Method对象将用来存储runtime时的方法定义

	runtime/method.rb

	# Represents a method defined in the runtime.
	class RumMethod
	  def initialize(params, body)
	    @params = params
	    @body = body
	  end
	  
	  def call(receiver, arguments)
	    # Create a context of evaluation in which the method will execute.
	    context = Context.new(receiver)
	    
	    # Assign arguments to local variables
	    @params.each_with_index do |param, index|
	      context.locals[param] = arguments[index]
	    end
	    
	    @body.eval(context)
	  end
	end

当我们开始引导我们的runtime之前，我们需要定义一个对象，即context的赋值.

The Context object encapsulates the
environment of evaluation of a specific block of code. It will keep track of the
following:

* 本地变量
* self的当前值
* 当前类



		runtime/context.rb

		# The evaluation context.
		class Context
		  attr_reader :locals, :current_self, :current_class
		  
		  # We store constants as class variable (class variables start with @@ and instance
		  # variables start with @ in Ruby) since they are globally accessible. If you want to
		  # implement namespacing of constants, you could store it in the instance of this 
		  # class.
		  @@constants = {}
		  
		  def initialize(current_self, current_class=current_self.runtime_class)
		    @locals = {}
		    @current_self = current_self
		    @current_class = current_class
		  end
		  
		  # Shortcuts to access constants, Runtime[...] instead of Runtime.constants[...]
		  def [](name)
		    @@constants[name]
		  end
		  def []=(name, value)
		    @@constants[name] = value
		  end
		end

最后我们开始引导runtime.首先，在runtime里是没有任何对象的.在我们执行我们的第一个表达式之前，
我们需要用Class、Object、true、false、nil等对象和以希望核心方法填充runtime.

	runtime/bootstrap.rb

	# Bootstrap the runtime. This is where we assemble all the classes and objects together
	# to form the runtime.
	                                            # What's happening in the runtime:
	rum_class = RumClass.new            #  Class
	rum_class.runtime_class = rum_class #  Class.class = Class
	object_class = RumClass.new             #  Object = Class.new
	object_class.runtime_class = rum_class  #  Object.class = Class

	# Create the Runtime object (the root context) on which all code will start its
	# evaluation.
	Runtime = Context.new(object_class.new)

	Runtime["Class"] = rum_class 
	Runtime["Object"] = object_class
	Runtime["Number"] = RumClass.new(Runtime["Object"])
	Runtime["String"] = RumClass.new

	# Everything is an object, even true, false and nil. So they need
	# to have a class too.
	Runtime["TrueClass"] = RumClass.new
	Runtime["FalseClass"] = RumClass.new 
	Runtime["NilClass"] = RumClass.new

	Runtime["true"] = Runtime["TrueClass"].new_with_value(true)
	Runtime["false"] = Runtime["FalseClass"].new_with_value(false)
	Runtime["nil"] = Runtime["NilClass"].new_with_value(nil)

	# Add a few core methods to the runtime.

	# Add the `new` method to classes, used to instantiate a class:
	#  eg.: Object.new, Number.new, String.new, etc.
	Runtime["Class"].runtime_methods["new"] = proc do |receiver, arguments|
	  receiver.new
	end

	# Print an object to the console.
	# eg.: print("hi there!")
	Runtime["Object"].runtime_methods["print"] = proc do |receiver, arguments|
	  puts arguments.first.ruby_value
	  Runtime["nil"]
	end

	Runtime["Number"].runtime_methods["+"] = proc do |receiver, arguments|
	    result = receiver.ruby_value + arguments.first.ruby_value
	    Runtime["Number"].new_with_value(result)
	end

	注:代码和书中有些不同