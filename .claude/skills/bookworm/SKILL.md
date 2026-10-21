---
name: bookworm
description: Records content into the repo's wiki, library or knowledge base, or notes. Use when the user asks to put, save, add or record something in a wiki, library, knowledge base or notes: "add this to the wiki", "note this down", "put this in the library", "save this to the library", "record this in the knowledge base". Runs after the prompt's other tasks are finished, never before them.
---

Bookworm records content into a library. The `librarian` agent does all discovery and writing. This skill identifies the content, waits until the other work is done, hands off, and reports.

## 1. Identify what to record

Work out exactly what the user wants recorded. It is one of:
- explicit text in the prompt (quote it verbatim)
- outputs produced by other tasks in the prompt (note the file paths of each output)

Also keep the user's exact request quote, the sentence that asks for recording. Do not start recording yet.

Done when you can list every item to record, each as verbatim text or as a file path.

## 2. Defer until the other tasks are done

Finish every other task in the prompt first, including writing the files that bookworm will record. Bookworm runs last. Only move on when no other task remains open.

Done when all other tasks are finished and every output to record exists on disk.

## 3. Spawn the librarian

Spawn the `librarian` agent with the Agent tool, `subagent_type: librarian`. If that type is not available, use `subagent_type: general-purpose`, `model: haiku`, and the prompt "Read .claude/agents/librarian.md and follow it".

Pass in the prompt:
- the content: verbatim text, or the file paths of produced outputs
- the user's exact request quote
- the repo root: `/home/leandro/Documents/Skill-Factory`

Do not search for the library, read wiki pages, or write pages yourself. The librarian does all of that.

Done when the librarian has returned a report or a QUESTIONS block.

## 4. Handle QUESTIONS

If the librarian returns a QUESTIONS block, for example no library found or several candidates, ask the user those questions. Do not pick a candidate and do not create a new library unasked. When the user answers, resume the same librarian with SendMessage, using its agent name or ID, and pass the answer.

Repeat until the librarian returns a report instead of QUESTIONS.

Done when the librarian has recorded the content or the user has told you to stop.

## 5. Report

Report briefly, in this order:
- pages created and updated, with their paths
- any problems the librarian found elsewhere in the library
