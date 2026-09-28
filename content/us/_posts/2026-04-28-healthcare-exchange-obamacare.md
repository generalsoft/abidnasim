---
layout: post
title: Healthcare Exchange — Obama Care Initiative
description: Designed and built a Healthcare Exchange platform under the Affordable Care Act, integrating EDI X12 transactions with Dynamics CRM and Azure cloud.
date: '2026-04-28 09:00:00'
tags: [Healthcare, Azure, Dynamics CRM, EDI, HIPAA]
section: work
image: /assets/content/work/healthcare-exchange.svg
image_alt: Healthcare Exchange Platform Architecture
permalink: /work/healthcare-exchange-obamacare/
---

## Context

In 2013, the Affordable Care Act ("Obama Care") mandated states to establish Health Insurance Exchanges — online marketplaces where individuals and small businesses could compare and purchase health plans. I was brought in to design and build a Healthcare Exchange for the state of Oregon, replacing legacy 5010 EDI processing with a modern, cloud-enabled platform.

The system needed to handle sensitive HIPAA-protected transactions at scale, integrate with multiple insurance carriers, and provide a consumer-facing portal backed by Dynamics CRM.

## Goal

> Build a state-level Healthcare Exchange that processes EDI X12 transactions, enforces geo-spatial business rules, and delivers plan comparisons through a CRM-powered portal.

Key requirements included:

- Processing EDI X12 837 (Claims), 835 (Remittance), 834 (Enrollment), and 270/271 (Eligibility) transactions
- Porting legacy 5010 implementations to BizTalk 2013
- Integrating Trizetto Facets for payer-side processing
- Delivering HTML5 EDI viewers and Windows Phone companion apps
- Enforcing business rules based on geo-spatial criteria

## Approach

I architected the solution around four pillars:

1. **EDI Processing Pipeline**  
   Refactored and ported 5010 implementations to BizTalk 2013, leveraging the ESB 2.2 Toolkit for canonical message routing. All HIPAA-mandated X12 transaction sets were validated, transformed, and routed through a centralized broker.

2. **CRM-Powered Front-End**  
   Extended Dynamics CRM with custom IFRAME forms using the Xrm.Page and Xrm.Utility SDK. Customized the Ribbon (RibbonDiffXml) to expose plan comparison workflows directly within the CRM interface.

3. **Cloud Document Routing**  
   Deployed document routing on Azure for EDI transactions, enabling elastic scale during open-enrollment surges. Used Azure Service Bus for reliable messaging between on-premises BizTalk and cloud-hosted services.

4. **Geo-Spatial Business Rules**  
   Implemented business rules that evaluated plan eligibility based on applicant location data, integrating with GIS services for coverage-area validation.

## Challenges

- HIPAA compliance required end-to-end encryption and audit trails across every transaction hop.
- The 5010-to-6020 EDI migration introduced breaking changes in segment definitions that required careful mapping.
- Open enrollment created extreme traffic spikes — the architecture had to scale from near-idle to full load within hours.
- Integrating Trizetto Facets with BizTalk required custom adapters for the MQSeries transport layer.

## Outcome

The Healthcare Exchange went live on schedule, processing hundreds of thousands of EDI transactions monthly. The HTML5 viewers eliminated reliance on desktop EDI tools, and the Windows Phone app gave field agents real-time access to enrollment data. Tableau dashboards provided state regulators with real-time visibility into exchange performance.

## Key takeaway

In healthcare integration, **compliance is not a checkbox — it's the architecture**. Designing for HIPAA, ICD coding, and auditability from day one avoided costly retrofits later.
