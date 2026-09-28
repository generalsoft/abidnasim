---
layout: post
title: Enterprise Service Bus for a Major Bank
description: Architected and implemented an Enterprise Service Bus integrating Microsoft Dynamics, SQL Server, BizTalk, and SharePoint for a large financial institution.
date: '2026-04-22 08:00:00'
tags: [Banking, ESB, BizTalk, SQL Server, SharePoint]
section: work
image: /assets/content/work/esb-banking.svg
image_alt: Enterprise Service Bus Architecture Diagram
permalink: /work/esb-banking/
---

## Context

In 2005, a major New York-based bank needed to modernize its integration architecture. Disparate line-of-business systems — CRM, ERP, document management, and reporting — operated in silos, creating data inconsistencies and slowing down business processes. I was brought in to design and implement an Enterprise Service Bus (ESB) that would serve as the central nervous system for all enterprise applications.

## Goal

> Build an Enterprise Service Bus that unifies Dynamics CRM, SQL Server, BizTalk, and SharePoint into a cohesive integration fabric.

The ESB needed to:

- Provide canonical message routing between all line-of-business systems
- Process EDI transactions through standardized pipelines
- Enable real-time OLAP reporting with ADOMD.Net
- Deliver intelligent document processing through SharePoint and Office 2007
- Expose business rules through a centralized rules engine

## Approach

1. **Canonical Message Model**  
   Defined a common message schema that all systems would publish and subscribe to. BizTalk 2006 served as the broker, with custom pipelines for EDI, flat-file, and XML transformations.

2. **Business Rules Engine**  
   Externalized business logic into the BizTalk Rules Engine (BRE), allowing non-technical analysts to modify rules — such as credit risk thresholds and compliance checks — without touching code.

3. **Intelligent Business Framework**  
   Integrated SharePoint 2003/2007 with Office 2007's Intelligent Business Framework (IBF), enabling contextual data lookups directly within Word, Excel, and Outlook.

4. **Real-Time Analytics**  
   Built OLAP cubes with SQL Server 2005 Analysis Services and exposed them through ADOMD.Net, giving executives dashboards that refreshed on every EDI batch cycle.

## Challenges

- The bank's legacy EDI formats were poorly documented, requiring reverse-engineering of segment delimiters, loops, and qualifiers.
- BizTalk 2006 had memory-pressure issues under sustained EDI load — required careful host-throttling configuration.
- SharePoint 2003's object model was notoriously leaky; custom web parts needed aggressive disposal patterns.
- Coordinating schema changes across 7+ line-of-business teams demanded rigorous governance.

## Outcome

The ESB went live processing over 50,000 EDI transactions daily. OLAP dashboards reduced month-end close from 5 days to under 8 hours. The rules engine cut policy-change turnaround from weeks to hours.

## Key takeaway

**An ESB is only as good as its canonical model.** Investing heavily in the message schema upfront paid dividends every time a new system joined the bus. Governance isn't overhead — it's the product.
