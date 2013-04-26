---
layout: post
title: "maven plugin的开发"
description: ""
category: 
tags: [maven, jee, plugin]
---
{% include JB/setup %}

#maven插件开发

##quick start

现在习惯于使用maven进行构建和管理项目，有时在实际工作中需要开发自己需求的maven plugin,其实maven 插件的看法还是比较简单的。下面介绍一下简单的实践。

1  创建个目录，并在此目录下执行下面的maven命令，就会在该目录下创建一个项目

    mvn archetype:create -DgroupId=com.gt.maven -DartifactId=maven-hello-plugin -DarchetypeArtifactId=maven-archetype-mojo

2  进入maven-hello-plugin目录,创建一个eclipse工程,你喜欢idea也行。创建的命令是

    mvn eclipse:eclipse //eclipse 工程
    mvn idea:idea //idea工程

3   导入工程到eclipse货idea中进行开发，实践开始了。

    package com.gt.maven;

    import org.apache.maven.plugin.AbstractMojo;
    import org.apache.maven.plugin.MojoExecutionException;
    import org.apache.maven.plugin.MojoFailureException;

    /**
     * @goal talk
     */
    public class HelloMojo extends AbstractMojo {

        /**
         * @parameter expression="${talk.words}" default-value="Hello world!"
         */
        
        public String words;
        @Override
        public void execute() throws MojoExecutionException, MojoFailureException {
            // TODO Auto-generated method stub
            this.getLog().info(words);
        }

    }


4   将插件安装到本地repository,在项目根目录下执行`mvn clean install`

5   检验下自己的成果,执行下下面命令。首先使用默认参数

    mvn com.gt.maven:maven-hello-plugin:1.0-SNAPSHOT:talk

可以看到结果是：

    [INFO] Scanning for projects...
    [INFO]                                                                         
    [INFO] ------------------------------------------------------------------------
    [INFO] Building maven-hello-plugin Maven Mojo 1.0-SNAPSHOT
    [INFO] ------------------------------------------------------------------------
    [INFO] 
    [INFO] --- maven-hello-plugin:1.0-SNAPSHOT:talk (default-cli) @ maven-hello-plugin ---
    [INFO] Hello world!
    [INFO] ------------------------------------------------------------------------
    [INFO] BUILD SUCCESS
    [INFO] ------------------------------------------------------------------------
    [INFO] Total time: 0.229s
    [INFO] Finished at: Thu Apr 25 17:08:59 CST 2013
    [INFO] Final Memory: 3M/554M
    [INFO] ------------------------------------------------------------------------

使用参数

    mvn com.gt.maven:maven-hello-plugin:1.0-SNAPSHOT:talk -Dtalk.words="sb"

结果如下

    [INFO] Scanning for projects...
    [INFO]                                                                         
    [INFO] ------------------------------------------------------------------------
    [INFO] Building maven-hello-plugin Maven Mojo 1.0-SNAPSHOT
    [INFO] ------------------------------------------------------------------------
    [INFO] 
    [INFO] --- maven-hello-plugin:1.0-SNAPSHOT:talk (default-cli) @ maven-hello-plugin ---
    [INFO] sb
    [INFO] ------------------------------------------------------------------------
    [INFO] BUILD SUCCESS
    [INFO] ------------------------------------------------------------------------
    [INFO] Total time: 0.228s
    [INFO] Finished at: Thu Apr 25 17:10:56 CST 2013
    [INFO] Final Memory: 3M/554M
    [INFO] ------------------------------------------------------------------------

##插件开发过程的相关说明

###MOJO

Maven 通过插件动作完成大多数构建任务。可以把 Maven 引擎认为是插件动作的协调器。插件中的每个任务goal称作一个 Mojo（Maven plain Old Java Object）。项目中每一个Mojo都要实现org.apache.maven.plugin.Mojo接口，上面的插件示例的Mojo通过扩展org.apache.maven.plugin.AbstractMojo类实现了该接口。Mojo提供过了如下的方法：
    void setLog( org.apache.maven.monitor.logging.Log log )

每一个Mojo实现都必须提供一种方法让插件能够和某个特定目标的过程相交流。该目标成功了么？或者，是否在运行目标的时候遇到了问题？当Maven加载并运行Mojo的时候，它会调用setLog()方法，为Mojo实例提供正确的日志目标，以让你在自定义插件中使用。

    protected Log getLog()

Maven会在Mojo运行之前调用setLog()方法，然后你的Mojo就可以通过调用getLog()获得日志对象。Mojo应该去调用这个Log对象的方法，而不是直接将输出打印到标准输出或者控制台。

    void execute() throws org.apache.maven.plugin.MojoExecutionException

轮到运行目标的时候，Maven就会调用该方法。

Mojo接口只关心两件事情：目标运行结果的日志记录，以及运行一个目标。当编写自定义插件的时候，需要扩展AbstractMojo。AbstractMojo处理setLog()和getLog()的实现，并包含一个抽象的execute()方法。在扩展AbstractMojo的时候，你所需要做的只是实现execute()方法。

###Phase
Maven 对构建生命周期的固定理解包含了许多不同的阶段，如下表：


validate   |   验证  | 确保当前配置和POM的内容是有效的。这包含对pom文件树的验证。
:-----------|:--------|:---------------------------------------------
initialize | 初始化 |在执行构建生命周期的主任务之前可以进行初始化。
generate-sources |   生成源码  |  代码生成器可以开始生成在以后阶段中处理或编译的源代码。
process-sources | 处理源码 |   提供解析、修改和转换源码。常规源码和生成的源码都可以在这里处理。
generate-resources | 生成资源  |  可以生成非源码资源。通常包括元数据文件和配置文件。
process-resources |  处理资源  |  处理非源码资源。修改、转换和重定位资源都能在这阶段发生。
compile | 编译  | 编译源码。编译过的类被放到目标目录树中。
process-classes |处理类 |处理类文件转换和增强步骤。字节码交织器和常用工具常在这一阶段操作。
generate-test-sources   | 生成测试源码 |  mojo可以生成要操作的单元测试代码。
process-test-sources   | 处理测试源码 | 在编译前对测试源码执行任何必要的处理。在这一阶段，可以修改、转换或复制源代码。
generate-test-resources | 生成测试资源 |  允许生成与测试相关的（非源码）资源。  
process-test-resources | 处理测试资源   | 可以处理、转换和重新定位与测试相关的资源。   
test-compile   | 测试编译  |  编译单元测试的源码。
test   | 测试  | 运行编译过的单元测试并累计结果。
package | 打包 | 将可执行的二进制文件打包到一个分布式归档文件中，如
pre-integration-test |   前集成测试、准备集成测试。这种情况下的集成测试是指在一个受到一定控制的模拟的真实部署环境中测试代码。这一步能将归档文件部署到一个服务器上执行。 |&nbsp;
integration-test  |   集成测试  |  执行真正的集成测试。
post-integration-test |  后集成测试、解除集成测试准备。这一步涉及测试环境重置或重新初始化。| &nbsp;
verify | 检验 | 检验可部署归档的有效性和完整性。过了这个阶段，将安装该归档。
install | 安装  | 将该归档添加到本地Maven目录。这一步让其他可能依赖该归档的模块可以使用它。
deploy  | 部署  | 将该归档添加到远程Maven目录。这一步让这个工件能为更多的人所用。

###插件组成

每一个mojo都由一些注解annotation来描述，这些注解是在java类的上面标注。常用的几个注解如下：

`execute：注解形式：`

    a), @execute phase="<phaseName>" lifecycle="<lifecycleId>";
    b), @execute phase="<phaseName>"
    c), @execute goal="<goalName>"

当这个目标goal被调用时，它会先调用一个平行的生命周期，在制定的阶段结束。如果插件没有被指定阶段，这一目标将会单独执行。

`goal：注解形式：@goal <goalName>`

用户在命令行下直接调用插件的目标goal，或者在项目的pom文件中通过配置调用这个goal。

`phase：注解形式：@phase <phaseName>`

绑定这个mojo到标准构建生命周期里对应的阶段。

对于一个mojo里的变量参数，也有一些常用的注解：

`configuration：注解形式`

    @parameter expression="${aSystemProperty}" default-value="${anExpression}"

对参数指定一个计算表达式、在mojo构建时将计算结果注入到此变量中，同时也可以给定一个默认值。这个参数值也可以在pom文件中予以配置。


##参考
[Maven: The Definitive Guide](http://www.sonatype.com/books/maven-book/reference/ )

[Mojo api](http://maven.apache.org/developers/mojo-api-specification.html)

[Maven plugin developer center](http://maven.apache.org/plugin-developers/index.html)

[浅谈maven插件开发](http://www.taobaotesting.com/blogs/qa?bid=4964)






