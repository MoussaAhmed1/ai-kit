# System Architecture Standards Plugin

Smicolon company standards for system architecture and diagram-as-code.

## Installation

```bash
# Add Smicolon marketplace
/plugin marketplace add https://github.com/smicolon/ai-kit

# Install System Architecture plugin
/plugin install architect
```

## What's Included

### 1 Specialized Agent

- `@system-architect` - Eraser.io diagram-as-code specialist

### 2 Slash Commands

- `/diagram-create` - Generate Eraser.io diagrams (ERD, flowchart, cloud, sequence, BPMN)
- `/explain-code [target]` - Explain code with an analogy, ASCII diagram, walkthrough, architecture context, gotchas, and a tiny example. Optional target can be a file path, symbol, or concept.

### Supported Diagram Types

The agent can create:
- **Entity Relationship Diagrams (ERD)** - Database schema visualization
- **Flowcharts** - Process flows and decision trees
- **Cloud Architecture** - AWS, Azure, GCP infrastructure diagrams
- **Sequence Diagrams** - System interaction flows
- **BPMN Diagrams** - Business process modeling

All diagrams are generated as code using Eraser.io syntax.

## Usage

```bash
# Database schema
@system-architect "Create an ERD for our e-commerce database"

# Cloud infrastructure
@system-architect "Design AWS architecture for microservices platform"

# Process flow
@system-architect "Create a sequence diagram for user authentication flow"

# Business process
@system-architect "Create BPMN diagram for order fulfillment process"

# Explain code with diagram + walkthrough
/explain-code packs/architect/commands/diagram-create.md
/explain-code useAuth hook
/explain-code "React Suspense boundaries"
```

## Output

The agent generates diagram-as-code that you can:
1. Copy to [Eraser.io](https://www.eraser.io/)
2. Edit and refine visually
3. Export as PNG, SVG, or PDF
4. Version control alongside your code

## Documentation

See the main [Smicolon Claude Infra repository](https://github.com/smicolon/ai-kit) for complete documentation.
