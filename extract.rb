#!/usr/bin/env ruby -Ku
# coding: utf-8
require 'rexml/document'
require 'open-uri'
require 'open-uri/cached'
require 'yaml'

class Array
  def only
    if size == 1
      first
    else
      raise ArgumentError, "*** not alone: #{inspect}"
    end
  end
end

IANA_XML = "https://www.iana.org/assignments/cose/cose.xml"

ACCEPT_XML = {"Accept" => "application/xml"}

EXTRACT_XPATH = "//xmlns:registry[@id='algorithms']/xmlns:record"
NS = {"xmlns" => "http://www.iana.org/assignments"}

badchar = Set[]
xml_src = URI(IANA_XML).open(ACCEPT_XML).read
doc = REXML::Document.new(xml_src)
entries = REXML::XPath.each(doc.root, EXTRACT_XPATH, NS).map {|el|
  n = el.get_elements("name").only.texts().join
  v = el.get_elements("value").only.texts().join
  # XXX: Any other filtering we want?
  if n !~ /\AUnassigned\z/i && n !~ /\AReserved/i
    n = n.split.join("_")
    if n =~ /([^-a-z0-9_])/i
      badchar << $1
    end
    n.gsub!(/_*[^-a-z0-9_]_*/i, "_")
    v = Integer(v)
    [n, v]
  end
}.compact

warn "; ** Non-name characters in <name>: #{badchar.to_a}" unless badchar == Set[]

names = Set[]
entries.each do |n, v|
  if names.include?(n)
    warn "; ** duplicate name: #{n}"
  end
  names << n
end
puts "algorithms = #{names.to_a.join(" / ")}"

entries.each do |n, v|
  puts "#{n} = #{v}"
end


# puts entries.to_yaml
exit

def count_range(s)
  a, b = s.split("-").map {Integer(_1)}
  [a, if b
   b - a + 1
  else
    1
  end]
end

RANGES = [24, 0x100, 0x10000, 0x100000000, 0x10000000000000000]
RANGE_COUNTS = [0] * 5
RANGE_UNASSIGNEDS = [0] * 5
RANGE_LABELS = [0, 1, 2, 4, 8].map {"1+#{_1}"}

def to_range(val)
  i = 0
  while RANGES[i] <= val
    i += 1
  end
  i
end

REXML::XPath.each(doc.root, "/xmlns:registry/xmlns:registry[@id='tags']/xmlns:record", NS) do |x|
  value = x.elements['value']
  a, n = count_range(value.text)
  r = to_range(a)
  semantics = x.elements['semantics']
  if semantics.text
    RANGE_COUNTS[r] += n
  else
    RANGE_UNASSIGNEDS[r] += n
  end
end

puts "range  used     %                 free                total"
(0...5).each do |i|
  total = RANGES[i] - (i == 0 ? 0 : RANGES[i-1])
  ct = RANGE_COUNTS[i]
  ua = RANGE_UNASSIGNEDS[i]
  if total != ct + ua
    puts "huh"
  end
  s = "%0#4.2f" % (ct*100.0/total)
  puts "%d %s %5d %05s %20d %20d" % [i, RANGE_LABELS[i], ct, s, ua, total]
end
