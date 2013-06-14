---
layout: page
title: 沉醉往昔少年时!
tagline: 咖啡煮萝卜的小屋
---
{% include JB/setup %}

  {% for post in site.posts %}
   <div class="well">
      <strong><a href="{{ post.url }}">{{ post.title }}</a></strong>
      
      <p>{{ post.excerpt}}</p>
      
    </div>
  {% endfor %}




