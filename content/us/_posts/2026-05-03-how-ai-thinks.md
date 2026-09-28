---
layout: post
title: How AI "Thinks"
description: A very intuitive explanation of AI's "ability" to "think"
date: '2026-05-03 10:00:00'
tags: [AI, NLP, Natural Language]
section: blog
image: /assets/content/blogs/AI/models.png
image_alt: Models are needed to "see" the universe
permalink: /blog/how-ai-thinks/
---

I admit I used to be an AI skeptic. I have been programming computers since 1982. My first computer had one kilobytes of RAM and on boot, it took away 300 bytes, leaving me with 700 bytes. I knew precisely what I wrote, where it went, and what it did. How can AI do things that its developers were surprised to find that it could? 

## What "thinking" means for a chatbot-style model

A large language model (LLM) is trained to **predict plausible next symbols**—usually fragments of words (tokens)—given what it has seen so far. That training compresses staggering amounts of text into billions of numerical knobs (weights) inside a neural network.

Natural language is a model of the universe. When I say “I am driving a car,” I’m not just producing words—I’m encoding a structured representation of reality: a singular subject (“I”), a contemporary verb (“am driving”), and an object (“a car”), all linked through a predicate or lack thereof, that specifies an action occurring in the world. In other words, language breaks experience into roles and relations that we can manipulate symbolically.

This is a big part of why AI can appear to “think.” Modern language models are trained on vast amounts of such representations, learning the statistical patterns that connect subjects, predicates, verbs, objects, and broader semantic structures to situations, intentions, causes, and outcomes. As they generate responses, they aren’t experiencing the world, but they are operating over these learned linguistic models in a way that resembles reasoning—predicting what subject comes next, what predicate is plausible, what object fits the context, and how a sequence of ideas should unfold. The result is behavior that feels like thought, because it is built on the same grammatical and relational scaffolding (subject–verb–object, predicate logic, semantic roles) that humans use to compress and reason about reality.

## Why it can feel like reasoning

Several effects stack up for the illusion of reasoning:

1. **Pattern completion at scale.** If the training data reliably pairs "symptom X" with "diagnosis Y," the model can surface that association without a separate "medical module."
2. **Chain-of-thought-style behavior** (whether you prompt "think step by step" or the system does it implicitly) lengthens the *internal stream of tokens* before an answer token. More intermediate text means more chances to correct course—similar in effect to scribbling scratch work, except it's still prediction all the way down.
3. **Alignment training** teaches the model preferences: be helpful, refuse harmful requests, follow instructions. That reshapes probabilities; it doesn't install a conscience.

Together, fluent language plus local consistency can impersonate deliberate reasoning—even when what's really happening is **statistical coherence** stretched across many hops.

## Architecture in one breath

Roughly:

- **Tokenization**: text -> numbered tokens  
- **Embeddings**: tokens -> vectors in a shared space  
- **Transformer layers**: each position updates its representation by attending to others (that's the famous "attention" idea-context mixing, not spotlight consciousness)  
- **Output layer**: logits over the vocabulary -> sampled next token  

That skeleton is shared across stacks of GPT-style decoder-only models, encoder-decoder setups, multimodal hybrids, etc. Naming varies; the gist is stable: **context in, probabilities out**.

## NLP, language, and limits

Natural language is the universal interface-not because computers "speak," but because we trained models on oceans of humanity's writing and speech-derived text.

Strengths you're seeing in the wild: summarization, translation, drafting, code assistance, search-style Q&A *when* facts are present in context or well represented in training.

Weak spots worth keeping in your head:

- **Hallucination**: fluent falsehood when the predictive path looks reasonable.  
- **Stale knowledge** unless tooling or retrieval fills gaps.  
- **No grounded self**: it doesn't observe the world continuously; anything not in prompts, tools, or internal weights is inaccessible.  

## A grounded takeaway

Treat "thinking" as a **shortcut metaphor**. The mechanism is differentiable prediction plus scale, scaffolding, retrieval, guardrails-and your prompts. Respect what it does well; double-check anything that matters.

If you'd rather say AI **simulates reasoning-like behavior**, you're on solid footing without spoiling what's remarkable about these systems-that they turn raw text exposure into extraordinarily capable language machines.
