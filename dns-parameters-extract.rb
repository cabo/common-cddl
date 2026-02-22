require 'iana-registry'

DNS_RR = {}

REXML::XPath.each(IANA::Registry.load("dns-parameters").root,
    "//xmlns:registry[@id='dns-parameters-4']/xmlns:record",
    IANA::Registry::NS) do |x|
  typ = x.elements['type'].text
  value = x.elements['value'].text.to_i
  semantics = x.elements['description'].text
  if semantics && typ =~ /\A[-_A-Z0-9]+\z/
    DNS_RR[typ.gsub("-", "_")] = value
  end
end

puts DNS_RR.map { |t, v| "RR_#{t} = #{v}\n" }
