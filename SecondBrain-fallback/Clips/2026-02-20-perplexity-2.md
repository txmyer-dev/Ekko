---
title: "Perplexity"
type: web-clip
domain: learning
tags: [web-clip]
date: 2026-02-20
source: "https://www.perplexity.ai/search/hey-sunshine-it-s-been-awhile-e7O6JIllRJaVET.TNl4YoA"
status: inbox
author: "Unknown"
site: "Perplexity AI"
---

There isn’t an official, first‑party “Perplexity CLI app” from Perplexity itself, but you can absolutely use Perplexity from the terminal via third‑party CLIs and generic LLM CLIs wired to the Perplexity API.

At a high level you’ve got three options:

1.  Unofficial Perplexity‑specific CLIs
    
    *   There are community tools (often called things like `perplexity` or `pplx-cli`) that wrap the Perplexity API and give you commands like `perplexity "your question"` or `perplexity ask "…"`.
        
    *   These usually support interactive chat, model selection, and sometimes simple RAG over a local notes directory.
        
2.  Generic LLM CLIs with a Perplexity backend
    
    *   Tools like `llm` (Simon Willison’s) let you register Perplexity as a model provider and then call it with something like `llm -m sonar-pro "question"`.
        
    *   That’s nice for your use case because you can treat Perplexity as “just another model” alongside Claude, Gemini, OpenAI, etc., all from one CLI.

## My Notes



## Related

