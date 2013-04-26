---
layout: post
title: "appfuse startup 的一些问题"
description: ""
category: 
tags: [jee, appfuse]
---
{% include JB/setup %}



##tomcat数据库连接问题
用appfuse建立个基本的startup项目，在tomcat 7 运行后发现报如下错误

>registered the JDBC driver \[oracle.jdbc.driver.OracleDriver\] but failed to unregister it when the web application was stopped. To prevent a memory leak, the JDBC Driver has been forcibly unregistered.

上网查找有人说是新版tomcat的问题，有两种解决方案

1  将数据库的驱动包放到tomcat的lib目录中。

2  tomcat中启动了一个内存监听，停止此监听即可，如下
  `<Listener className="org.apache.catalina.core.JreMemoryLeakPreventionListener"/>`

事实上，这两种方法对此都无效，我想这个错应该是由于数据库连接池导致的。
dbcp有个bug,见[DBCP-332](https://issues.apache.org/jira/browse/DBCP-332),现在这个bug不知道修复木有。我的解决方法是,修改了dbcp连接池的配置文件`applicationContext-resources`。改成下面这样就可以了。

    <bean id="dataSource" class="org.apache.commons.dbcp.BasicDataSource" destroy-method="close">
            <property name="driverClassName" value="${jdbc.driverClassName}"/>
            <property name="url" value="${jdbc.url}"/>
            <property name="username" value="${jdbc.username}"/>
            <property name="password" value="${jdbc.password}"/>
            <property name="maxActive" value="100"/>
            <property name="maxWait" value="1000"/>
            <property name="poolPreparedStatements" value="true"/>
            <property name="defaultAutoCommit" value="true"/>
        </bean>

##中文乱码问题
这个问题是maven的native2ascii插件的问题。其实也是配置的问题导致的。讲pom.xml文件中的配置改一下就ok了。

        <resource>
                <directory>src/main/resources</directory>
                <excludes> 
                    <exclude>ApplicationResources_de.properties</exclude> 
                    <exclude>ApplicationResources_fr.properties</exclude> 
                    <exclude>ApplicationResources_ko.properties</exclude> 
                    <exclude>ApplicationResources_nl.properties</exclude> 
                    <exclude>ApplicationResources_no.properties</exclude> 
                    <exclude>ApplicationResources_pt*.properties</exclude> 
                    <exclude>ApplicationResources_tr.properties</exclude> 
                    <exclude>ApplicationResources_zh*.properties</exclude> 
                    <exclude>applicationContext-resources.xml</exclude>
                    <exclude>displaytag_zh*.xml</exclude>
                </excludes> 
                <filtering>true</filtering>
        </resource>

##appfuse maven plugin
网上基本上都查不到model生成时自定义包的方法，查看了下源代码，其实配置也挺简单的。model的生成，在pom.xml文件中修改一下 appfuse-maven-plugin的插件的配置。

    <componentProperties>
            <implementation>annotationconfiguration</implementation>
            <revengfile>src/main/resources/hibernate.reveng.xml</revengfile>
            <packagename>xx.xx.xx.model.subpackage</packagename>
     </componentProperties>

hibernate.reveng.xml不配置的话回自动在test里面生产一个默认的文件。这个是用来配置生成那些表的，网上讲的比较详细。
