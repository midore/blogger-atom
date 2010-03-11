#!/usr/local/bin/ruby19
# coding: utf-8
#
# run-blogger-atom.rb
#
# Get Label
# $ ./run-blogger-atom.rb -f file.xml -label music
#
# Get range
# $ ./run-blogger-atom.rb -f file.xml -min 2009/12/1 -max 2009/12/31
# url => http://xxx.blogspot.com/feeds/posts/default?published-min=2009-11-30T23:59:00&published-max=2010-01-01T00:00:00

# lang
exit unless Encoding.default_external.name == 'UTF-8'

# edit your blogurl and blogid
blogurl = 'xxx.blogspot.com'
blogid = 'xxxxxxxxxx'

# argv
arg = ARGV
exit if arg.empty?
arg.delete("")
k, h = nil, Hash.new
h[:@blogid], h[:@blogurl] = blogid, blogurl
arg.each{|x| m = /^-(.*)/.match(x); (m) ? (k = ("@"+m[1]).to_sym; h[k] = nil) : h[k] ||= x}

# start
require 'open-uri'
require 'time'
require 'rexml/document'
require 'blogger-atom'

b = BloggerGetHttp::AtomRss.new()
h.each{|k,v| b[k] = v} 
exit if (b[:@f].nil? or b[:@blogid].nil? or b[:@blogurl].nil?)
b.base

