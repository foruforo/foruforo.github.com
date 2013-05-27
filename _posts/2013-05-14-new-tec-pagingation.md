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

数据访问采用JPA，所以数据库后台分页也就用到JPA分页查询的功能。如果没有用hibernate或spring data框架，用原生JPA的话，可以自己组织分页语句，使用CriteriaQuery进行动态查询语句的组合。

###查询条件及排序封装

>查询条件SearchBean

    public enum Operator{
        EQ,NEQ,LIKE,GT,LT,GTE,LTE,IN,NIN
    }
    String fieldName;
    Object value;
    Operator operator;

    public static List<SearchBean> parseToList(Map<String, Object> searchParams){
         List<SearchBean> searchBeans = Lists.newArrayList();
         for (Entry<String, Object> entry : searchParams.entrySet()) {
                // 过滤掉空值
                String key = entry.getKey();
                Object value = entry.getValue();
                if (StringUtils.isBlank((String) value)) {
                    continue;
                }

                // 拆分operator与filedAttribute
                String[] names = StringUtils.split(key, "_");
                if (names.length != 2) {
                    throw new IllegalArgumentException(key
                            + " is not a valid search filter name");
                }
                String filedName = names[0];
                Operator operator = Operator.valueOf(names[1]);

                // 创建searchFilter
                SearchBean filter = new SearchBean(filedName,  value,operator);
                searchBeans.add( filter);
            }
         return searchBeans;
    }

>排序条件OrderBy

    public enum OrderByDirection {
            ASC, DESC;
    }
    public String columnOrProperty;
    public OrderByDirection direction;

    public static List<OrderBy> parseToList(Map<String, String> orderParams){
        List<OrderBy> orderBys = Lists.newArrayList();
        for (Entry<String, String> entry :orderParams.entrySet()){
            String key = entry.getKey();
            String value = entry.getValue();
            if (StringUtils.isBlank((String) value)) {
                continue;
            }
            
            OrderBy orderBy = new OrderBy(key,OrderByDirection.valueOf(value));
            orderBys.add(orderBy);
        }
        return orderBys;
    }

>分页类PagingationSupportForJPA
    //查询数据集总数
    public final Long getTotals(Class<T> clazz,
            final Collection<SearchBean> searchBeans) {
        CriteriaBuilder builder = this.getEntityManager().getCriteriaBuilder();
        CriteriaQuery<Long> cql = builder.createQuery(Long.class);
        Root<T> root = cql.from(clazz);
        cql.select(builder.count(root));
        Predicate predicate = creatPredicate(root, searchBeans, builder);
        cql.where(predicate);
        TypedQuery<Long> query = this.getEntityManager().createQuery(cql);
        return query.getSingleResult();
    }

    //单页数据集查询
    public final List<T> queryForList(Class<T> clazz,
            final Collection<SearchBean> searchBeans,
            final Collection<OrderBy> OrderBys, int firstResult, int maxResult) {
        CriteriaBuilder builder = this.getEntityManager().getCriteriaBuilder();
        CriteriaQuery<T> cq = builder.createQuery(clazz);
        Root<T> root = cq.from(clazz);
        cq.select(root);
        Predicate predicate = creatPredicate(root, searchBeans, builder);
        cq.where(predicate);
        cq.orderBy(createOrders(root, OrderBys, builder));
        TypedQuery<T> query = this.getEntityManager().createQuery(cq);

        if (firstResult >= 0)
            query.setFirstResult(firstResult);
        if (maxResult > 0)
            query.setMaxResults(maxResult);
        return query.getResultList();
    }

    //分页查询
    public final Pager<T> getPager(Class<T> clazz,
            final Collection<SearchBean> searchBeans,
            final Collection<OrderBy> OrderBys, int currentPage, int pageSize) {
        Long totalObjects = getTotals(clazz, searchBeans);
        Pager<T> pager = new Pager<T>(totalObjects.intValue(), currentPage,
                pageSize);
        pager.setPageList(queryForList(clazz, searchBeans, OrderBys,
                pager.getFirstResult(), pager.getPageSize()));
        log.info("Pager="+pager);
        return pager;
    }

    // 构造orders
    final List<Order> createOrders(Root<T> root,
            final Collection<OrderBy> OrderBys, CriteriaBuilder builder) {
        List<Order> orders = Lists.newArrayList();
        for (OrderBy orderBy : OrderBys) {
            switch (orderBy.direction) {

            case ASC:
                orders.add(builder.asc(root.get(orderBy.columnOrProperty)));
                break;
            case DESC:
                orders.add(builder.desc(root.get(orderBy.columnOrProperty)));
                break;
            }

        }
        return orders;
    }

    // 构造Predicate
    final Predicate creatPredicate(Root<T> root,
            final Collection<SearchBean> searchBeans, CriteriaBuilder builder) {

        List<Predicate> predicates = Lists.newArrayList();
        for (SearchBean searchBean : searchBeans) {
            String[] names = StringUtils.split(searchBean.fieldName, ".");
            Path expression = root.get(names[0]);
            for (int i = 1; i < names.length; i++) {
                expression = expression.get(names[i]);
            }

            // logic operator
            switch (searchBean.operator) {
            case EQ:
                predicates.add(builder.equal(expression, searchBean.value));
                break;
            case LIKE:
                predicates.add(builder.like(expression, "%" + searchBean.value
                        + "%"));
                break;
            case GT:
                predicates.add(builder.greaterThan(expression,
                        (Comparable) searchBean.value));
                break;
            case LT:
                predicates.add(builder.lessThan(expression,
                        (Comparable) searchBean.value));
                break;
            case GTE:
                predicates.add(builder.greaterThanOrEqualTo(expression,
                        (Comparable) searchBean.value));
                break;
            case LTE:
                predicates.add(builder.lessThanOrEqualTo(expression,
                        (Comparable) searchBean.value));
                break;
            case NEQ:
                predicates.add(builder.notEqual(expression,
                        (Comparable) searchBean.value));
                break;

            }
            if (predicates.size() > 0) {
                return builder.and(predicates.toArray(new Predicate[predicates
                        .size()]));
            }
        }
        return builder.conjunction();
    }







