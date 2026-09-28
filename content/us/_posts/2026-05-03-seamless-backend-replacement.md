---
layout: post
title: Seamless Backend Replacement
description: I worked on this in 1999. Replaced a backend transparently for the front-end.
date: '2026-05-03 11:00:00'
tags: [Project, RDBMS]
section: work
image: /assets/content/work/NdPHR.jpg
image_alt: Expo Booth Layout System
permalink: /work/seamless-backend-replacement/
---

## Context

In 1999, my client, an exhibitions management company, was running a third party product namely, ExpoCad, to manage exhibition space on desktops. The product used an xBase as the backend. An executive decided to publish the exhibition space online using a Java pluggin, not realizing the increased volumes could not be handled by the backend. So the logical option was to change the backend with something scalable, like Oracle. However, the vendor declined to make the upgrade. I was taked to do just that, subject to the condition that **the front-end should not notice the change**.

## Goal

> Replace the backend without forcing any front-end changes.

The migration needed to preserve:

- Existing API contracts and payload formats
- Business-critical query behavior
- Acceptable latency under normal load
- Operational continuity during cutover

## Approach

I designed a compatibility-first rollout with three tracks in parallel:

1. **Contract mirroring**  
   We documented current request/response semantics and implemented equivalent behavior in the new backend so client code stayed untouched.

2. **Database translation layer**  
   The new service mapped old access patterns to the replacement RDBMS model, including edge-case handling around nullability, sorting, and joins.

3. **Phased traffic switch**  
   We ran shadow validation and staged rollout gates to compare results between old and new paths before full cutover.

## Challenges

- Legacy behavior was under-documented and partly encoded in query side effects.
- A few front-end screens relied on implicit ordering that was not guaranteed by default in the new stack. xBase is a record based RDBMS. Oracle is/was based on SQL. 
- Operational confidence required side-by-side checks for a sustained period, not just spot tests.

## Outcome

The backend was replaced transparently, with no required front-end rewrite and no user-visible disruption during the transition window. It was a solo project. I had the prototype working in two months.

## Key takeaway

When replacing foundational systems, **compatibility is a product feature**. Treating behavior parity as a first-class deliverable made the port safer and faster overall.
