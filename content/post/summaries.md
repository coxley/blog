---
title: "Ship Code Faster: Summaries"
date: 2020-06-15T08:45:58-07:00
url: "/summaries"
draft: false
---

Do your changes take a long time to get accepted? Is there a lot of back and
forth with reviewers to understand context?

We limit round-trips to other systems in software — why not code review?
Consider reviewers as external systems. Answer questions up-front to avoid
unnecessary round-trips.

Assume reviewers aren’t as familiar with the code. Write down your thought
process instead of waiting for the right question to be asked. You will hone
your writing skills, and give context when someone runs `hg blame` a year from
now.

As a code reviewer, I spend a lot of time looking at diffs and enjoy being
thorough. Diffs with less context take longer to review and need more
revisions.

As a code writer, peers appreciate when summaries answer their questions from
the start. The closer to this approach, the less revisions needed to get
accepted. That's not because you won't make mistakes. But by doing this
exercise, you can catch most low hanging fruit before clicking "Submit".

The following is a template of what this diff summary *might* look like. Your
exact approach will vary as you experiment. I've included a full-example at the
bottom.

```md
Title: [project] Feature / Fix

One-liner that summarizes the problem / feature.

A paragraph giving extra context about the problem. Link to discussions,
repro example, or log output.

## Plan / Why?

Details that explain how the diff fits in, what the intentions are, and
plans. This helps reviewers think about how easy the future changes will
be to integrate.

## Why ABC?

## Why not XYZ?

## Caveats

General caveats about the approach

## Changes

* List of implementation details.
* Some of these might have an interesting anecdote.
  * Like this
```

# Describe the Problem

A diff cannot be reviewed before knowing “why”.

Act as if the reviewer lacks context by writing for someone that is unfamiliar
with the project. This will stop you from over- or under-explaining.

```sh
# Instead of this...
Adjusted filter for alarm

# Do this.
Exclude samples from client_id foo_bar.

Received several false-positives during on-call. The spikes
were from a particular client. After talking to their team,
found out this behavior is expected.

<links to the false positives>
```

```sh
# Instead of this...
Improve SQL performance

# Do this.
Updating these rows is in our critical path. We have been doing `N=len(rows)`
number of inserts. Job perf fluctuates because of this.

Use `INSERT ... ON DUPLICATE KEY UPDATE` instead.
```

# Explain Your Intentions

Code can be correct, but not in-line with the intent.

Statements like these let reviewers know about extra constraints to keep in mind:

* Update values in a way that limits the I/O we perform.
* Filter logs *only* from the `foo.bar` module.

# Itemize Your Approach

Connect the implementation to your intent.

Read your entire diff, top to bottom, to make this easier. No need to explain
every line — highlight the important themes. It should take less-than 20
minutes.

As a bonus, I always find things that I missed:

* bugs
* stale TODO’s
* commented code
* incorrect type annotations

# Play Devil’s Advocate

A lot.

You’re most familiar with the code.  Arguing against yourself will solidify why
you solved the problem this way... And may lead to better alternatives.

Speed up review by giving others the caveats and your justification. Include
benchmarks and data for your arguments. This can save several round trips.

Everything is a trade-off, and talking about them will make your software
better. Cases are made for each of these depending on the problem at hand.

* Readability vs. Performance
* Familiarity vs. Perfect Language
* Tailor-made vs. Open Source

# Test Plans

Make them reproducible.

For output from a command, include exact command used. For a browser
screenshot, include the exact URL. If it’s not straight-forward, take the time
to make it repeatable in some way.

This is especially helpful when on-boarding people to the project later. You
can use previous commits as documentation to contribute.

```sh
# Instead of this...
"Ran tests"

# Do this.
buck test //path/to/tests/...
python -m unittest  'test/*.py'
go test -run ''

--output--
```

# Full Example

```md
Title: [plantuml] Proxy Server

PlantUML is a diagram framework that will step-up our docs.

Compared to Graphviz:

* Syntax is nicer.
* More options for diagrams.
* Actively developed, with set of mature features.
* New features are added responsibly.
* Ability to use "style sheets" to change the color scheme.
  * Later we can have the server do this so you get a
    standard scheme for free

Home page: http://plantuml.com/index

<diagram.png>

## Why?

* Render anywhere we can communicate with Thrift/gRPC -- no need for Java.
  * Easier integrations:
    * Sphinx
    * Live editor

* Caching for free.
  * Same payload will render the same image.

## Doesn't PlantUML already have an HTTP server?

Yes! But it comes pre-packaged as a WAR. We need to build from source.

Thrift/gRPC gives us a strongly-typed API. Will use service discovery
instead of managing a VIP or availability.

## Why Go vs. Java?

I concede that Java would make it cheaper to hook into PlantUML APIs. But
no one working on this is familiar with Java. Using Go took one day for
the final product.

For performance, we start a pool of PlantUML processes in streaming mode.
This gets rid of JVM start-up time per-request which, IMO, was the real
concern.

## Changes

* Shorten / Expand implemented in Go
  * Limit the amount of communication between the forks.

* Server & CLI in same binary.
  * To simplify distribution and testing.

* Worker pool of N PlantUML Java procs
  * Unrecoverable errors will kill their proc, decrement running
    worker counter, spawn a new worker goroutine, then exit.
  * Requests will loadshed based on free / total workers.

* CLI command: `stress`
  * In waves starting at 2 QPS, and doubling each time, issue
    requests until receiving errors.
  * Simplifies benchmarking.
```
