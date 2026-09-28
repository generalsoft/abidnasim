---
layout: post
title: Clinical ERP with AI-Powered Fraud Detection & IoT Asset Tracking
description: Integrated a clinical ERP with AI-driven medical billing verification, fraud detection, and IoT-based asset tracking using HoloLens AR and Azure IoT Hub.
date: '2026-04-25 11:00:00'
tags: [AI, IoT, Azure, Healthcare, AR]
section: work
image: /assets/content/work/clinical-erp.png
image_alt: Clinical ERP with AI and IoT Architecture
permalink: /work/clinical-erp-ai-iot/
---

## Context

In late 2019, a clinical healthcare provider needed to modernize their ERP system. The existing setup had no automated verification of medical billing, no fraud detection on claims, and no visibility into the location of expensive medical assets. I was engaged as the Azure Architect and Tech Lead to deliver a comprehensive solution that combined AI, IoT, and Augmented Reality.

The project ran through December 2020, with the added complexity of remote collaboration during the pandemic.

## Goal

> Use AI to verify medical billing and detect fraud, while tracking physical assets in real-time with IoT and AR.

The solution needed to deliver:

- AI-powered verification of diagnostics against claims submissions
- Fraud detection models trained on historical billing patterns
- Real-time asset tracking with LoRaWAN, BLE, and 5G sensors
- Augmented Reality visualization of asset locations via Microsoft HoloLens
- Azure IoT Hub for device management and notification routing

## Approach

I designed a layered architecture spanning edge, cloud, and AI:

1. **AI Billing Verification**  
   Trained machine learning models to cross-reference diagnostic codes (ICD-10) against procedure claims (CPT/HCPCS). The model flagged anomalies — such as procedures inconsistent with diagnoses or statistically improbable billing patterns — for human review.

2. **Fraud Detection Pipeline**  
   Built a rules engine combined with anomaly detection that scored every claim in real time. High-risk claims were routed to an investigation queue, reducing false positives through continuous model retraining.

3. **IoT Asset Mesh**  
   Deployed a heterogeneous sensor network: LoRaWAN for long-range indoor tracking, BLE beacons for room-level precision, and 5G for high-throughput medical imaging devices. All telemetry flowed through Azure IoT Hub.

4. **HoloLens AR Experience**  
   Developed a HoloLens application that overlaid asset locations onto the wearer's field of view, enabling staff to locate equipment instantly. The AR layer consumed the same IoT telemetry, rendered as spatial anchors.

## Challenges

- Medical billing codes (ICD-10, CPT, HCPCS) have complex hierarchical relationships — the AI model needed domain-specific feature engineering.
- IoT sensor diversity (LoRaWAN, BLE, 5G, BT) required a unified ingestion pipeline with protocol-specific adapters.
- HoloLens development in 2019–2020 was still maturing — spatial mapping accuracy varied across clinical environments.
- COVID-19 lockdowns mid-project forced all collaboration, testing, and deployment to go fully remote.

## Outcome

The AI models reduced fraudulent claim payouts by an estimated 18% within the first six months. Asset utilization improved by 30% as staff could locate equipment in seconds via HoloLens rather than searching manually. The IoT mesh scaled to over 2,000 tracked assets across multiple clinic locations.

## Key takeaway

**AI in healthcare isn't about replacing clinicians — it's about catching what humans miss.** The fraud detection model found patterns invisible to manual review, while IoT gave operations teams superpowers they didn't know they needed.
