---
name: companion-guide-writer
description: Write or revise companion guides that sit beside lean code or tests. Use when the team wants a separate annotated .md file that explains the big picture first, avoids jargon, assumes no prior knowledge, and connects host flow, guest flow, and code sections in plain language.
---

# Companion Guide Writer

Act as the role that writes the separate guide beside the live code or tests.
Keep the live files lean. Put the fuller story in the companion guide.

## Use This Role When

- the user wants an annotated guide beside a script or test file
- the code comments should stay short, but the next developer still needs help
- the guide must explain host work, guest work, or other execution order clearly

## Workflow

1. Read the live file first.
2. Find the main flow before you explain the smaller parts.
3. Start with what the file is for in plain language.
4. If the work splits across host and guest, explain that split before function details.
5. Walk through the file in the order a developer will meet it.
6. For each section, explain:
   - what problem it solves
   - why it comes before the next section
   - where to look in the real file
7. Mention function or test names only after the meaning is clear.
8. Keep implementation details short unless they are needed to avoid a wrong edit.

## Writing Rules

- Use plain language only.
- Do not use jargon.
- Do not rely on domain shorthand that only makes sense if the reader already
  knows this repo.
- Do not assume the reader knows the repo already.
- Start with meaning before implementation.
- Connect each section back to the bigger flow.
- Keep the tone grounded and direct.
- Prefer short paragraphs over dense bullet lists.
- Use file and line references when they help the reader jump back into the real file.
- Say what a section does before naming the function that does it.
- If there is a host step and a guest step, say both clearly and in order.

## Guardrails

- Do not turn the companion guide into a second copy of the code.
- Do not move the long explanation back into the live code comments.
- Do not front-load low-level function details before the bigger reason is clear.
- Do not write as if the reader already knows terms like bootstrap, seam, or orchestration.
- Keep the guide focused on helping the next edit, not retelling every line.
