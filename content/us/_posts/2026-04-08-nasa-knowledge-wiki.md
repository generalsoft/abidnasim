---
layout: post
title: Knowledge Management Wiki for NASA
description: Designed and implemented enterprise knowledge management wikis for NASA, with single sign-on, compliance workflows, and integrated enterprise search — as the sole architect and developer.
date: '2026-04-08 07:00:00'
tags: [NASA, SharePoint, Knowledge Management, Silverlight, Enterprise Search]
section: work
image: /assets/content/work/nasa-wiki.svg
image_alt: NASA Knowledge Management Wiki
permalink: /work/nasa-knowledge-wiki/
---

## Context

In late 2008, NASA needed a knowledge management platform to capture and share institutional knowledge across its geographically distributed centers. Decades of mission-critical knowledge lived in silos — individual hard drives, email archives, and the memories of retiring engineers. I was brought in as the sole Architect and Developer to design and build the solution on SharePoint Server 2007 (MOSS).

## Goal

> Build a knowledge management wiki platform for NASA that captures institutional knowledge, enforces compliance, and makes everything discoverable through enterprise search.

The platform required:

- Wiki-based knowledge capture with rich media support (Silverlight, AJAX)
- Single sign-on across internet, extranet, and intranet boundaries
- Configurable compliance workflows for content approval
- Enterprise search with custom content migration web parts
- Excel Services integration for live data within wiki pages

## Approach

As the sole architect and developer, I owned the full stack:

1. **Wiki Foundation**  
   Extended SharePoint's built-in wiki capabilities with custom web parts for Silverlight-based diagrams, AJAX-driven data grids, and Excel Services embeds. Engineers could create rich documentation pages combining text, live data, and interactive visualizations.

2. **Single Sign-On (SSO)**  
   Implemented a complex SSO architecture spanning three security perimeters — internet (public knowledge base), extranet (contractor access), and intranet (internal NASA networks). Used SharePoint's SSO provider with custom token validation for cross-boundary authentication.

3. **Compliance Workflows**  
   Built configurable approval workflows using SharePoint Designer and custom C# workflow activities. Content went through staged reviews — peer review, technical accuracy, security classification — before publication. Workflow routing was metadata-driven, allowing each NASA center to define its own approval chain.

4. **Enterprise Search**  
   Configured MOSS Enterprise Search to crawl all wiki content, document libraries, and external file shares. Built custom Content Migration Web Parts that allowed bulk import of legacy documents with automatic metadata extraction.

5. **Excel Services Integration**  
   Published mission data spreadsheets as interactive Excel Services web parts, allowing wiki readers to filter and pivot live data without leaving the page.

## Challenges

- NASA's security requirements were exceptionally strict — cross-boundary SSO needed ITAR and export-control compliance reviews.
- SharePoint 2007's wiki capabilities were rudimentary; building a rich editing experience required deep customization of the SPWebPartManager and safe-control entries.
- Content migration from legacy systems (Lotus Notes, shared drives) was messy — inconsistent metadata, broken links, and duplicate documents.
- As the sole developer, I had to balance feature development with documentation and training for NASA staff.

## Outcome

The wiki platform was deployed across multiple NASA centers. Over 10,000 knowledge articles were captured and indexed within the first year. The compliance workflows ensured that mission-critical documentation passed proper reviews before publication — something the previous ad-hoc system could never guarantee.

## Key takeaway

**Knowledge management isn't a technology problem — it's an adoption problem.** The biggest success factor wasn't the SharePoint customization; it was the 390-page training manual I wrote and the hands-on sessions I ran with NASA engineers. Great tools unused are worthless.
