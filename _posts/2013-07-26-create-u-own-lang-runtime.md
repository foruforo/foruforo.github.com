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
class-based model是现在比较流行的运行时模型。像ava, Python, Ruby等等都是这种模型。

##PROTOTYPE-BASED
除了javascript以外,非 Prototype-based模式的语言已经相当的广泛和流行。这种模式是最容易实现也是最灵活的。因为所有的东西都是一个对象的clone.

##FUNCTIONAL
像Lisp、Haskell、Scala、clojure、Erlang等都是functional模型。其根源是数学中的λ演算（lambda Calculus.).




