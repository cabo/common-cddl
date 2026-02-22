#!/usr/bin/env ruby -Ku
# extract.rb — extract CDDL from an enum-style IANA registry

require 'iana-registry'

class Array
  def only
    if size == 1
      first
    else
      raise ArgumentError, "*** should be single-element array: #{inspect}"
    end
  end
end

# Which registry group and which registry in there are we assigning from
REG_GROUP = "cose"
REG_NAME = "algorithms"

# Retrieval URI for REG_GROUP, retrieval parameters
IANA_XML = "https://www.iana.org/assignments/#{REG_GROUP}/#{REG_GROUP}.xml"
ACCEPT_XML = {"Accept" => "application/xml"}

# XPath for REG_NAME, XPath parameters
EXTRACT_XPATH = "//xmlns:registry[@id='#{REG_NAME}']/xmlns:record"
NS = {"xmlns" => "http://www.iana.org/assignments"}

# Retrieve registry group; extract records that are neither Unassigned nor Reserved
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

# Find and warn about duplicates (possibly duplicate after underscore processing)
names = Set[]
entries.each do |n, v|
  if names.include?(n)
    warn "; ** duplicate name: #{n}"
  end
  names << n
end

# Output choice line
puts "#{REG_NAME} = #{names.to_a.join(" / ")}"
# Output one line each for choices
entries.each do |n, v|
  puts "#{n} = #{v}"
end
