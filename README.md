# GraphQL Beautifier (Burp Suite extension)
Works like [JSONBeautifier](https://github.com/NetSPI/JSONBeautifier) but for GraphQL and makes requests more 
readable. Uses [graphql-ruby](https://github.com/rmosolgo/graphql-ruby) library.

Converts this: 

<img src="https://raw.githubusercontent.com/zidekmat/graphql_beautifier/master/imgs/img_before.png" alt="" data-canonical-src="" width="600" height="400" />

into this:

<img src="https://raw.githubusercontent.com/zidekmat/graphql_beautifier/master/imgs/img_after.png" alt="" data-canonical-src="" width="600" height="400" />

# Installation
1. [Setup JRuby environment inside Burp](https://portswigger.net/burp/help/extender#options_rubyenv), I got it working with JRuby complete .jar file from [here](http://jruby.org/download)
2. Navigate to your installation folder and run:
```bash
git clone --recursive https://github.com/zidekmat/graphql_beautifier
cd graphql_beautifier && sed -i "s#BLAH_BLAH_BLAH#$(pwd)/graphql-ruby/lib#" graphql_beautifier.rb
```
3. Load `graphql_beautifier.rb` as extension inside Burp
