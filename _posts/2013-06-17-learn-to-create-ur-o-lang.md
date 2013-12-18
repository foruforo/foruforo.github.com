---
layout: post
title: "创造一个自己的开发语言 （前言）"
description: "Creating your first programming language is easier than you think."
category: learn
tags: [tec]
---

{% include JB/setup %}

Marc 是个技术大牛。写了本书，叫《Create Your Own Freaking Awesome Programming Language》。ruby创始人Matz说他也很想读，CoffeeScript作者说他是看了这本书才创造了coffeescript的。一句话，Creating your first programming language is easier than you think.

这本书很薄，不过作者也说了他不是教你造一个可以用于生产级别的语言，而是帮你建个自己的一个玩具语言，其实CoffeeScript的作者也证明了，生产级别的语言也是行的，只要你够行。

这个系列文章，算是读书笔记，不算是翻译。所以很简要。

###BEFORE WE BEGIN

* Ruby 1.8.7 or 1.9.2
* Racc 1.4.6

###OVERVIEW

Contrary to Web Applications, where we’ve seen a growing number of frameworks, languages are still built from a `lexer`, a `parser` and a `compiler`.

有两本经典的书还是值得看的。Principles of Compiler Design （1977）和 Smalltalk-80: The Language and its Implementation （1983）

###THE FOUR PARTS OF A LANGUAGE

很多的动态语言都由4部分组成：the `lexer`, the `parser`, the `interpreter` and the `runtime`. 

![urownlang-1.jpg](/assets/image/post/urownlang-1.jpg)

###MEET AWESOME: OUR TOY LANGUAGE
即将开发出来的语言叫`Awesome`,好臭美啊。它有点像Ruby和Python的混血儿。

{% highlight ruby %}
class Awesome: 
    def name:
        "I'm Awesome"
    def awesomeness:
        100
awesome=Awesome.new 
print(awesome.name) 
print(awesome.awesomeness)
{% endhighlight %}

假设Awesome语言的基本规则是:

* As in Python, blocks of code are delimited by their indentation.
* Classes are declared with the class keyword.
* Methods can be defined anywhere using the def keyword.
* Identifiers starting with a capital letter are constants which are globally accessible.
* Lower-case identifiers are local variables or method names.
* If a method takes no arguments, parenthesis can be skipped, much like in Ruby.
* The last value evaluated in a method is its return value.
* Everything is an object.


flex:词法分析器
词法分析器的作用是把字符解析成单词。一般的把单词称为token.
首先来看flex的使用：简单来说分为两步： 1 先定义一个flex的输入文件，描述词法。2 用flex程序处理这个文件，生成对应的C语言源代码文件。

BISON:语法分析器

    

