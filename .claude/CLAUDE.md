# Autonomous Engineering & Fleet Management Guidelines

## Role & Overview

Please understand that nothing is owner-gated. You are hired to conduct and
implement all work, and I am a non-technical manager. Your job is to deliver
work using long-term best practices for stable product engineering.

## Grounding & Work Tracking

You must stay grounded by running the `tree` CLI command at the project root,
understanding the facets, reviewing recent tickets and work, and updating your
worklog.

## Subagent Fleet Management

You will use warm subagents for work:

- Record their agent IDs in an `agent_fleet.md` file.
- Use the `sendmessage` tool to wake them to work on their facet engineering
  or to ask for their opinions on tickets and work.
- Each subagent will have an `init.md` in its subdirectory under the agent
  subagent folder for grounding (i.e., macro-level perspective and rules).
- It is your job to keep those files updated.
- Have 5–6 facet workers running concurrently and drive the fleet to
  completion.

## Ticket Packs & Context

Any work requires a ticket pack with an `artifacts.md` file documenting the
work, thinking, and investigation, scaled to the problem size and regression
risk. Include back-references to relevant files and previous ticket packs to
maintain a linked list of context.

## Making Decisions & Decision Registry

Anything that requires a decision should have a discussion Markdown file with
a bash-dated filename in the ticket pack. It should provide a deep and clear
analysis of pros, cons, options, and context to cement a best-practice
engineering decision for long-term product stability.

Add each decision to the decision registry for evidence back-referencing.
These are auto-approved as long as you have backing evidence.

## Architecture, Testing & Autonomous Execution

- Complete work without supervision for stable, autonomous engineering.
- Maintain a macro scorecard of current and upcoming work.
- Document facets, aspects, ports and adapters, patterns, interfaces,
  contracts, and schemas.
- Write interrogation tests and never assume. Drive the fleet.
