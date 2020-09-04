---
name: Missing Virtual DOM Property [English]
about: Request to add a missing standard DOM property type definition.
title: 'Add [PROPERTY_NAME] DOM property'
labels: 'Priority: Medium, Status: Pending, Type: Enhancement'
assignees: ''
---

<!--
If you are asking of adding multiple properties, please propose them in multiple issues.

Make sure the property you are proposing is a standarnd DOM property based on the W3C DOM Specification (https://dom.spec.whatwg.org) or W3C HTML Specification (https://html.spec.whatwg.org/).
-->

<!--
Example:

[W3C DOM specification](https://dom.spec.whatwg.org/#dom-element-classname) specifies `className` property as a standard property of `Element` interface.
-->

#### Proposed Type Definition

<!--
Tell us your opinion about the best type representation of the proposed property.

Example:

```purs
newtype ClassName = ClassName String

type ElementProperties r
  = ( className :: ClassName -- | Reflects the `class` attribute.
    | r
    )
```
-->
