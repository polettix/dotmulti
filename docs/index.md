---
title: Howdy!
layout: default
---

{% for post in site.posts %}	
<h3><small>{{ post.date | date: "%B %e, %Y" }}</small> <a href="http://mypage.github.com{{ post.url }}#disqus_thread"></a></small> - <a href="{{ site.baseurl }}{{ post.url }}">{{ post.title }}</a></h3>	
{% endfor %}

{{ site.time | date_to_rfc822 }}
