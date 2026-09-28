---
layout: post
title: Cruise Ship Fleet Integration — 30+ Ships
description: Integrated a new Property Management System across 30+ cruise ships, with GIS-based customs reporting, Dynamics CRM build automation, and AS/400 host integration.
date: '2026-04-15 10:00:00'
tags: [Integration, GIS, BizTalk, Dynamics CRM, AS/400]
section: work
image: /assets/content/work/cruise-fleet.svg
image_alt: Cruise Ship Fleet Integration
permalink: /work/cruise-fleet-integration/
---

## Context

In late 2012, a major cruise line headquartered in Miramar, Florida, needed to roll out a new Property Management System (PMS) across its entire fleet — over 30 ships, each essentially a floating hotel with thousands of guests. The PMS replacement touched every onboard system: reservations, housekeeping, dining, billing, and customs reporting.

I served as the Architect and Lead Developer, responsible for the integration layer that would connect the new PMS to the fleet's existing infrastructure — including JD Edwards on AS/400, Dynamics CRM, and GIS-based customs systems.

## Goal

> Replace the Property Management System across 30+ ships without disrupting onboard operations, while integrating customs reporting based on GIS data.

The integration had to:

- Synchronize PMS data with the corporate JD Edwards ERP running on IBM i (AS/400)
- Automate Dynamics CRM builds through TFS CI/CD
- Generate country-specific customs reports based on ship location (GIS)
- Support continuous deployment of approved builds using TFS Build Quality gates
- Handle intermittent connectivity — ships are offline while at sea

## Approach

1. **PMS Integration Hub**  
   BizTalk 2009/2010 served as the central integration broker. I used the ESB 2.0/2.1 Toolkit to build an itinerary-driven message router: when a ship docked and connected, BizTalk processed the accumulated batch of PMS transactions, prioritizing customs reports for the destination country.

2. **AS/400 Host Integration**  
   Wrote specifications for JD Edwards developers on the AS/400 side, then implemented the Host Integration layer using BizTalk's MQSeries adapter. The AS/400 received nightly PMS syncs and returned inventory and financial data.

3. **GIS-Based Customs Engine**  
   Ships crossing into a country's territorial waters automatically triggered customs report generation. I integrated GIS data to determine jurisdiction and applied the correct customs forms (based on IMO FAL conventions) per country.

4. **TFS CI/CD for Dynamics CRM**  
   Built a TFS plugin that promoted builds through quality gates — from Dev to QA to Production — automatically upon approval. This eliminated manual deployment errors and cut release cycles from days to minutes.

5. **Offline Resilience**  
   Designed a store-and-forward pattern: PMS transactions queued locally on each ship during voyages and flushed to the integration hub upon connectivity, with conflict resolution for concurrent updates.

## Challenges

- Maritime satellite internet is slow and expensive — batch sizes and compression had to be carefully tuned.
- Each country had its own customs form format, some requiring XML (e.g., UN/EDIFACT), others flat files.
- AS/400 integration required EBCDIC-to-ASCII conversion and fixed-width field parsing — a world apart from modern APIs.
- Coordinating PMS cutovers across 30 ships meant staggered rollouts over several months, with rollback plans per ship.

## Outcome

The PMS was successfully deployed across the entire fleet. Customs reports that previously took hours to compile manually were now generated automatically upon port arrival. The TFS CI/CD pipeline became the standard for all future CRM deployments in the organization.

## Key takeaway

**Integration at sea is integration at the edge.** Designing for disconnected operation, bandwidth constraints, and multi-jurisdictional compliance made this project a masterclass in resilient architecture.
