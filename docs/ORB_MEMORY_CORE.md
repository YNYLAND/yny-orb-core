# ORB MEMORY CORE

Version: 0.1.0
Status: canonical draft

## Purpose

ORB MEMORY CORE is a shared cognitive memory architecture for SYSTEM, YNY CHAT and CORP. Modes do not own separate memories. Each mode receives a relevant projection of the same Actor memory according to its frame and execution policy.

## Memory layers

### 1. conversation_messages — discourse
Raw message stream. This preserves what was literally said.

### 2. session_summary_blocks — periodic raw-discourse summaries
Generated directly from the raw conversation stream. These summaries are independent of semantic-session boundaries and are not session closures.

Primary purposes:
- compress long conversation history;
- support later semantic retrieval;
- detect repeated topics/patterns that were not obvious in one moment;
- provide evidence for monthly/periodic profile re-analysis.

### 3. memory_events — semantic event stream
Orb's 'notes in the margins': observed or inferred events that changed the working model of the Actor, project or session.

Examples:
- session_opened
- goal_set
- context_changed
- decision
- research_started
- research_completed
- action_started
- action_completed
- result
- blocked
- paused
- resumed
- reframed
- session_closed

Events may point to `context_session_id` when they belong to a semantic session.

### 4. context_sessions — parallel semantic sessions
A semantic session is a goal/process line, not a technical chat session. Several semantic sessions may be active or paused inside the same conversation stream.

A session stores:
- title;
- goal;
- context;
- current and target state;
- lifecycle status;
- parent relation;
- final result and closure reason.

A session closes when its goal is achieved, cancelled, reframed, merged or consciously closed by the Actor. Closure is recorded on the session itself.

### 5. session_checks — checks / open loops
Checks describe the states or outcomes that may be required to complete a semantic session.

A check may be:
- open;
- potential;
- actionable;
- in progress;
- completed;
- skipped;
- cancelled;
- blocked.

Each check may name `capability_keys` from ORB MAX that can help close it. This is the bridge between Actor memory and the ORB MAX ontology.

### 6. closed-session results — Actor achievements
The final result of a completed semantic session is an achievement/state transition, not a conversational summary.

Examples:
- created a project;
- published a book;
- deployed a token;
- launched an initiative;
- created a site;
- completed a research package.

These results can later be analysed separately from what the Actor merely discussed or intended.

### 7. profile_memory — durable Actor state
Long-lived confirmed or useful profile state. It should not be polluted with every passing interest. Transient interests can remain in discourse/context sessions until they prove persistent or become confirmed.

## Future periodic chronicle

A future Profile Chronicle pass can periodically re-read:
- raw-discourse summaries;
- memory events;
- open sessions;
- closed-session results;
- durable profile memory;
- capability changes and transactions;
- linked entities/artifacts.

Its purpose is not just to summarize a month, but to detect accumulated patterns, recurring vectors, relationships between seemingly separate projects and old unfinished goals that have become actionable.

Derived conclusions should distinguish:
- `observed` — directly happened;
- `confirmed` — Actor explicitly confirmed;
- `inferred` — Guide inferred it;

and inferred conclusions should carry confidence and provenance.

## Runtime rule

Orb does not answer from raw discourse alone. Guide Core should interpret discourse into context, select the relevant semantic session(s), open checks, Actor state and ORB MAX branch, then build a compact Guide Packet for the flagship model.

**Listen to discourse. Answer context. Preserve the Actor's will. Drive manifested goals toward concrete results.**
