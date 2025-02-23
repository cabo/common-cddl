---
v: 3

title: >
  CDDL models for some existing RFCs
# abbrev: CDDL models from RFCs
docname: draft-bormann-cbor-rfc-cddl-models-latest
date: 2025-02-23 # 05 2024-08-27 # 04
keyword: CDDL models
cat: info
stream: IETF

pi: [toc, sortrefs, symrefs, compact, comments]

author:
  - name: Carsten Bormann
    org: Universität Bremen TZI
    street: Postfach 330440
    city: Bremen
    code: D-28359
    country: Germany
    phone: +49-421-218-63921
    email: cabo@tzi.org

venue:
  mail: core@ietf.org
  github: cabo/common-cddl

normative:
  STD90:
    -: json
#    =: RFC8259
  STD94:
    -: cbor
#    =: RFC8949
  RFC8610: cddl
  RFC9165: control1
  I-D.ietf-cbor-cddl-more-control: control2
informative:
  RFC7807: problem-old
  RFC8366: voucher
  RFC9457: problem-bis
  RFC9290: concise-problem
  RFC7071: reputon
  RFC9595: yang-sid
  IANA.cose:

--- abstract

A number of CBOR- and JSON-based protocols have been defined before
CDDL was standardized or widely used.

This short draft records some CDDL definitions for such protocols,
which could become part of a library of CDDL definitions available for
use in CDDL2 processors.  It focuses on CDDL in (almost) published
IETF RFCs.

--- middle

Introduction        {#intro}
============

(Please see abstract.)
Add in {{-cbor}} {{-json}}
{{-cddl}} {{-control1}} {{-control2}}

# CDDL definitions for (almost) published RFCs

This section is intended to have one subsection for each CDDL data
model presented for an existing RFC.
As a start, it is fleshed out with three such data models.

## RFC 7071 (Reputation Interchange)

{{Appendix H of RFC8610}} contains two CDDL definitions for {{RFC7071}},
which are not copied here.
Typically, the compact form would be used in applications using the
RFC 7071 format; while the extended form might be useful to
cherry-pick features of RFC 7071 into another protocol.

## RFC 8366 (Voucher Artifact for Bootstrapping Protocols)

{{RFC8366}} defines a data model for a "Voucher Artifact", which can be
represented in CDDL as:

~~~ cddl
{::include rfc8366.cddl}
~~~
{: #rfc8366 sourcecode-name="rfc8366.cddl" title="CDDL for RFC 8366"}

The two examples in the RFC can be validated with this little patchup
script:

~~~ shell
sed -e s/ue=/uQ=/ -e s/'"true"'/true/ | cddl rfc8366.cddl vp -
~~~

## RFC 9457 (Problem Details for HTTP APIs)

{{RFC9457}} defines a simple data model
that is reproduced in CDDL here:

~~~ cddl
problem-object = {
  ? type: preferably-absolute-uri
  ? title: text
  ? status: 100..599
  ? detail: text
  ? instance: preferably-absolute-uri
  * text .feature "problem-object-extension" => any
}

; RECOMMENDED: absolute URI or at least absolute path:
preferably-absolute-uri = ~uri
~~~
{: #rfc9457 sourcecode-name="rfc9457.cddl" title="CDDL for RFC 9457"}

Note that {{Appendix B of RFC9290}} also defines a CBOR-specific data
model that may be useful for tunneling {{RFC7807}} or {{RFC9457}} problem details in
{{RFC9290}} Concise Problem Details.

## RFC 9595 (YANG-SID)

{{RFC9595}} defines a data model for a
"SID file" in YANG, to be transported as a YANG-JSON instance.

An equivalent CDDL data model is given here:

~~~ cddl
{::include rfc9595.cddl}
~~~
{: #rfc9595 sourcecode-name="rfc9595.cddl" title="CDDL for RFC 9595"}

## Your favorite RFC here...

# CDDL definitions derived from IANA registries {#iana-defs}

Often, CDDL models need to use numbers that have been registered as
values in IANA registries.

This section is intended to have one subsection for each CDDL data
model presented that is derived from an existing IANA registry.
As a start, it is fleshed out with one such data model.

The intention is that these reference modules are update automatically
(after each change of the registry or periodically, frequent enough.)
Hence, this document can only present a snapshot for IANA-derived data
models.

The model(s) presented here clearly are in proof-of-concept stage;
suggestions for improvement are very welcome.

## COSE Algorithms Registry

The IANA registry for COSE Algorithms is part of the IANA cose
registry group {{IANA.cose}}.

The following automatically derived model defines some 70 CDDL rules
that have the name for a COSE algorithm as its rule name and the
actual algorithm number as its right hand side.
The additional first rule is a type choice between all these
constants; this could be used in places that just have to validate the
presence of a COSE algorithm number that was registered at the time
the model was derived.

This section does not explore potential filtering of the registry
entries, e.g., by recommended status (such as leaving out deprecated
entries) or by capabilities.

The names given in the COSE algorithms registry are somewhat irregular
and do not consider their potential use in modeling or programming
languages; the automatic derivation used here turns sequences of one
or more spaces and other characters that cannot be in CDDL names
(`[/+]` here) into underscores.

~~~ cddl
{::include-fold65left2 cose-algorithms.cddl}
~~~
{: #cose-algorithms sourcecode-name="cose-algorithms.cddl"
   title="CDDL for cose-algorithms Registry"}

IANA Considerations
==================

This document makes no requests of IANA.

However, the use of IANA registries for deriving CDDL (e.g., as in
{{iana-defs}}) is an active subject of discussion.




Security considerations
=======================

The security considerations of {{-cddl}}, {{-control1}}, {{-control2}}, {{-cbor}} and {{-json}} apply.
This collection of CDDL models is not thought to create new security
considerations.
Errors in the models could -- if we knew of them, we'd fix those
errors instead of explaining their security consequences in this
section.

--- back

{::include-all lists.md}

Acknowledgements
================
{: unnumbered}

TBD
