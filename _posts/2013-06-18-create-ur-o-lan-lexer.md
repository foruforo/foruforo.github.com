---
layout: post
title: "创造一个自己的开发语言 （Lexer）"
description: ""
category: learn
tags: [tec]
---
{% include JB/setup %}
###Lexer

先看看下面这段代码

    print "I ate",
           3,
           pies

一旦这段代码进入了词法分析器，看起来就像下面这样

    [IDENTIFIER print] [STRING "I ate"] [COMMA]
                        [NUMBER 3] [COMMA]
                        [IDENTIFIER pies]

What the lexer does is split the code and tag each part with the type of token it contains. 

词法分析器(`Lexer`)的作用就是把字符解析成单词(`token`).

####LEX (FLEX)

Lex(包含Lex家族)不是Lexer,它只是个Unix下词法分析器的生成工具，主要是用来生成C Lexer的，经常和Yacc配合着用。在linux下对应的就是Flex和BISON了。给他一套语法，他能还你一词法分析器。

语法就像下面这样编写，详细的可以查看FLEX文档

    BLANK        [ \t\n]+
     %%
     // Whitespace
     {BLANK}       /* ignore */
     // Literals
     [0-9]+        yylval = atoi(yytext); return T_NUMBER;
     // Keywords
     "end"         yylval = yytext; return T_END;
     // ...


当然也有支持其他语言的：

* Rex for Ruby
* JFlex for Java

####RAGEL

Ragel是个有限状态机编译器，它将基于正则表达式的状态机编译成传统语言（C，C++，D，Java，Ruby等）的解析器。Ragel不仅仅可以用来解析字节流，它实际上可以解析任何可以用正则表达式表达出来的内容。而且可以很方便的将解析代码嵌入到传统语言中。

下面就是Ragel grammar的样子

    %%{
     machine lexer;
     # Machine
     number      = [0-9]+;
     whitespace  = " ";
     keyword     = "end" | "def" | "class" | "if" | "else" | "true" | "false" | "nil";
     # Actions
     main := |*
       whitespace;  # ignore
       number      => { tokens << [:NUMBER, data[ts..te].to_i] };
       keyword     => { tokens << [data[ts...te].upcase.to_sym, data[ts...te]] };
    *|;
     class Lexer
       def initialize
        %% write data;
       end
       def run(data)
         eof = data.size
         line = 1
         tokens = []
         %% write init;
         %% write exec;
         tokens
    end end
    }%% 

更多的详情可以查看[ Ragel manual (pdf)](http://www.complang.org/ragel/ragel-guide-6.5.pdf)

下面是两个真实的lexer例子

* [Min’s lexer (Java)](https://github.com/macournoyer/min/blob/master/src/min/lang/Scanner.rl)
* [Potion’s lexer (C)](https://github.com/whymirror/potion/blob/fae2907ce1f4136da006029474e1cf761776e99b/core/pn-scan.rl)

