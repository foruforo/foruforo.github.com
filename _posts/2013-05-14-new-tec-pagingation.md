---
layout: post
title: "分页设计"
description: ""
category: 
tags: [jee]
---
{% include JB/setup %}

#通用分页设计

##页面分页对象的设计
要让数据在页面上分页展示，需要一些基本的分页数据，主要有

* 数据总条数`totalNumber`
* 每页数据条数`pageSize`
* 总页数`totalPages`
* 当前页`currentPage`
* 本页数据集合`pageList`
* 本页开始位置`firstResult`
* 本页结束位置`endResult`

##数据库后台分页设计

数据访问才有JPA，所以数据库后台分页也就用到JPA分页查询的功能。如果没有用hibernate或spring data框架，用原生JPA的话，可以自己组织分页语句

###查询条件封装

>SearchBean

    public enum Operator{
        EQ,NEQ,LIKE,GT,LT,GTE,LTE,IN,NIN
    }
    String fieldName;
    Object value;
    Operator operator;






