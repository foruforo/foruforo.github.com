---
layout: page
title: 沉醉往昔少年时!
tagline: 咖啡煮萝卜的小屋
---
{% include JB/setup %}
<div class="well">
  {% for post in site.posts %}
   <div class="hero-unit">
      <strong>{{ post.title }}</strong>
      
      <p>{{ post.excerpt }}</p>
      <a href="{{ post.url }}">more...</a>
    </div>
  {% endfor %}
</div>



