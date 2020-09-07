---
name: Missing Virtual DOM Output [English]
about: Request to add a missing standard DOM event output type definition.
title: 'Add missing [OUTPUT_NAME] virtual DOM output'
labels: 'Priority: Medium, Status: Pending, Type: Enhancement'
assignees: ''
---

<!--
If you are asking of adding multiple outputs, please propose them in multiple issues.

Make sure the output you are proposing is a standarnd DOM event based on the following specifications:
- W3C HTML Events Index (https://html.spec.whatwg.org/multipage/indices.html#events-2)
- W3C HTML Media Events Summary (https://html.spec.whatwg.org/multipage/media.html#mediaevents)
- W3C HTML App Cache Events Summary (https://html.spec.whatwg.org/multipage/offline.html#appcacheevents)
- W3C HTML Drag and Drop Events Summary (https://html.spec.whatwg.org/multipage/dnd.html#dndevents)
- W3C DOM Specification (https://dom.spec.whatwg.org)
- W3C HTML Specification (https://html.spec.whatwg.org/).
- W3C UI Events Specification (https://www.w3.org/TR/uievents/)
-->

<!--
Example:

[W3C UI events specification](https://www.w3.org/TR/uievents/#event-type-click) specifies `click` event as a standard event which targeting `Element` interface.
-->

#### Proposed Type Definition

<!--
Tell us your opinion about the best type representation of the proposed output.

Example:

```purs
type ElementOutputs message r
  = ( onClick :: MouseClick -> message
    | r
    )
```
-->
