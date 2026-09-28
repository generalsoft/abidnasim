---
layout: post
title: Multi-Cloud IoT & Big Data Proof of Concept
description: Built cross-cloud IoT, Big Data, and Machine Learning POCs across Azure, AWS, GCP, and IBM Bluemix — from Raspberry Pi edge devices to cloud data lakes.
date: '2026-04-18 14:00:00'
tags: [Cloud, IoT, Big Data, Machine Learning, Azure]
section: work
image: /assets/content/work/multicloud-iot.svg
image_alt: Multi-Cloud IoT Architecture
permalink: /work/multicloud-iot-poc/
---

## Context

In early 2017, I was tasked with building a comprehensive set of Proof of Concepts (POCs) to evaluate cloud platforms for IoT, Big Data, and Machine Learning workloads. The goal was to compare Azure, AWS, GCP, IBM Bluemix (now IBM Cloud), and Alibaba Cloud across identical use cases — then recommend a strategic cloud adoption roadmap.

The POCs spanned edge computing (Raspberry Pi with LTE), message brokers (MQTT on Facebook, Azure, Adafruit IO), data lakes, and machine learning pipelines.

## Goal

> Evaluate and compare five cloud platforms for IoT ingestion, Big Data processing, and Machine Learning — using real hardware and real data.

Success criteria:

- Ingest telemetry from physical Raspberry Pi devices over SigFox and LoRaWAN
- Process streaming data with Hadoop (HDFS, Yarn, MapReduce)
- Build Data Lake pipelines with Azure Data Factory and AWS Glue
- Train and deploy ML models on each platform
- Automate IaaS lab management for reproducible environments

## Approach

I ran identical workloads across all platforms:

1. **Edge Layer**  
   Flashed Raspberry Pi devices with Raspbian, connected LTE modems, and configured SigFox and LoRaWAN gateways. Each Pi published MQTT messages to platform-specific brokers — Azure IoT Hub, AWS IoT Core, IBM Watson IoT, and Adafruit IO.

2. **Stream Ingestion**  
   MQTT telemetry was routed to each platform's streaming engine: Azure Stream Analytics, AWS Kinesis, Google Cloud Dataflow, and IBM Streaming Analytics. Latency and throughput were measured under identical payload sizes.

3. **Data Lake & Big Data**  
   Landed raw telemetry into each platform's data lake (Azure Data Lake Store, AWS S3, Google Cloud Storage). Ran Hadoop MapReduce jobs for aggregation and fed results into each platform's ML service.

4. **Machine Learning**  
   Trained identical regression models (predicting sensor drift) on Azure ML, AWS SageMaker, Google AI Platform, and IBM Watson Studio. Compared training time, deployment latency, and cost.

5. **IaaS Automation**  
   Scripted VM provisioning and teardown using each platform's CLI/SDK, enabling reproducible lab environments for every test cycle.

## Challenges

- Cross-platform MQTT broker implementations had subtle differences in QoS (Quality of Service) levels and retained-message behavior.
- LoRaWAN gateway configuration varied significantly between providers — required custom firmware tweaks on the Raspberry Pi concentrator boards.
- Hadoop job tuning was platform-specific; Yarn configurations that worked on Azure HDInsight failed on Amazon EMR without adjustment.
- Cost tracking across five clouds was a project in itself — each platform's billing model required separate monitoring dashboards.

## Outcome

The evaluation produced a 120-page recommendation report adopted by the CTO's office. Azure was selected as the primary cloud, with AWS as the DR (Disaster Recovery) fallback. The automated lab environment became the company's standard for future POCs, cutting new-project spin-up from weeks to hours.

## Key takeaway

**Multi-cloud isn't about avoiding lock-in — it's about picking the right tool for each job.** IoT ingestion favored Azure, Big Data favored AWS at the time, and ML training was most cost-effective on GCP. The recommendation was pragmatic, not dogmatic.
