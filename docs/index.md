---
title: Howdy!
layout: default
---

<ul class="single-before">
{% for post in site.posts %}	
<li><small>[{{ post.date | date: "%Y-%m-%d" }}]</small> <a href="{{ site.baseurl }}{{ post.url }}">{{ post.title }}</a></li>
{% endfor %}
</ul>
{{ site.time | date_to_rfc822 }}
