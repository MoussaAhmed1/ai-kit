---
name: explain-code
description: Explain code with an analogy, ASCII diagram, execution walkthrough, architecture context, gotchas, and a tiny example. Optional argument - file path, symbol, or concept.
argument-hint: [file path | symbol | concept]
---

If `$ARGUMENTS` is provided, explain that target (file path, symbol, function, module, or concept). Otherwise, explain the code most recently discussed or read in this conversation.

When explaining code, always include:

1. **Start with an analogy**: Compare the code to something from everyday life so the concept is intuitive before the details.

2. **Draw a diagram**:
   - Use ASCII diagrams to show:
     - data flow
     - component hierarchy
     - request lifecycle
     - state transitions
     - module relationships
   - Prefer diagrams before detailed explanations.

3. **Walk through the code**:
   - Explain step-by-step what happens.
   - Describe what executes first, what calls what, and how data changes over time.
   - Use plain language instead of jargon when possible.

4. **Explain why this approach exists**:
   - What problem does this pattern solve?
   - Why might the author have chosen this implementation?
   - Mention tradeoffs and alternatives when relevant.

5. **Connect implementation to architecture**:
   - Explain how this code fits into the larger system, app flow, or design pattern.
   - If multiple files are involved, explain how they interact before diving into details.

6. **Highlight a gotcha**:
   - What's a common mistake or misconception developers run into with this pattern?
   - Mention edge cases, hidden behavior, or debugging traps.

7. **Performance notes**:
   - Mention performance implications, scalability concerns, unnecessary renders, expensive operations, memory usage, or optimization opportunities when relevant.

8. **Security considerations**:
   - Mention validation, sanitization, authentication, authorization, or data exposure concerns when relevant.

9. **Show a tiny example**:
   - Give a minimal, runnable snippet that demonstrates the core idea in isolation.

10. **Adapt depth to complexity**:
    - Simple code → concise explanation.
    - Complex systems → architecture-first explanation before implementation details.

Before explaining implementation details:

- Identify the framework, runtime, and architecture pattern being used.
- Mention related files/modules if they are important for understanding the flow.
- Infer project conventions when possible.

When possible, explain code in this order:

1. Why it exists
2. How the pieces connect
3. How execution flows
4. Important implementation details
5. Common pitfalls

If the explanation involves React, Next.js, Node.js, Django, APIs, databases, queues, caching, authentication, or async workflows:
- Explain both the developer experience and the runtime behavior.

## Style

- Keep the tone friendly and clear — like explaining to a teammate over coffee.
- Avoid jargon unless you define it the first time.
- Prefer short paragraphs and bullet points over walls of text.
- Focus on clarity over completeness.
- Use practical examples whenever possible.

## Format

Structure the response like this:

## The Big Picture (Analogy)
…

## Architecture Context
…

## Diagram
```text
[ASCII diagram here]
```

## Walkthrough
…

## Why This Approach
…

## Gotchas
…

## Performance & Security Notes
…

## Tiny Example
```text
[minimal runnable snippet]
```
